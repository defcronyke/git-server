#!/bin/bash
echo
echo "Installing git server utilities..."
echo

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

sudo mkdir -p $HOME/git/local
sudo chown $USER: $HOME/git/local
chmod 770 $HOME/git/local

# Install GitCid CI/CD
if [ ! -d "gitcid" ]; then
	source <(curl -sL https://tinyurl.com/gitcid)
else
	cd gitcid
	git pull
fi

# Make a new GitCid git remote (a.k.a. "bare" git repo)
if [ ! -d "$HOME/git/local/repo1.git" ]; then
	.gc/new-remote.sh ~/git/local/repo1.git

	# copy it to an external "~/git/disk1" if mounted as well
	cp -r ~/git/local/repo1.git ~/git/disk1/repo1.git || true
fi

echo
cd ~

if [ ! -d "$HOME/repo1" ]; then
	git clone ~/git/disk1/repo1.git || \
	git clone ~/git/local/repo1.git
	cd ~/repo1
	source <(curl -sL https://tinyurl.com/gitcid) -e
else
	cd ~/repo1
	git pull
fi

git remote -v

# Start git instaweb: http://localhost:1234
echo
echo "Starting git instaweb..."
# Try removable disk1 first, fallback to local disk.
cd ~/git/disk1/repo1.git || \
cd ~/git/local/repo1.git
GIT_DISCOVERY_ACROSS_FILESYSTEM=1 git instaweb 2>/dev/null

if [ $? -ne 0 ]; then
        echo
        echo "Restarting git instaweb because it was already running..."
        echo
        git instaweb --stop
        sudo killall lighttpd
        GIT_DISCOVERY_ACROSS_FILESYSTEM=1 git instaweb
fi

cd ~

echo
echo "git server utilities installed"
echo
echo "done"

