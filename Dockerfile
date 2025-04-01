# https://github.com/dusty-nv/jetson-containers
FROM dustynv/ros:foxy-desktop-l4t-r35.4.1

# Maintainer Information
LABEL maintainer="wengkunduo@gmail.com"

RUN apt-get update

# 關閉互動模式
ENV DEBIAN_FRONTEND=noninteractive

## NVIDIA GraphicsCard parameter
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES all

# 接收外部參數
ARG USER=initial
ARG UID=1000
ARG GROUP=initial
ARG GID=1000
ARG GID=${UID}
ARG SHELL=/bin/bash

# 創建一個名為initial的用戶和用戶組
# RUN groupadd -g $GID $GROUP && \
#     useradd -m -u $UID -g $GID -s /bin/bash $USER

## Setup users and groups
RUN groupadd --gid ${GID} ${GROUP} \
  && useradd --gid ${GID} --uid ${UID} -ms ${SHELL} ${USER} \
  && mkdir -p /etc/sudoers.d \
  && echo "${USER}:x:${UID}:${UID}:${USER},,,:$HOME:${shell}" >> /etc/passwd \
  && echo "${USER}:x:${UID}:" >> /etc/group \
  && echo "${USER} ALL=(ALL) NOPASSWD: ALL" > "/etc/sudoers.d/${USER}" \
  && chmod 0440 "/etc/sudoers.d/${USER}"

# Update and Install Packages
RUN apt-get update
RUN apt-get install -y software-properties-common
RUN apt-get install -y bash-completion
RUN apt-get install -y at-spi2-core
RUN apt-get install -y htop git wget curl
RUN apt-get install -y byobu zsh
RUN apt-get install -y terminator 
RUN apt-get install -y dbus-x11 libglvnd0 libgl1 libglx0 libegl1 libxext6 libx11-6 libxtst6 libinih-dev
RUN apt-get install -y nano vim
RUN apt-get install -y gnome-terminal libcanberra-gtk-module libcanberra-gtk3-module
RUN apt-get install -y python3-wheel python3-pip python3-dev python3-setuptools
# RUN apt-get install -y libopencv-dev
RUN apt-get install -y openssh-server
RUN apt-get install -y cmake
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/*

RUN apt update
RUN apt install -y python3-tk

# Install ROS Foxy packages
RUN apt-get update && apt-get install -y \
    ros-foxy-cartographer \
    ros-foxy-cartographer-ros \
    ros-foxy-navigation2 \
    ros-foxy-nav2-bringup && \
    echo "source ~/.bashrc" >> ~1 && \
    /bin/bash -c "source ~/.bashrc" && \
    apt-get install -y \
    python3-argcomplete \
    python3-colcon-common-extensions \
    libboost-system-dev \
    build-essential \
    ros-foxy-hls-lfcd-lds-driver \
    ros-foxy-turtlebot3-msgs \
    ros-foxy-turtlebot3 \
    ros-foxy-dynamixel-sdk \
    python3-argcomplete python3-colcon-common-extensions libboost-system-dev build-essential\
    libudev-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

#=========================================================
#    Modifly bash
#=========================================================
RUN echo 'if [ -f /etc/bash_completion ]; then' >> /etc/bash.bashrc \
    && echo '    . /etc/bash_completion' >> /etc/bash.bashrc \
    && echo 'fi' >> /etc/bash.bashrc

# Set permanent environment variable
RUN echo 'export LDS_MODEL=LDS-02' >> /etc/bash.bashrc \
    && echo "source /opt/ros/foxy/install/setup.bash" >> /etc/bash.bashrc \
    && echo 'export TURTLEBOT3_MODEL=burger' >> /etc/bash.bashrc \
    && echo "export ROS_DOMAIN_ID=11" >> /etc/bash.bashrc \

# 安裝opencv與tensorflow
# RUN pip3 install opencv-python tensorflow==2.11.0 matplotlib

# Dynamixel-SDK
RUN pip3 install dynamixel-sdk

# Switch apt source to Taiwan's mirror
RUN sed -i 's@archive.ubuntu.com@tw.archive.ubuntu.com@g' /etc/apt/sources.list

# Timezone
RUN echo "tzdata tzdata/Areas select Asia" | debconf-set-selections && \
    echo "tzdata tzdata/Zones/Asia select Taipei" | debconf-set-selections && \
    apt-get update && apt-get install -y tzdata && \
    ln -snf /usr/share/zoneinfo/$TIME_ZONE /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /home/${USER}/.config/terminator/

WORKDIR /home/${USER}
USER ${USER}

RUN mkdir work
WORKDIR /home/${USER}/work

CMD ["terminator"]
USER $USER


