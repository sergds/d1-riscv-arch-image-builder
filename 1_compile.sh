#!/usr/bin/sh

set -e
# set -x

source ./consts.sh

function clean_dir() {
    _DIR=${1}

    # kind of dangerous ...
    [ "${_DIR}" == '/' ] && extit -1
    rm -rf ${_DIR} || true
}

function pin_commit() {
    _COMMIT=${1}

    pushd ${2}
    _COMMIT_IS=`git rev-parse HEAD`
    popd

    [ "${IGNORE_COMMITS}" != '0' ] || [ ${_COMMIT} == ${_COMMIT_IS} ]
}

for DEP in riscv64-linux-gnu-gcc swig ; do
    check_deps ${DEP}
done

mkdir -p build
mkdir -p ${OUT_DIR}
cd build

if [ ! -f "${OUT_DIR}/boot0_sdcard_sun20iw1p1.bin" ] ; then
    # build Boot0
    DIR='sun20i_d1_spl'
    clean_dir ${DIR}

    git clone https://github.com/smaeul/sun20i_d1_spl
    cd ${DIR}
    git checkout ${COMMIT_BOOT0}
    make CROSS_COMPILE=${CROSS_COMPILE} p=sun20iw1p1 mmc
    cd ..
    cp ${DIR}/nboot/boot0_sdcard_sun20iw1p1.bin ${OUT_DIR}
fi

if [ ! -f "${OUT_DIR}/u-boot.toc1" ] ; then
    # build OpenSBI
    DIR='opensbi'
    clean_dir ${DIR}

    git clone https://github.com/smaeul/opensbi
    cd ${DIR}
    git checkout d1-wip
    make CROSS_COMPILE=${CROSS_COMPILE} PLATFORM=generic FW_PIC=y FW_OPTIONS=0x2
    cd ..
    # cp opensbi/build/platform/generic/firmware/fw_dynamic.bin ${OUT_DIR}

    # build U-Boot
    DIR='u-boot'
    clean_dir ${DIR}

    git clone https://github.com/smaeul/u-boot.git
    cd ${DIR}
    git checkout d1-wip
    pin_commit ${COMMIT_UBOOT} . || exit -1

    make CROSS_COMPILE=${CROSS_COMPILE} ARCH=${ARCH} nezha_defconfig
    # make CROSS_COMPILE=${CROSS_COMPILE} ARCH=${ARCH} lichee_rv_defconfig
    make CROSS_COMPILE=${CROSS_COMPILE} ARCH=${ARCH} -j `nproc`
    cd ..
    # cp u-boot/arch/riscv/dts/sun20i-d1-lichee-rv-dock.dtb ${OUT_DIR}

    # build u-boot toc
    cat << EOF > licheerv_toc1.cfg
[opensbi]
file = opensbi/build/platform/generic/firmware/fw_dynamic.bin
addr = 0x40000000
[dtb]
file = u-boot/arch/riscv/dts/sun20i-d1-lichee-rv-dock.dtb
addr = 0x44000000
[u-boot]
file = u-boot/u-boot-nodtb.bin
addr = 0x4a000000
EOF
    ${DIR}/tools/mkimage -T sunxi_toc1 -d licheerv_toc1.cfg u-boot.toc1
    cp u-boot.toc1 ${OUT_DIR}
fi

if [ ! -f "${OUT_DIR}/boot.scr" ] ; then
    DIR='u-boot'

    # https://andreas.welcomes-you.com/boot-sw-debian-risc-v-lichee-rv/
    cat << 'EOF' > bootscr.txt
setenv bootargs earlycon=sbi console=ttyS0,115200n8 root=/dev/mmcblk0p2
echo "Loading kernel from mmc 0:1 to address ${kernel_addr_r}"
load mmc 0:1 ${kernel_addr_r} Image
echo "Booting kernel with bootargs as $bootargs; and fdtcontroladdr is $fdtcontroladdr"
booti ${kernel_addr_r} - ${fdtcontroladdr}
EOF
    ${DIR}/tools/mkimage -T script -C none -O linux -A ${ARCH} -d bootscr.txt boot.scr
    rm bootscr.txt
    cp boot.scr ${OUT_DIR}
fi

if [ ! -f "${OUT_DIR}/Image" ] || [ ! -f "${OUT_DIR}/Image.gz" ] ; then
    # TODO use archlinux-riscv kernel

    # build kernel
    DIR='linux'
    clean_dir ${DIR}
    clean_dir ${DIR}-build

    # try not to clone complete linux source tree here!
    git clone --depth 1 https://github.com/smaeul/linux -b riscv/d1-wip
    pin_commit ${COMMIT_KERNEL} ${DIR} || exit -1

    # mkdir -p linux-build/arch/riscv/configs
    # cp ../licheerv_linux_defconfig linux-build/arch/riscv/configs/licheerv_defconfig
    # make ARCH=${ARCH} -C linux O=../linux-build licheerv_defconfig
    make ARCH=${ARCH} -C linux O=../linux-build nezha_defconfig

    make CROSS_COMPILE=${CROSS_COMPILE} ARCH=${ARCH} -j `nproc` -C linux-build
    cp linux-build/arch/riscv/boot/Image.gz ${OUT_DIR}
    cp linux-build/arch/riscv/boot/Image ${OUT_DIR}
fi

# if [ ! -f "${OUT_DIR}/8723ds.ko" ] ; then
#     # build WiFi driver
#     DIR='rtl8723ds'
#     clean_dir ${DIR}

#     git clone https://github.com/lwfinger/rtl8723ds.git
#     cd ${DIR}
#     make CROSS_COMPILE=${CROSS_COMPILE} ARCH=${ARCH} KSRC=../linux-build -j `nproc`  modules
#     cd ..
#     cp ${DIR}/8723ds.ko ${OUT_DIR}
# fi
