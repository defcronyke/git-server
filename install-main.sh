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
echo "Installing usb-mount-git..."

if [ ! -d "usb-mount-git" ]; then
	git clone https://gitlab.com/defcronyke/usb-mount-git.git
fi

current_dir="$PWD"
cd usb-mount-git
git pull
./install-usb-mount-git.sh && \
echo "usb-mount-git installed"
cd ..

sudo mkdir -p /opt/git
sudo chown $USER: /opt/git
chmod 770 /opt/git

# Add symlink: ~/git -> /opt/git
ln -s /opt/git $HOME/git 2>/dev/null || true

cd $HOME/git
git init
echo '*' | tee .gitignore
git add .
git commit -m "Initial commit"
cd "$current_dir"

sudo mkdir -p /media/local
sudo chown $USER: /media/local
chmod 770 /media/local

# Install GitCid CI/CD
if [ ! -d "gitcid" ]; then
	source <(curl -sL https://tinyurl.com/gitcid)
else
	cd gitcid
	git pull
fi

# Make a new GitCid git remote (a.k.a. "bare" git repo)
if [ ! -d "/media/local/repo1.git" ]; then
	.gc/new-remote.sh /media/local/repo1.git
fi

echo
cd ~

if [ ! -d "$HOME/repo1" ]; then
	git clone /media/local/repo1.git
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
cd ~/git
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

