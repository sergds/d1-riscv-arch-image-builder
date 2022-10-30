#!/usr/bin/sh
export CROSS_COMPILE='riscv64-linux-gnu-'
export ARCH='riscv'
PWD="$(pwd)"
NPROC="$(nproc)"
export PWD
export NPROC

export ROOT_FS='archriscv-20210601.tar.zst'
export ROOT_FS_DL="https://archriscv.felixc.at/images/${ROOT_FS}"

# select 'arch', 'nezha_defconfig'
export KERNEL='nezha_defconfig'

# Device Tree:
# In the current pinned U-Boot Commit the following device trees are available
# for the D1:
# u-boot/arch/riscv/dts/sun20i-d1-lichee-rv-86-panel.dtb
# u-boot/arch/riscv/dts/sun20i-d1-lichee-rv-dock.dtb
# u-boot/arch/riscv/dts/sun20i-d1-lichee-rv.dtb
# u-boot/arch/riscv/dts/sun20i-d1-nezha.dtb
export DTB=u-boot/arch/riscv/dts/sun20i-d1-lichee-rv-dock.dtb

# folder to mount rootfs
export MNT='mnt'
# folder to store compiled artifacts
export OUT_DIR="${PWD}/output"

# run as root
export SUDO='sudo'

# use arch-chroot?
export USE_CHROOT=1

# use extlinux ('extlinux'), boot.scr ('script') or EFI 'efi' (broken) for loading the kernel?
export BOOT_METHOD='extlinux'

# pinned commits (no notice when things change)
export SOURCE_BOOT0='https://github.com/smaeul/sun20i_d1_spl'
export SOURCE_OPENSBI='https://github.com/smaeul/opensbi'
export SOURCE_UBOOT='https://github.com/smaeul/u-boot'
export SOURCE_KERNEL='https://github.com/smaeul/linux'
# https://github.com/karabek/xradio

export COMMIT_BOOT0='882671fcf53137aaafc3a94fa32e682cb7b921f1' # from 14.06.2022
export COMMIT_UBOOT='afc07cec423f17ebb4448a19435292ddacf19c9b' # equals d1-wip (28.05.2022)
# export COMMIT_KERNEL='fe178cf0153d98b71cb01a46c8cc050826a17e77' # equals riscv/d1-wip head
# export KERNEL_TAG='riscv/d1-wip'
# export COMMIT_KERNEL='673a7faa146862c6ba7b0253a5ff22b07de0e0a9' # equals d1/wip head (12.08.2022)
# export KERNEL_TAG='d1/wip'
export COMMIT_KERNEL='cc63db754b218d3ef9b529a82e04b66252e9bca1' # equals tag d1-wip-v5.18-rc1
export KERNEL_TAG='d1-wip-v5.18-rc1'
# use this (set to something != 0) to override the check
export IGNORE_COMMITS=0
export DEBUG='n'

check_deps() {
    if ! pacman -Qi "${1}" > /dev/null ; then
        echo "Please install '${1}'"
        exit 1
    fi
}

