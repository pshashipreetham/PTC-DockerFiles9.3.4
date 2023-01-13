# ThingWorx Ignite Dockerfiles

## Overview
This package provides Dockerfile and supplemental scripts required to
build Security Tool image required to run ThingWorx.

While there is very simple example on how to run the image built using docker compose, more in
depth examples can be found in the ThingWorx Docker Guide on the PTC Support
Downloads site alongside this release.

## Prerequisites
This topic covers the required Docker software to run ThingWorx Security Tool Docker image.

### Operating System
Docker images can be run on any platform supporting Docker.

Only linux operating system  supports building the Docker images. The
scripts have been validated on Ubuntu and should work on other Linux
operating systems that support Docker and Docker Compose. Note that PTC has
not validated other systems.

### Docker Versions
The following Docker versions are required:

* Docker Community Edition (docker-ce)

    Version 19 or higher is recommended. To install the Docker Community
    Edition on your system, follow the instructions for your operating system on
    the Docker website: https://www.docker.com/community-edition#/download.

* Docker Compose (docker-compose)

    Version 1.25 or higher is recommended. To install the Docker Compose on
    your system, follow the instructions for your operating system on the Docker
    website: https://docs.docker.com/compose/install/.## Setting Up For ThingWorx Ignite Docker Builds

In order to build the Thingworx Security Tool Docker images there are two major
steps that need to be done:
The first is to make sure the needed binaries are staged and available for the build process.
The second is to verify & modify, if required, the `build.env` variable file with appropriate values.

### Required Files
Knowledge of the files required will help determine the variables and staging details that are necessary.

#### `build.env` Variables
The following are a list of variables in `build.env` that must be set.

| Variable                   | Default                                                        | Comment                                                                                                                               |
|----------------------------|----------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------|
| JAVA_ARCHIVE               | amazon-corretto-11.0.8.10.1-linux-x64.tar.gz                    | The file name of the Java archive as it exists in the `staging` directory.  |
| SECURITY_TOOL_VERSION             | 1.3.4.104                                                | The Security Tool Library Version                                                                                                             |
| SECURITY_TOOL_ARCHIVE             | security-common-cli-1.3.4.104.tar.gz                                               | The Security Tool Library name as it exists in the `staging` directory.                                                                                                                 |
| TEMPLATE_PROCESSOR_ARCHIVE | template-processor-12.1.0.15-application.tar.gz                                    | The version of the template processor archive as it exists in the `staging`  |


### Staging Files
You must put the required files for building the Docker images in the `staging`
folder that is part of this release.

#### Java
The Java JDK 8 or 11 archive downloaded from Oracle or other source.  

#### ThingWorx Security Tool Archive
The ThingWorx Security Tool Archive can be downloaded from the PTC Support Downloads
site alongside this Dockerfile release.

Save these files into the `staging` directory and make sure the
`SECURITY_TOOL_ARCHIVE` variable matches the file.

#### Template Processor Archive
The Template Processor program is included in the `staging` directory and should
be included in the Docker builds automatically. Double-check the version and
archive file name in `staging` match your `build.env` settings.

## Building The ThingWorx Security Tool Images
With the setup complete, it is now possible to run the build script to create the
Docker images.

The included `build.sh` script is able to take the variables set previously and
work with the `staging` directory to make sure the Docker build command has the
appropriate variables and build context passed in.

To build the images run the command: `./build.sh`

After the build process completes there will be Docker images available .

This guide is mainly targeting the building of the Docker Images. For more detailed
usage examples and configuration please see the full documentation that can be
found in the ThingWorx Docker Guide on the PTC Support Downloads site alongside
this release.

# Container configuration

Container can be configured using environment variables

##  KeyStore Secret Provider

To run the CLI and have it setup and populate a KeyStore you need to pass an
environment variable KEYSTORE with the value true.    When KeyStore is enabled you can
configure it with additional environment variables listed below.

- KEYSTORE

