FROM node:6.9.4-slim
MAINTAINER j.ciolek@webnicer.com
WORKDIR /tmp
COPY webdriver-versions.js ./
ENV CHROME_PACKAGE="google-chrome-stable_58.0.3029.96-1_amd64.deb" NODE_PATH=/usr/local/lib/node_modules
RUN npm install -g protractor@4.0.14 mocha@3.2.0 jasmine@2.5.3 minimist@1.2.0 && \
    node ./webdriver-versions.js --chromedriver 2.27 && \
    webdriver-manager update && \
    echo "deb http://ftp.debian.org/debian jessie-backports main" >> /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y xvfb wget sudo && \
    apt-get install -y -t jessie-backports openjdk-8-jre && \
    wget https://github.com/webnicer/chrome-downloads/raw/master/x64.deb/${CHROME_PACKAGE} && \
    dpkg --unpack ${CHROME_PACKAGE} && \
    apt-get install -f -y && \
    apt-get clean && \
    rm ${CHROME_PACKAGE} && \
    mkdir /protractor && \
    uid=$(stat -c %u ${PWD}) && \
    gid=$(stat -c %g ${PWD}) && \
    groupadd -o -g $gid protractor && \
    useradd -m -g $gid protractor 
COPY protractor.sh /protractor.sh
USER protractor
# Fix for the issue with Selenium, as described here:
# https://github.com/SeleniumHQ/docker-selenium/issues/87
ENV DBUS_SESSION_BUS_ADDRESS=/dev/null SCREEN_RES=1280x1024x24
WORKDIR /protractor
ENTRYPOINT ["/protractor.sh"]
