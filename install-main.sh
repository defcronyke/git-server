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

# Respond to broadcast pings for current DNS discovery protocol (subject to change)
sudo cat /etc/sysctl.conf | grep "net.ipv4.icmp_echo_ignore_broadcasts = 0"
if [ $? -ne 0 ]; then
	echo
	echo "Enabling broadcast ping response for DNS discovery..."
	echo "net.ipv4.icmp_echo_ignore_broadcasts = 0" | sudo tee -a /etc/sysctl.conf
	sudo sysctl --system
	echo "broadcast ping response enabled"
	echo
else
	echo
	echo "info: broadcast ping response is already enabled, not enabling it again"
	echo
fi

echo
echo "Installing usb-mount-git..."

current_dir="$PWD"

if [ ! -d "usb-mount-git" ]; then
	git clone https://gitlab.com/defcronyke/usb-mount-git.git
	cd usb-mount-git
else
	cd usb-mount-git
	git pull
fi

./install-usb-mount-git.sh && \
echo "usb-mount-git installed"
cd ..

sudo mkdir -p /opt/git
sudo chown $USER: /opt/git
chmod 770 /opt/git

# Add symlink: ~/git -> /opt/git
if [ ! -d "$HOME/git" ]; then
	ln -s /opt/git $HOME/git 2>/dev/null || true
fi

cd $HOME/git
git init
echo '*' | tee .gitignore
git add .
git commit -m "Initial commit"
cd "$current_dir"

sudo mkdir -p /media/local
sudo chown $USER: /media/local
chmod 770 /media/local

if [ ! -d "$HOME/git/local" ]; then
	ln -s /media/local $HOME/git/local 2>/dev/null || true
fi

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
	git pull 2>/dev/null
fi

git remote -v

# Start git instaweb: http://localhost:1234
echo
echo "Starting git instaweb..."
cd ~/git

sudo chown -R $USER: /home/pi/git/.git/gitweb
sudo chown $USER: /home/pi/git/.git/pid

git instaweb 2>/dev/null
#GIT_DISCOVERY_ACROSS_FILESYSTEM=1 git instaweb 2>/dev/null

if [ $? -ne 0 ]; then
        echo
        echo "Restarting git instaweb because it was already running..."
        echo
        git instaweb --stop
        sudo killall lighttpd
	git instaweb
        #GIT_DISCOVERY_ACROSS_FILESYSTEM=1 git instaweb
fi

cd ~

echo
echo "git server utilities installed"
echo
echo "done"
