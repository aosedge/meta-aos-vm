
python do_update_hosts() {
    hostnames = d.getVar("HOSTNAMES")
    hosts = hostnames.split(";")

    file_name_dest = oe.path.join(d.getVar("D"), d.getVar("sysconfdir"), "hosts")

    if len(hosts) < 1:
        return

    with open(file_name_dest, "a") as f:
        for host in hosts:
            print(host, file=f) 
}

addtask update_hosts after do_install before do_package
