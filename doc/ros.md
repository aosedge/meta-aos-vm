# ROS2 jazzy SDK environment setup

## Setup ROS2 jazzy SDK environment

### Source the AOS core SDK environment

```sh
source /opt/aos-core-sdk/genericx86-64/ros/environment-setup-core2-64-aos-linux
```

### Source the ROS2 jazzy SDK environment

```sh
source $OECORE_TARGET_SYSROOT/opt/ros/jazzy/setup.sh
```

## Build ROS2 workspace

### Build workspace using SDK

On this step it's expected that you have already sourced the AOS core SDK environment
and ROS2 jazzy SDK environment.
And all the desired ROS2 packages are already cloned into the workspace: `$PWD/src`.

```sh
colcon build \
    --merge-install \
    --install-base $PWD/install \
    --cmake-args \
    " --no-warn-unused-cli" \
    " -DCMAKE_TOOLCHAIN_FILE=$CMAKE_TOOLCHAIN_FILE" \
    " -DCMAKE_STAGING_PREFIX=$PWD/install" \
    " -DPYTHON_SOABI=$(basename -s so $PYTHON_SOABI)" \
    " -DPython3_NumPy_INCLUDE_DIR=$OECORE_TARGET_SYSROOT/usr/lib/python3.12/site-packages/numpy/core/include" \
    " -DBUILD_TESTING=OFF"
```

Once built, install, build, log folders are created in the workspace root folder.
Suggested to remove all these generated folder to perform a clean build of the workspace.

## Creating an Aos Service

### Expose ROS2 utils as an SM resource on the target device

Make sure `/opt/ros/jazzy` folder is mounted as a read-only resource
in the Aos Service configuration file `/etc/aos/resources.cfg`:

```sh
cat /etc/aos/resources.cfg 
[
    {
        "name": "ros2-jazzy",
        "mounts": [
            {
                "source": "/opt/ros/jazzy",
                "destination": "/opt/ros/jazzy",
                "type": "bind",
                "options": ["bind", "ro"]
            }
        ]
    }
]
```

### Create an Aos Service

Copy the `install` folder from the workspace to the Aos Service folder.
I suggest adding a `run.sh` script to the Aos Service folder to make it
an entrypoint for the Aos Service.

```sh
source /opt/ros/jazzy/setup.bash
source install/local_setup.bash

export ROS_LOG_DIR=/storage

ros2 run dummy_composed_service dummy_composed_service
```

I set `ROS_LOG_DIR` to `/storage` to make sure that the logs are written
to a persistent storage on the target device. Otherwise, it will take
the ROS_HOME env variable value which is likelly lead to service failure
due to the read-only filesystem on the target device.
