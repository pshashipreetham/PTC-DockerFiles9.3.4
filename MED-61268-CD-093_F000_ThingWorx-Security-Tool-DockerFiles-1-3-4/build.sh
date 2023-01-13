#!/bin/bash
source build.env

# determine the java version from the archive name
if [[ "$JAVA_ARCHIVE" =~ [0-9]+u[0-9]+ ]]; then
   JAVA_VERSION="${BASH_REMATCH[0]}"
   JAVA_PRODUCT_VERSION="${JAVA_VERSION%%u*}"
elif [[ "$JAVA_ARCHIVE" =~ [0-9]+(\.[0-9]+){2} ]]; then
   JAVA_VERSION="${BASH_REMATCH[0]}"
   JAVA_PRODUCT_VERSION="${JAVA_VERSION%%.*}"
else
  exit_status 1 "Unable to determine Java version from archive"
fi

exit_status () {
    if [ $1 -ne 0 ]; then
        echo "${2}: Failed."
        exit $1
    else
        echo "${2}: Success"
    fi
}

setup_build_dir () {
  if [ ! -d "$1" ]; then
      echo "Failed to find Dockerfile dir: $1"
      exit 1
  fi
  mkdir build
  cp -r staging build/.
  cp -r "$1/." build/.
}

clean_build_dir () {
    rm -rf build
}

#Build security-tool
build_security_tool () {
    setup_build_dir "dockerfiles/security-tool"
    (
        cd build
        docker build --build-arg SECURITY_TOOL_ARCHIVE=${SECURITY_TOOL_ARCHIVE} \
        --build-arg TEMPLATE_PROCESSOR_ARCHIVE=${TEMPLATE_PROCESSOR_ARCHIVE} \
        --build-arg JAVA_ARCHIVE=${JAVA_ARCHIVE} \
        --build-arg BASE_IMAGE=${BASE_IMAGE} \
        -t thingworx/security-tool:${SECURITY_TOOL_VERSION}\
        -t thingworx/security-tool:latest \
        .
    )
    exit_status $? "Build security-tool Image"
    clean_build_dir
    return 0
}

# Build all variants
build_all () {
    build_security_tool
    return 0
}

clean_build_dir
build_all

