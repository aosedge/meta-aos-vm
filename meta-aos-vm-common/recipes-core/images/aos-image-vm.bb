SUMMARY = "An image which contains AOS components"
LICENSE = "Apache-2.0"

IMAGE_LINGUAS = " "

ROS_DISTRO = "jazzy"
ROS_WORLD_SKIP_GROUPS:append = " moveit fortran qt5 ogre webots-python-modules opengl x11 gazebo gazebo11 hunter"

require recipes-core/images/aos-image.inc
require recipes-core/images/ros-image-core.bb

inherit core-image extrausers

IMAGE_INSTALL = "packagegroup-core-boot ${CORE_IMAGE_EXTRA_INSTALL}"
IMAGE_FSTYPES = "ext4"

# Set password to the root user. This is the requirement of the provisioning script.
EXTRA_USERS_PARAMS = "usermod -p '\$6\$1A1UsrSPWS8nQFZP\$dI8sN.4/y00EWaLEN22tWcLtrBKD08hZTitCub4BhEC2qrDZhQF3YKapF3bXLFq0rsj6xhlJehrEHDJfDFcsF/' -s /bin/bash root;"

# System packages
IMAGE_INSTALL:append = " \
    bash \
    iperf3 \
    iproute2 \
    iproute2-tc \
    mc \
    netconfig \
    openssh \
    tzdata \
    wget \
"

# Python packages required by the ROS2 application
IMAGE_INSTALL:append = " \
    python3-ultralytics \
    python3-valkey \
    python3-open3d \
    python3-plotly \
    python3-dash \
    python3-botocore \
    python3-scikit-learn \
    python3-addict \
    python3-paho-mqtt \
    redis \
    python3-yolov5 \
    rosbag2 \
"

# python3-open3d

# Set fixed rootfs size
IMAGE_ROOTFS_SIZE ?= "15728640"
IMAGE_OVERHEAD_FACTOR ?= "1.0"
IMAGE_ROOTFS_EXTRA_SPACE ?= "524288"
