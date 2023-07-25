FROM ghcr.io/greyltc-org/archlinux-aur

WORKDIR /home/runner/work/d1-riscv-arch-image-builder/d1-riscv-arch-image-builder

ADD 1_compile.sh 1_compile.sh
ADD 2_create_sd.sh 2_create_sd.sh
ADD consts.sh consts.sh

RUN pacman-key --init 
RUN pacman-key --populate archlinux
RUN pacman -Syyu --noconfirm --needed riscv64-linux-gnu-gcc swig cpio python3 python-setuptools base-devel bc git arch-install-scripts parted
RUN aur-install qemu-user-static qemu-user-static-binfmt

CMD ["sh", "1_compile.sh"]
