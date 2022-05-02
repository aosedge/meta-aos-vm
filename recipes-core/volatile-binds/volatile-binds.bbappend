VOLATILE_BINDS += "\
    /var/machine-id /etc/machine-id\n\
"

do_compile_append() {
    if [ -e var-machine-id.service ]; then
        # machine-id should be mounted before journald for proper configuration
        sed -i -e "/^Before=/s/\$/ systemd-journald.service/" \
               var-machine-id.service
    fi
}
