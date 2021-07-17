#!/bin/bash
echo
echo "Installing git server utilities..."
echo

git pull

./install-packages.sh

# ufw defaults
sudo ufw default deny incoming
sudo ufw default allow outgoing

# NOTE: Uncomment below lines to enable
# some permissive firewall rules if you
# want. Otherwise firewall is off by
# default.
#sudo ufw allow 22/tcp   # allow ssh
#sudo ufw allow 1234/tcp # allow git instaweb lighttpd
#sudo ufw --force enable

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

cd ..

# Installing GitCid CI/CD

source <(curl -sL https://tinyurl.com/gitcid)
.gc/new-remote.sh ~/git/repo1.git
cd ~/git/repo1.git
git instaweb
cd ~

git clone ~/git/repo1.git
cd ~/git/repo1
source <(curl -sL https://tinyurl.com/gitcid) -e
git remote -v

echo
echo "git server utilities installed"
echo
echo "done"

