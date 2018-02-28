#!/bin/bash

set -o errexit

usage() {
    echo """
    Usage:

       docker run \\
           --tty \\
           --interactive \\
           --rm \\
           --volume /var/run/libvirt/libvirt-sock:/var/run/libvirt/libvirt-sock \\
           --volume \${HOME}/.boxes:${VAGRANT_HOME}/boxes \\
           --volume \$(pwd):/home/${user}/project \\
           kitchen {command}

        Commands:
          shell   start interactive shell
          *       run \`kitchen \$*\` inside /home/${user}/project
    """
}

main () {
    [ ! -e "/var/run/libvirt/libvirt-sock" ] && usage && exit 0
    [ "$(stat --format %u /home/${user}/project)" -eq 0 ] && usage && exit 0
    [ -z "$1" ] && usage && exit 0

    local uid gid newUID newGID lgid exitStatus

    uid=$(stat --format %u /home/${user})
    gid=$(stat --format %g /home/${user})
    newUID=$(stat --format %u /home/${user}/project)
    newGID=$(stat --format %g /home/${user}/project)
    lgid=$(stat --format %g /var/run/libvirt/libvirt-sock)
    exitStatus=0

    groupadd -g ${lgid} libvirtd
    usermod -a -G libvirtd ${user}

    echo "export VAGRANT_HOME=${VAGRANT_HOME}" >> /home/${user}/.profile
    echo "export VAGRANT_DEFAULT_PROVIDER=libvirt" >> /home/${user}/.profile

    if [ "${uid}" != "${newUID}" ] ; then
        usermod -u ${newUID} ${user}
        find /home -user ${uid} -exec chown -h ${newUID} {} \;
    fi

    if [ "${gid}" != "${newGID}" ] ; then
        groupmod -g ${newGID} ${user}
        find /home -group ${gid} -exec chgrp -h ${newGID} {} \;
    fi

    case "$1" in
        shell)
          su -l ${user} -s /bin/bash --login
          ;;
        *)
          su -l ${user} -c "cd /home/${user}/project; kitchen ${*}" || exitStatus=1
          ;;
    esac

    exit ${exitStatus}
}

main "$@"
