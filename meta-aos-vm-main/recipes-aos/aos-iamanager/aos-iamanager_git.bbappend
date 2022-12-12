FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

AOS_IAM_IDENT_MODULES = " \
    identhandler/modules/visidentifier \
"

python do_update_config_append() {
    # Add remote IAM's configuration

    data["RemoteIams"] = []

    for node in d.getVar("NODE_LIST").split():
        if node != d.getVar("NODE_ID"):
            data["RemoteIams"].append({"NodeID": node, "URL": node+":8089"})

    with open(file_name, "w") as f:
        json.dump(data, f, indent=4)
}

