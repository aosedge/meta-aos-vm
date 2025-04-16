FROM ubuntu:22.04

# Fix for tzdata for docker image build
ENV TZ=UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install necessery for build packages
RUN apt-get update && apt-get install -y \
    apt-utils gawk wget git-core diffstat unzip texinfo gcc-multilib build-essential chrpath socat \
    cpio python2 python3 python3-pip python3-pexpect xz-utils debianutils iputils-ping \
    python3-git python3-jinja2 libegl1-mesa libsdl1.2-dev xterm \
    vim locales rsync devscripts debhelper dkms curl imx-code-signing-tool jq \
    ninja-build zstd liblz4-tool dosfstools mtools

RUN apt-get install --reinstall -y ca-certificates

# Clean up APT when done.
RUN apt-get clean && rm -rf /tmp/* /var/tmp/*

# Set the locale for fix this:
# "Please use a locale setting which supports UTF-8 (such as LANG=en_US.UTF-8)."
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Define name for user and uid/gid
ENV USER_NAME=yocto
ARG USER_ID=1000
ARG USER_GID=1000

# Creating the user
RUN groupadd --gid "${USER_GID}" "${USER_NAME}" && \
    useradd \
    --uid ${USER_ID} \
    --gid ${USER_GID} \
    --create-home \
    --shell /bin/bash \
    ${USER_NAME}

# Switch the user from root to $USER_NAME (yocto)
USER $USER_NAME

# Install moulin
RUN pip3 install --user git+https://github.com/xen-troops/moulin

# Create workdir for docker and define it as WORKDIR
RUN mkdir -p /home/$USER_NAME/workspace
RUN chown $USER_NAME:$USER_NAME /home/$USER_NAME/workspace
ENV BUILD_DIR /home/$USER_NAME/workspace
ENV PATH="${PATH}:/home/${USER_NAME}/.local/bin"

WORKDIR $BUILD_DIR
