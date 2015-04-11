#!/bin/bash

echo building video drivers for vm ware

readonly TOP=$PWD

if [[ ! -d $TOP/drm ]] || \
   [[ ! -d $TOP/mesa ]] || \
   [[ ! -d $TOP/xf86-video-vmware ]] || \
   [[ ! -d $TOP/vmwgfx ]] ; then
    
    echo 'git submodules not found' 1>&2
    echo "did you run 'git submodule update --recursive --init' ? " 1>&2
    exit 1
fi

function build_drm {
    cd $TOP/drm
    ./autogen.sh --prefix=/usr \
                 --libdir=/usr/lib64
    make
}

function install_drm {
    cd $TOP/drm
    sudo make install
}

function build_mesa {
    cd $TOP/mesa
    ./autogen.sh --prefix=/usr \
                 --libdir=/usr/lib64 \
                 --with-gallium-drivers=svga \
                 --with-dri-drivers= \
                 --enable-xa \
                 --disable-dri3
    make
}

function install_mesa {
    cd $TOP/mesa
    sudo make install
}

function build_xf86-video-vmware {
    cd $TOP/xf86-video-vmware
    ./autogen.sh --prefix=/usr \
                 --libdir=/usr/lib64

    make
}

function install_xf86-video-vmware {
    cd $TOP/xf86-video-vmware
    sudo make install
}

function build_vmwgfx {
    cd $TOP/vmwgfx
    ./autogen.sh
    make
}

function install_vmwgfx {
    cd $TOP/vmwgfx
    sudo rm /lib/modules/`uname -r`/kernel/drivers/gpu/drm/vmwgfx.ko*
    sudo make install

    sudo cp 00-vmwgfx.rules /etc/udev/rules.d
    sudo depmod -ae
    sudo depmod -ae
}

build_drm
install_drm

build_mesa
install_mesa

build_xf86-video-vmware
install_xf86-video-vmware

build_vmwgfx
install_vmwgfx
