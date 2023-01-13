ARG BASE_IMAGE
FROM ${BASE_IMAGE} as builder

ARG JAVA_ARCHIVE
ARG SECURITY_TOOL_ARCHIVE
ARG TEMPLATE_PROCESSOR_ARCHIVE

COPY staging/ /tmp/

RUN mkdir -p /opt/jdk && \
    tar -C /opt/jdk --strip-components=1 -xavf "/tmp/${JAVA_ARCHIVE}" \
    && rm "/tmp/${JAVA_ARCHIVE}"

ENV JAVA_HOME=/opt/jdk \
    PATH=${PATH}:/opt/jdk/bin \
    LANG=C.UTF-8

RUN cd /opt

RUN mkdir /opt/template-processor \
    && tar -xvzf "/tmp/${TEMPLATE_PROCESSOR_ARCHIVE}" -C "/opt/template-processor" --strip-components=1 \
    && rm "/tmp/${TEMPLATE_PROCESSOR_ARCHIVE}"

RUN mkdir -p /opt/security-tool \
    && tar -xvzf "/tmp/${SECURITY_TOOL_ARCHIVE}" -C "/opt/security-tool" --strip-components=1 \
    && rm "/tmp/${SECURITY_TOOL_ARCHIVE}"

RUN apt-get update && apt-get -y --no-install-recommends install python3-pip

COPY imageFiles/ /opt/
RUN chmod +x /opt/docker-entrypoint.sh

CMD /opt/docker-entrypoint.sh
