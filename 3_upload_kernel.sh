#!/usr/bin/sh

set -e
# set -x

. ./consts.sh

if [ -z "$1" ]; then
    echo "Usage: $0 user@host"
    exit 1
fi

SSH_TARGET="$1"

SSH="ssh $SSH_TARGET"

if [ ! -f output/Image ] || [ ! -f output/8723ds.ko ]; then
    echo "run ./1_compile.sh first"
    exit 1
fi

# get kernel release
cd build/linux-build
KERNEL_RELEASE=$(make ARCH="${ARCH}" -s kernelversion)
cd ../..
MODULES="/usr/lib/modules/$KERNEL_RELEASE"
if [ ! -d "$MNT/$MODULES" ]; then
    echo "mount the flashed SD card to $MNT"
    exit 1
fi

# make remote temp folder
tmpfile=$($SSH mktemp -d arch-image-builder.XXXXXX)

# copy files
echo "copying files..."
scp "$OUT_DIR"/Image "$OUT_DIR"/8723ds.ko "$SSH_TARGET":"$tmpfile"
scp -r "$MNT/$MODULES" "$SSH_TARGET":"$tmpfile"

# write install script
echo "writing install.sh..."
$SSH sh -c "cat <<EOF > "$tmpfile"/install.sh
#!/usr/bin/sh

set -e
set -x

# backup kernel
if [ -f /boot/Image ] ; then
    if [ -f /boot/Image.old ] ; then
        rm /boot/Image.old
    fi
    mv /boot/Image /boot/Image.old
fi

# backup modules
if [ -d "$MODULES" ] ; then
    if [ -d "$MODULES".old ] ; then
        rm -r "$MODULES".old
    fi
    mv "$MODULES" "$MODULES".old
fi

# copy modules
mv "$KERNEL_RELEASE" /usr/lib/modules
mv 8723ds.ko /usr/lib/modules/"$KERNEL_RELEASE"/kernel/drivers/net/wireless/8723ds.ko

# copy kernel
mv Image /boot

# depmod
depmod -v
EOF"

# run install script
echo "running install.sh on ${SSH_TARGET}..."
ssh -t "$SSH_TARGET" "cd $tmpfile; pwd; sudo sh ./install.sh"

# clean up
$SSH rm -r "$tmpfile"
