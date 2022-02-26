FROM runmymind/docker-android-sdk:alpine-lazydl

EXPOSE 80

# install my SDK Packages
COPY mypackagelist/package-list.txt /opt/tools/package-list.txt
RUN chmod a+rw /opt/tools/package-list.txt
RUN ls -l /opt/tools/package-list.txt
RUN cat /opt/tools/package-list.txt
RUN /opt/tools/entrypoint.sh lazy-dl

# install python
RUN apk add --update --no-cache python3 python3-dev py3-pip rsync && ln -sf python3 /usr/bin/python

# install gcc needed to build fdroidserver
RUN apk add --no-cache build-base

RUN apk add freetype-dev \
        libpng-dev \
        libffi-dev \
        jpeg-dev

# install the fdroidserver
RUN python3 -m pip install --no-cache-dir --upgrade setuptools pip && \
    python3 -m pip install --no-cache-dir wheel && \
    python3 -m pip install --no-cache-dir fdroidserver

# install nginx for fdroid server
RUN apk add nginx
RUN apk del build-base

RUN python3 -m pip cache purge
# RUN apk cache clean
# RUN rm /etc/nginx/sites-enabled/default

# Workaround for non writeable SDK FOLDER
# RUN chmod -R g+rw /opt/android-sdk-linux

COPY . /

CMD ["/entrypoint.sh"]
