# Fix QA file-rdeps errors: shared libraries installed by this package link to
# these runtime libs, so they must appear in RDEPENDS.
ROS_EXEC_DEPENDS += " \
    fastcdr \
    libpython3 \
    rcutils \
    rosidl-runtime-c \
    rosidl-typesupport-c \
    rosidl-typesupport-cpp \
    rosidl-typesupport-fastrtps-c \
    rosidl-typesupport-fastrtps-cpp \
    rosidl-typesupport-introspection-c \
    rosidl-typesupport-introspection-cpp \
"
