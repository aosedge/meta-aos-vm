# set proper systemd tmpfiles config
EXTRA_OECONF += "--with-tmpfilesdir=${exec_prefix}/lib/tmpfiles.d"