When true the tool will create a configuration file using the KeyStore environment
variables.

- KEYSTORE_PASSWORD_FILE_PATH

Sets the path to the KeyStore password file.   The path is REQUIRED.

- KEYSTORE_PASSWORD_FILE_NAME

Sets the name of the KeyStore password file.   It will default to "keystore-password".

- KEYSTORE_FILE_PATH

Sets the path to the KeyStore file.  The path is REQUIRED.

- KEYSTORE_FILE_NAME

Sets the KeyStore filename.  Defaults to "keystore".

## Common Provider Configurations

- DEFAULT_ENCRYPTION_KEY_LENGTH

This sets the default key length used when creating new encryption keys.   It does effect
the size of existing keys.  The default is 256 bytes.

## Initializing Secrets

The secrets are passed to the tool using environment variables.

#Option 1:
It will process all environment variables starting the text "SECRET_"

The following would be valid environment variable names:

* SECRET_MYSECRET
* SECRET_SECRET1
* SECRET_SPECIAL_SECRET_VALUE

The name of the environment variable will have the SECRET_ prefix stripped and will be converted to lower case to be used as the key

Example:
* SECRET_MYSECRET => mysecret

The value of the environment variable is value of secret to be set

#Option 2:
It will process the environment variable with name 'CUSTOM_SECRET_LIST' and value that's a comma-separated list of secretKey-envVarName pairs. The comma-separated value will be tokenized and for each secretKey-envVarName token, the environment variable represented by envVarName will be read into a secretValue variable. This secretKey-secretValue pair will be set in the keystore.

Example value of the CUSTOM_SECRET_LIST environment variable:
* mysecretkey1:<env-var that has the value for this key>,mysecretkey2:<env-var that has the value for this key>

## Example Compose for KeyStore

The below example will create a shared storage volume.  In the container we map it
to /SecureData and that is where we configure the location of the KeyStore and
KeyStore Password Files. The container will start up and run and will create/update
the KeyStore values. Once all values have been populated the container will exit.

docker-compose.yml
```
version: '2.3'
volumes:
    storage:

services:
  secrets:
    image: artifactory.rd2.thingworx.io/twxdevops/security-cli:latest
    environment:
      - "KEYSTORE=true"
      - "KEYSTORE_PASSWORD_FILE_PATH=/SecureData"
      - "KEYSTORE_FILE_PATH=/SecureData"
      - "SECRET_MYSECRET=zyfdzhij"
      - "SECRET_SECRET1=mydata1"
      - "SECRET_MY_SECRET2=mydata2"
      - "SECRET_SPECIAL_SECRET_VALUE=mydata3"
      - "TWX_DATABASE_PASSWORD=abcd"
      - "LS_PASSWORD=efgh"
      - "CUSTOM_SECRET_LIST=encrypt.db.password:TWX_DATABASE_PASSWORD,encrypt.licensing.password:LS_PASSWORD"
    volumes:
      - storage:/SecureData
```

To use the file above if you run "docker-compose up secrets" it will generate the
output

```
secrets_1  | Running command with config:
secrets_1  | Config(SimpleConfigObject({"output-file":"/opt/cli.conf","sources":{"scripts":[]},"template-file":"/opt/cli.conf.j2","type":"process-template"}))
secrets_1  | Loading config from file /opt/cli.conf
secrets_1  | mysecret stored
secrets_1  | Loading config from file /opt/cli.conf
secrets_1  | secret1 stored
secrets_1  | Loading config from file /opt/cli.conf
secrets_1  | my_secret2 stored
secrets_1  | Loading config from file /opt/cli.conf
secrets_1  | special_secret_value stored
secrets_1  | Loading config from file /opt/cli.conf
secrets_1  | encrypt.db.password stored
secrets_1  | Loading config from file /opt/cli.conf
secrets_1  | encrypt.licensing.password stored
secrets_1  | security-common-cli-docker_secrets_1 exited with code 0
```