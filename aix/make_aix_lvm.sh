#!/usr/bin/env sh
#
# Create and mount two logical volumes for Salt development
#

vg=rootvg

for newlv in freeware salt; do
    # Make logical volume for log
    echo "Making jfs2log volume for logical volume '$newlv'"
    loglvname=`mklv -t jfs2log $vg 1` || exit 1
    # Make logical volume
    echo "Making jfs2 volume for logical volume '$newlv'"
    ## dgm mklv -t jfs2 -y $newlv $vg 10G || exit 1
    mklv -t jfs2 -y $newlv $vg 6G || exit 1
    # Format logical volume
    echo "Formatting jfs2 volume for logical volume '$newlv'"
    yes | mkfs -o log=/dev/$loglvname -V jfs2 /dev/$newlv || exit 1
    # Backup existing /opt/freeware
    if test "$newlv" == "freeware"; then
        echo "Backing up existing /opt/freeware"
        mv /opt/freeware /opt/freeware.bak || exit 1
    fi
    # Make mountpoint
    echo "Creating mountpoint /opt/$newlv for logical volume '$newlv'"
    mkdir /opt/$newlv || exit 1
    # Mount the new LV
    echo "Mounting logical volume '$newlv' to /opt/$newlv"
    mount -o log=/dev/$loglvname /dev/$newlv /opt/$newlv || exit 1
    # Relocate all the files from the /opt/freeware backup into new LV
    if test "$newlv" == "freeware"; then
        echo "Relocate files from /opt/freeware backup to new /opt/freeware"
        mv /opt/freeware.bak/* /opt/freeware/ || exit 1
        echo "Cleaning up old /opt/freeware"
        rm -rf /opt/freeware.bak || exit 1
    fi
done
