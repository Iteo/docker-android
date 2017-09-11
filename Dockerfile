FROM java:8-jdk

ENV     DEBIAN_FRONTEND             noninteractive
ENV     ANDROID_HOME                /opt/android-sdk-linux
ENV     ANDROID_SDK_TOOLS_VERSION   3952940

ENV     PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools

RUN     echo ANDROID_HOME="$ANDROID_HOME" >> /etc/environment

# Install utils
RUN     dpkg --add-architecture i386 \
            && apt-get update \
            && apt-get install -y --force-yes \
                expect \
                git \
                wget \
                libc6-i386 \
                lib32stdc++6 \
                lib32gcc1 \
                lib32ncurses5 \
                lib32z1 \
                file \
            && apt-get clean \
            && rm -rf /var/lib/apt/lists/*

# Android #
## Download and extract Android Tools
RUN     wget https://dl.google.com/android/repository/sdk-tools-linux-${ANDROID_SDK_TOOLS_VERSION}.zip -O /tmp/android-tools.zip \
            && mkdir -p ${ANDROID_HOME} \
            && unzip /tmp/android-tools.zip -d ${ANDROID_HOME} \
            && rm -v /tmp/android-tools.zip \
            && chmod +x ${ANDROID_HOME}/tools/bin/sdkmanager

## Accept Licences
RUN     mkdir -p $ANDROID_HOME/licenses/ \
            && echo "8933bad161af4178b1185d1a37fbf41ea5269c55" > $ANDROID_HOME/licenses/android-sdk-license \
            && echo "84831b9409646a918e30573bab4c9c91346d8abd" > $ANDROID_HOME/licenses/android-sdk-preview-license

## Install packages
COPY    packages.txt ${ANDROID_HOME}
RUN     mkdir -p /root/.android \
            && touch /root/.android/repositories.cfg \
            && sdkmanager --update \
            && sdkmanager --package_file=${ANDROID_HOME}/packages.txt --verbose

# Copy install tools
COPY tools /opt/tools
RUN chmod +x /opt/tools/android-start-emulator.sh /opt/tools/android-wait-for-emulator.sh

ENV PATH ${PATH}:/opt/tools

# use 64bit bash for emulator
ENV SHELL /bin/bash 

RUN     avdmanager create avd -n api25 -k "system-images;android-25;google_apis;x86_64" -c 1000M --device "Nexus 5X"