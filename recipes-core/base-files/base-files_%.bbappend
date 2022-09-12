FILESEXTRAPATHS_append := "${THISDIR}/base-files:"

do_install_append() {
   echo '/dev/aosvg/downloads /var/aos/downloads ext4 defaults,nofail,noatime,x-systemd.device-timeout=5s'\
${@bb.utils.contains('DISTRO_FEATURES', 'selinux', ',context=system_u:object_r:aos_var_run_t:s0', '', d)} '0 0' \
   >> ${D}/${sysconfdir}/fstab

   echo '/dev/aosvg/workdirs  /var/aos/workdirs   ext4 defaults,nofail,noatime,x-systemd.device-timeout=5s'\
${@bb.utils.contains('DISTRO_FEATURES', 'selinux', ',context=system_u:object_r:aos_var_run_t:s0', '', d)} '0 0' \
   >> ${D}/${sysconfdir}/fstab

   echo '/dev/aosvg/storages /var/aos/storages ext4 ' \
'defaults,nofail,noatime,usrjquota=aquota.user,jqfmt=vfsv0,x-systemd.device-timeout=5s'\
${@bb.utils.contains('DISTRO_FEATURES', 'selinux', ',context=system_u:object_r:aos_var_run_t:s0', '', d)} '0 0' \
   >> ${D}/${sysconfdir}/fstab

   echo '/dev/aosvg/states /var/aos/states ext4 ' \
'defaults,nofail,noatime,usrjquota=aquota.user,jqfmt=vfsv0,x-systemd.device-timeout=5s'\
${@bb.utils.contains('DISTRO_FEATURES', 'selinux', ',context=system_u:object_r:aos_var_run_t:s0', '', d)} '0 0' \
   >> ${D}/${sysconfdir}/fstab
}
