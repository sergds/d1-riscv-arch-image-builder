FROM ghcr.io/greyltc-org/archlinux-aur

WORKDIR /home/runner/work/riscv-arch-image-builder/riscv-arch-image-builder

ADD 1_compile.sh 1_compile.sh
ADD 2_create_sd.sh 2_create_sd.sh
ADD consts.sh consts.sh
ADD licheerv_linux_defconfig licheerv_linux_defconfig
ADD upload_kernel.sh upload_kernel.sh
# ADD mirrorlist /etc/pacman.d/mirrorlist

RUN pacman-key --init 
RUN pacman-key --populate archlinux
RUN pacman -Syyu --noconfirm riscv64-linux-gnu-gcc swig cpio python3 python-setuptools base-devel bc git arch-install-scripts parted
RUN aur-install qemu-user-static-bin binfmt-qemu-static

RUN sh 1_compile.sh output
# RUN dd if=/dev/zero of=./archlinux_riscv.img bs=1M count=1500
# RUN losetup /dev/loop17 archlinux_riscv.img
# RUN sh 2_create_sd.sh /dev/loop17

CMD ["./2_create_sd.sh", "/dev/loop17"]
