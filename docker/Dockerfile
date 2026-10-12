FROM ros:humble

ARG UID
ARG GID
ARG USER_NAME
ARG BUILD_WITH_CUDA

SHELL ["/bin/bash", "-c"]

WORKDIR /home/setup

# RUN if [ -n "${GID_AUDIO}" ] ; then groupadd -f -g ${GID_AUDIO} audio ; fi
# RUN if [ -n "${GID_VIDEO}" ] ; then groupadd -f -g ${GID_VIDEO} video ; fi

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
    tzdata \
    && rm -rf /var/lib/apt/lists/*
ENV TZ=Asia/Tokyo

RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo \
    nano \
    iputils-ping \
    net-tools \
    iproute2 \
    traceroute \
    zip \
    unzip \
    psmisc \
    wget \
    git \
    cmake \
    software-properties-common \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

COPY /setup/setup-cuda.sh ./
COPY /setup/setup-tensorrt.sh ./
COPY /setup/setup-spconv.sh ./
RUN if [ ${BUILD_WITH_CUDA} = ON ] ; \
    then \
        ./setup-cuda.sh ; \
        ./setup-tensorrt.sh ; \
        ./setup-spconv.sh ; \
    fi

RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-humble-rmw-cyclonedds-cpp \
    && rm -rf /var/lib/apt/lists/*

COPY /setup/setup-autoware.sh ./
RUN ./setup-autoware.sh

#RUN apt-get upgrade

RUN groupadd -g ${GID} ${USER_NAME}
RUN useradd -m -u ${UID} -g ${GID} ${USER_NAME}
RUN echo "${USER_NAME}:${USER_NAME}" | chpasswd

# RUN echo "${USER_NAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
RUN echo "${USER_NAME} ALL=(ALL:ALL) ALL" > /etc/sudoers.d/${USER_NAME} && chmod 0440 /etc/sudoers.d/${USER_NAME}

# RUN usermod -a -G audio ${USER_NAME}
# RUN usermod -a -G video ${USER_NAME}

RUN mkdir -p /home/${USER_NAME}

RUN cp -r ./autoware_data /home/${USER_NAME}
RUN chown -R ${USER_NAME}:${USER_NAME} /home/${USER_NAME}

USER ${USER_NAME}

WORKDIR /home/${USER_NAME}

RUN if [ ${BUILD_WITH_CUDA} = ON ] ; \
    then \
      echo '' >> ~/.bashrc ; \
      echo 'export PATH=/usr/local/cuda/bin:${PATH}' >> ~/.bashrc ; \
      echo 'export LD_LIBRARY_PATH=/usr/local/cuda/lib64:${LD_LIBRARY_PATH}' >> ~/.bashrc ; \
    fi

COPY --chown=${USER_NAME}:${USER_NAME} /setup/cyclonedds.xml ./

RUN echo '' >> ~/.bashrc
RUN echo 'source /opt/ros/humble/setup.bash' >> ~/.bashrc
RUN source ~/.bashrc
