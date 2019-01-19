FROM java:8-jdk

ENV     DEBIAN_FRONTEND             noninteractive
ENV     ANDROID_HOME                /opt/android-sdk-linux
ENV     ANDROID_SDK_TOOLS_VERSION   4333796

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

# Accept licenses before installing components
RUN yes | sdkmanager --licenses

RUN sdkmanager "emulator" "tools" "platform-tools"

## Install packages
RUN     mkdir -p /root/.android \
            && touch /root/.android/repositories.cfg \
            && sdkmanager --update \
            && sdkmanager \
		"build-tools;28.0.3" \
                "build-tools;27.0.3" \
                "build-tools;27.0.2" \
                "build-tools;27.0.1" \
                "build-tools;26.0.2" \
                "build-tools;26.0.1" \
                "build-tools;26.0.0" \
                "build-tools;25.0.3" \
                "build-tools;25.0.2" \
                "build-tools;24.0.3" \
                "build-tools;23.0.3" \
                "build-tools;22.0.1" \
                "platform-tools" \
		"platforms;android-28 \
                "platforms;android-27" \
                "platforms;android-26" \
                "platforms;android-25" \
                "platforms;android-24" \
                "platforms;android-23" \
                "platforms;android-22" \
                "platforms;android-21" \
                "platforms;android-20" \
                "platforms;android-19" \
                "platforms;android-18" \
                "platforms;android-17" \
                "extras;android;m2repository" \
                "extras;google;m2repository" \
                "emulator" \
                "system-images;android-25;google_apis;x86_64"

# Copy install tools
COPY tools /opt/tools
RUN chmod +x /opt/tools/android-start-emulator.sh /opt/tools/android-wait-for-emulator.sh

ENV PATH ${PATH}:/opt/tools

# use 64bit bash for emulator
ENV SHELL /bin/bash 

RUN     avdmanager create avd -n api25 -k "system-images;android-25;google_apis;x86_64" -c 1000M --device "Nexus 5X"
