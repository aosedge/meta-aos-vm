FILESEXTRAPATHS:prepend := "${THISDIR}/refpolicy:"

PV = "2.20210203+git${SRCPV}"

SRC_URI = "git://github.com/SELinuxProject/refpolicy.git;protocol=https;branch=master;name=refpolicy;destsuffix=refpolicy"

SRCREV_refpolicy = "1167739da1882f9c89281095d2595da5ea2d9d6b"

SRC_URI += "file://customizable_types  \
	    file://setrans-mls.conf  \
	    file://setrans-mcs.conf  \
	   "

SRC_URI += " \
        file://0001-fc-subs-volatile-alias-common-var-volatile-paths.patch \
        file://0002-fc-subs-busybox-set-aliases-for-bin-sbin-and-usr.patch \
        file://0003-fc-hostname-apply-policy-to-common-yocto-hostname-al.patch \
        file://0004-fc-bash-apply-usr-bin-bash-context-to-bin-bash.bash.patch \
        file://0005-fc-resolv.conf-label-resolv.conf-in-var-run-properly.patch \
        file://0006-fc-login-apply-login-context-to-login.shadow.patch \
        file://0007-fc-bind-fix-real-path-for-bind.patch \
        file://0008-fc-hwclock-add-hwclock-alternatives.patch \
        file://0009-fc-dmesg-apply-policy-to-dmesg-alternatives.patch \
        file://0010-fc-ssh-apply-policy-to-ssh-alternatives.patch \
        file://0011-fc-sysnetwork-apply-policy-to-ip-alternatives.patch \
        file://0012-fc-udev-apply-policy-to-udevadm-in-libexec.patch \
        file://0013-fc-rpm-apply-rpm_exec-policy-to-cpio-binaries.patch \
        file://0014-fc-su-apply-policy-to-su-alternatives.patch \
        file://0015-fc-fstools-fix-real-path-for-fstools.patch \
        file://0016-fc-init-fix-update-alternatives-for-sysvinit.patch \
        file://0017-fc-brctl-apply-policy-to-brctl-alternatives.patch \
        file://0018-fc-corecommands-apply-policy-to-nologin-alternatives.patch \
        file://0019-fc-locallogin-apply-policy-to-sulogin-alternatives.patch \
        file://0020-fc-ntp-apply-policy-to-ntpd-alternatives.patch \
        file://0021-fc-kerberos-apply-policy-to-kerberos-alternatives.patch \
        file://0022-fc-ldap-apply-policy-to-ldap-alternatives.patch \
        file://0023-fc-postgresql-apply-policy-to-postgresql-alternative.patch \
        file://0024-fc-screen-apply-policy-to-screen-alternatives.patch \
        file://0025-fc-usermanage-apply-policy-to-usermanage-alternative.patch \
        file://0026-fc-getty-add-file-context-to-start_getty.patch \
        file://0027-fc-init-add-file-context-to-etc-network-if-files.patch \
        file://0028-fc-vlock-apply-policy-to-vlock-alternatives.patch \
        file://0029-fc-cron-apply-policy-to-etc-init.d-crond.patch \
        file://0030-fc-sysnetwork-update-file-context-for-ifconfig.patch \
        file://0031-file_contexts.subs_dist-set-aliase-for-root-director.patch \
        file://0032-policy-modules-system-logging-add-rules-for-the-syml.patch \
        file://0033-policy-modules-system-logging-add-rules-for-syslogd-.patch \
        file://0034-policy-modules-kernel-files-add-rules-for-the-symlin.patch \
        file://0035-policy-modules-system-logging-fix-auditd-startup-fai.patch \
        file://0036-policy-modules-kernel-terminal-don-t-audit-tty_devic.patch \
        file://0037-policy-modules-system-modutils-allow-mod_t-to-access.patch \
        file://0038-policy-modules-services-avahi-allow-avahi_t-to-watch.patch \
        file://0039-policy-modules-system-getty-allow-getty_t-to-search-.patch \
        file://0040-policy-modules-services-bluetooth-fix-bluetoothd-sta.patch \
        file://0041-policy-modules-roles-sysadm-allow-sysadm-to-run-rpci.patch \
        file://0042-policy-modules-services-rpc-add-capability-dac_read_.patch \
        file://0043-policy-modules-services-rpcbind-allow-rpcbind_t-to-c.patch \
        file://0044-policy-modules-services-rngd-fix-security-context-fo.patch \
        file://0045-policy-modules-services-ssh-allow-ssh_keygen_t-to-re.patch \
        file://0046-policy-modules-services-ssh-make-respective-init-scr.patch \
        file://0047-policy-modules-kernel-terminal-allow-loging-to-reset.patch \
        file://0048-policy-modules-system-selinuxutil-allow-semanage_t-t.patch \
        file://0049-policy-modules-system-systemd-enable-support-for-sys.patch \
        file://0050-policy-modules-system-systemd-fix-systemd-resolved-s.patch \
        file://0051-policy-modules-system-init-add-capability2-bpf-and-p.patch \
        file://0052-policy-modules-system-systemd-allow-systemd_logind_t.patch \
        file://0053-policy-modules-system-logging-set-label-devlog_t-to-.patch \
        file://0054-policy-modules-system-systemd-support-systemd-user.patch \
        file://0055-policy-modules-system-systemd-allow-systemd-generato.patch \
        file://0056-policy-modules-system-systemd-allow-systemd_backligh.patch \
        file://0057-policy-modules-system-logging-fix-systemd-journald-s.patch \
        file://0058-policy-modules-services-cron-allow-crond_t-to-search.patch \
        file://0059-policy-modules-services-crontab-allow-sysadm_r-to-ru.patch \
        file://0060-policy-modules-system-sysnetwork-support-priviledge-.patch \
        file://0061-policy-modules-services-acpi-allow-acpid-to-watch-th.patch \
        file://0062-policy-modules-system-setrans-allow-setrans-to-acces.patch \
        file://0063-policy-modules-system-modutils-allow-kmod_t-to-write.patch \
        file://0064-policy-modules-roles-sysadm-allow-sysadm_t-to-watch-.patch \
        file://0065-policy-modules-system-selinux-allow-setfiles_t-to-re.patch \
        file://0066-policy-modules-system-mount-make-mount_t-domain-MLS-.patch \
        file://0067-policy-modules-roles-sysadm-MLS-sysadm-rw-to-clearan.patch \
        file://0068-policy-modules-services-rpc-make-nfsd_t-domain-MLS-t.patch \
        file://0069-policy-modules-admin-dmesg-make-dmesg_t-MLS-trusted-.patch \
        file://0070-policy-modules-kernel-kernel-make-kernel_t-MLS-trust.patch \
        file://0071-policy-modules-system-init-make-init_t-MLS-trusted-f.patch \
        file://0072-policy-modules-system-systemd-make-systemd-tmpfiles_.patch \
        file://0073-policy-modules-system-logging-add-the-syslogd_t-to-t.patch \
        file://0074-policy-modules-system-init-make-init_t-MLS-trusted-f.patch \
        file://0075-policy-modules-system-init-all-init_t-to-read-any-le.patch \
        file://0076-policy-modules-system-logging-allow-auditd_t-to-writ.patch \
        file://0077-policy-modules-kernel-kernel-make-kernel_t-MLS-trust.patch \
        file://0078-policy-modules-system-systemd-make-systemd-logind-do.patch \
        file://0079-policy-modules-system-systemd-systemd-user-sessions-.patch \
        file://0080-policy-modules-system-systemd-systemd-make-systemd_-.patch \
        file://0081-policy-modules-services-ntp-make-nptd_t-MLS-trusted-.patch \
        file://0082-policy-modules-system-setrans-allow-setrans_t-use-fd.patch \
        file://0083-policy-modules-services-acpi-make-acpid_t-domain-MLS.patch \
        file://0084-policy-modules-services-avahi-make-avahi_t-MLS-trust.patch \
        file://0085-policy-modules-services-bluetooth-make-bluetooth_t-d.patch \
        file://0086-policy-modules-system-sysnetwork-make-dhcpc_t-domain.patch \
        file://0087-policy-modules-services-inetd-make-inetd_t-domain-ML.patch \
        file://0088-policy-modules-services-bind-make-named_t-domain-MLS.patch \
        file://0089-policy-modules-services-rpc-make-rpcd_t-MLS-trusted-.patch \
        file://0090-policy-modules-system-systemd-make-_systemd_t-MLS-tr.patch \
        file://0091-fc-usermanage-update-file-context-for-chfn-chsh.patch \
"
