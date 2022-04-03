CROSS_COMPILE='riscv64-linux-gnu-'
ARCH='riscv'
PWD=`pwd`

ROOT_FS='archriscv-20210601.tar.zst'
ROOT_FS_DL="https://archriscv.felixc.at/images/${ROOT_FS}"

# folder to mount rootfs
MNT='mnt'
# folder to store compiled artifacts
OUT_DIR=${PWD}/output

# run as root
SUDO='sudo'

# use arch-chroot?
USE_CHROOT=1

# pinned commits (no notice when things change)
COMMIT_BOOT0='0ad88bfdb723b1ac74cca96122918f885a4781ac' # from 28.02.2022
COMMIT_UBOOT='7446a47204fd8923b99ced0091667979c4fd27fa' # equals d1-wip (06.04.2022)
COMMIT_KERNEL='cc63db754b218d3ef9b529a82e04b66252e9bca1' # equals riscv/d1-wip (06.04.2022)
KERNEL_RELEASE='5.18.0-rc1-gcc63db754b21' # must match commit!
# use this (set to something != '') to override the check
IGNORE_COMMITS=0


function check_deps() {
    pacman -Qi ${1} > /dev/null

    if [ ${?} -ne 0 ] ; then
        echo "Please install '${1}'"
        exit -1
    fi
}