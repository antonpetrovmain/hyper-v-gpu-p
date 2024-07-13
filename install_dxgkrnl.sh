#!/bin/bash -e

# You can also try with the latest version available:
BRANCH=linux-msft-wsl-6.6.y

if [ "$EUID" -ne 0 ]; then
    echo "Swithing to root..."
    exec sudo $0 "$@"
fi

apt-get install -y git dkms

git clone -b $BRANCH --depth=1 https://github.com/microsoft/WSL2-Linux-Kernel
cd WSL2-Linux-Kernel
VERSION=$(git rev-parse --short HEAD)

cp -r drivers/hv/dxgkrnl /usr/src/dxgkrnl-$VERSION
mkdir -p /usr/src/dxgkrnl-$VERSION/inc/{uapi/misc,linux}
cp include/uapi/misc/d3dkmthk.h /usr/src/dxgkrnl-$VERSION/inc/uapi/misc/d3dkmthk.h
cp include/linux/hyperv.h /usr/src/dxgkrnl-$VERSION/inc/linux/hyperv_dxgkrnl.h
## TODO can I include a newer header for that eventfd interface change and make the script use that one instead of the one from my kernel? Or should I do it the other way around? 
sed -i 's/\$(CONFIG_DXGKRNL)/m/' /usr/src/dxgkrnl-$VERSION/Makefile
sed -i 's#linux/hyperv.h#linux/hyperv_dxgkrnl.h#' /usr/src/dxgkrnl-$VERSION/dxgmodule.c
echo "EXTRA_CFLAGS=-I\$(PWD)/inc" >> /usr/src/dxgkrnl-$VERSION/Makefile

cat > /usr/src/dxgkrnl-$VERSION/dkms.conf <<EOF
PACKAGE_NAME="dxgkrnl"
PACKAGE_VERSION="$VERSION"
BUILT_MODULE_NAME="dxgkrnl"
DEST_MODULE_LOCATION="/kernel/drivers/hv/dxgkrnl/"
AUTOINSTALL="yes"
EOF

dkms add dxgkrnl/$VERSION
dkms build dxgkrnl/$VERSION
dkms install dxgkrnl/$VERSION
