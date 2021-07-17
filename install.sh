#!/bin/sh
echo
echo "Installing git server utilities..."
echo

./install-packages.sh

echo
echo "Installing usb-mount..."

if [ ! -d "usb-mount" ]; then
	git clone https://gitlab.com/defcronyke/usb-mount.git
fi

cd usb-mount
git pull
./install-usb-mount.sh && \
echo "usb-mount installed"
cd ..

# Add symlink: ~/git -> ~/mnt -> /media
ln -s $HOME/mnt $HOME/git 2>/dev/null

echo
echo "git server utilities installed"
echo
echo "done"

