# /bin/bash
dd if=/dev/zero of=./archlinux_riscv.img bs=1M count=2048
sudo losetup /dev/loop17 ./archlinux_riscv.img
docker run --name build_riscv riscv-arch-image:${1}
docker cp build_riscv:/home/runner/work/riscv-arch-image-builder/riscv-arch-image-builder ../
pwd
ls
ls ..
sudo CI_BUILD=1 ./2_create_sd.sh /dev/loop17
tar -zcvf archlinux_riscv.img.tar.gz archlinux_riscv.img
