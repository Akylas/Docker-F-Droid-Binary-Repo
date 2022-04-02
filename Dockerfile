FROM python:3.7.12-slim-buster

EXPOSE 80

#   Ensure that the local python is preferred over distribution python
ENV PATH /usr/local/bin:$PATH
ENV LANG=C.UTF-8

#
#   This hack is widely applied to avoid python printing issues in docker containers.
#   See: https://github.com/Docker-Hub-frolvlad/docker-alpine-python3/pull/13
#
ENV PYTHONUNBUFFERED=1

#
#   The two lines below are there to prevent a red line error to be shown about apt-utils not being installed
#
ARG DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-c"]

RUN apt-get update && apt-get install -y \
  wget \
  git \
  unzip \
  openjdk-11-jdk \
  nginx \
  && rm -rf /var/lib/apt/lists/* \
  && apt-get clean \
  && rm /etc/nginx/sites-enabled/default

RUN pip3 install --no-cache-dir fdroidserver && pip3 cache purge


# WORKDIR /app
# RUN git clone https://gitlab.com/fdroid/fdroidserver.git \
#   && rm -fr fdroidserver/.git \
#   && ln -sf /app/fdroidserver/fdroid /usr/bin/fdroid

ENV ANDROID_HOME=/usr/local/sdk
ENV CLI_TOOL_VERSION=commandlinetools-linux-6858069_latest
ENV PATH=$PATH:$ANDROID_HOME:$ANDROID_HOME/cmdline-tools/tools/bin

# install android sdk
RUN mkdir -p $ANDROID_HOME/cmdline-tools && \
  wget "https://dl.google.com/android/repository/${CLI_TOOL_VERSION}.zip" && \
  unzip -d $ANDROID_HOME/cmdline-tools $CLI_TOOL_VERSION.zip && \
  rm -rf $CLI_TOOL_VERSION.zip && \
  mv $ANDROID_HOME/cmdline-tools/cmdline-tools $ANDROID_HOME/cmdline-tools/tools

# prepare sdkmanager
RUN yes | sdkmanager --licenses

# install android tools
RUN sdkmanager "build-tools;30.0.3" && rm -fr $ANDROID_HOME/emulator

WORKDIR /app
RUN git clone https://github.com/farfromrefug/fdroidserver.git

COPY . /

CMD ["/entrypoint.sh"]
