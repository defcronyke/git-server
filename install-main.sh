#!/bin/bash

git_server_install_main_routine() {
  echo
  echo "Installing git server utilities..."
  echo

  ./install-packages.sh

  # Install GitCid into current git repo.
  if [ ! -d ".gc/" ]; then
    echo ""
    echo "Installing GitCid into git repo..."
    echo ""
    source <(curl -sL https://tinyurl.com/gitcid) -e >/dev/null
    echo ""
  fi

  # ufw defaults
  sudo ufw default deny incoming
  sudo ufw default allow outgoing

  # Add some very permissive ufw rules if needed.
  #
  # !! IMPORTANT !!: You should consider removing these 
  # rule later, after adding similar more restrictive ones 
  # for better security. To remove them, make sure you
  # added similar ones first so you don't lose access,
  # then run the following line of commands:
  # 
  #   sudo ufw delete allow 22/tcp; sudo ufw delete allow 53; sudo ufw delete allow 1234/tcp
  #

  sudo ufw status | grep "22/tcp" | grep "ALLOW"
  if [ $? -ne 0 ]; then
    echo ""
    echo "info: Adding permissive ufw firewall rule: ufw allow 22/tcp"
    echo "info: ssh for remote access"
    sudo ufw allow 22/tcp
    echo ""
  fi

  sudo ufw status | grep "53" | grep "ALLOW"
  if [ $? -ne 0 ]; then
    echo ""
    echo "info: Adding permissive ufw firewall rule: ufw allow 53"
    echo "info: dns for service discovery"
    sudo ufw allow 53
    echo ""
  fi

  sudo ufw status | grep "1234/tcp" | grep "ALLOW"
  if [ $? -ne 0 ]; then
    echo ""
    echo "info: Adding permissive ufw firewall rule: ufw allow 1234/tcp"
    echo "info: http web server for GitWeb"
    sudo ufw allow 1234/tcp
    echo ""
  fi


  # Check for more restrictive ufw firewall rules so that 
  # we can recommend removing the overly-permissive ones,
  # if we find all the ones that are needed.

  GIT_SERVER_HAS_STRICT_UFW_RULES=()

  sudo ufw status | grep "22/tcp" | grep "ALLOW" | grep -v "Anywhere"
  GIT_SERVER_HAS_STRICT_UFW_RULES+=($?)

  sudo ufw status | grep "53" | grep "ALLOW" | grep -v "Anywhere"
  GIT_SERVER_HAS_STRICT_UFW_RULES+=($?)

  sudo ufw status | grep "1234/tcp" | grep "ALLOW" | grep -v "Anywhere"
  GIT_SERVER_HAS_STRICT_UFW_RULES+=($?)

  GIT_SERVER_HAS_STRICT_UFW_RULES_RECOMMEND=0

  for i in ${GIT_SERVER_HAS_STRICT_UFW_RULES[@]}; do
    if [ $i -ne 0 ]; then
      GIT_SERVER_HAS_STRICT_UFW_RULES_RECOMMEND=1
      break
    fi
  done

  # Detect default overly-permissive ufw firewall rules.
  GIT_SERVER_HAS_WEAK_UFW_RULES=()

  sudo ufw status | grep "22/tcp" | grep "ALLOW" | grep "Anywhere"
  GIT_SERVER_HAS_WEAK_UFW_RULES+=($?)

  sudo ufw status | grep "53" | grep "ALLOW" | grep "Anywhere"
  GIT_SERVER_HAS_WEAK_UFW_RULES+=($?)

  sudo ufw status | grep "1234/tcp" | grep "ALLOW" | grep "Anywhere"
  GIT_SERVER_HAS_WEAK_UFW_RULES+=($?)

  GIT_SERVER_HAS_WEAK_UFW_RULES_RECOMMEND=1

  for i in ${GIT_SERVER_HAS_WEAK_UFW_RULES[@]}; do
    if [ $i -eq 0 ]; then
      GIT_SERVER_HAS_STRICT_UFW_WEAK_RECOMMEND=0
      break
    fi
  done

  if [ $GIT_SERVER_HAS_STRICT_UFW_RULES_RECOMMEND -eq 0 ] && [ $GIT_SERVER_HAS_WEAK_UFW_RULES_RECOMMEND -eq 0 ]; then
    echo ""
    echo "NOTICE: COMPATIBLE UFW FIREWALL RULES WERE DETECTED ON YOUR SYSTEM."
    echo ""
    echo "NOTICE: CONSIDER RUNNING THE FOLLOWING LINE OF COMMANDS TO REMOVE THE "
    echo "DEFAULT OVERLY-PERMISSIVE UFW RULES IF YOU PREFER BETTER SECURITY:"
    echo ""
    echo "  sudo ufw delete allow 22/tcp; sudo ufw delete allow 53; sudo ufw delete allow 1234/tcp"
    echo ""
    echo "WARNING: MAKE SURE YOU'LL STILL BE ABLE TO ACCESS THIS DEVICE FROM YOUR"
    echo "REQUIRED LOCATIONS BEFORE RUNNING THE ABOVE COMMANDS."
    echo ""
    echo "WARNING: IF YOU AREN'T SURE, TEST IT FIRST OR DON'T RUN THE ABOVE COMMANDS,"
    echo "OTHERWISE YOU COULD LOSE THE ABILITY TO ACCESS YOUR DEVICE REMOTELY."
    echo ""
    echo "YOU HAVE BEEN WARNED!"
    echo ""
  fi

  # Enable ufw firewall if not enabled.
  sudo ufw status | grep "Status: inactive"
  if [ $? -eq 0 ]; then
    echo ""
    echo "info: enabling ufw firewall"
    sudo ufw --force enable
    echo ""
  fi

  # # Recommend enabling ufw if not enabled.
  # sudo ufw status | grep "Status: inactive"
  # if [ $? -eq 0 ]; then
  #   echo ""
  #   echo "NOTICE: UFW FIREWALL IS NOT CURRENTLY ENABLED. CONSIDER ENABLING IT"
  #   echo "FOR BETTER SECURITY BY RUNNING THE FOLLOWING COMMAND:"
  #   echo ""
  #   echo "  sudo ufw --force enable"
  #   echo ""
  # fi


  ## Service Discovery
  ##
  ## Fallback Method:
  ##   (Optional) Uncomment below to respond to broadcast pings 
  ##   for a less performant fallback service discovery method.
  ##   It's better to not use this unless you need it for your 
  ##   particular network environment.
  ##
  # sudo cat /etc/sysctl.conf | grep "net.ipv4.icmp_echo_ignore_broadcasts = 0"
  # if [ $? -ne 0 ]; then
  # 	echo
  # 	echo "Enabling broadcast ping response for DNS discovery..."
  # 	echo "net.ipv4.icmp_echo_ignore_broadcasts = 0" | sudo tee -a /etc/sysctl.conf
  # 	sudo sysctl --system
  # 	echo "broadcast ping response enabled"
  # 	echo
  # else
  # 	echo
  # 	echo "info: broadcast ping response is already enabled, not enabling it again"
  # 	echo
  # fi

  echo ""
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
  echo ""

  # Install GitCid into current git repo.
  if [ ! -d ".gc/" ]; then
    echo ""
    echo "Installing GitCid into git repo..."
    echo ""
    source <(curl -sL https://tinyurl.com/gitcid) -e >/dev/null
    echo ""
  fi

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

  # Install GitCid into current git repo.
  if [ ! -d ".gc/" ]; then
    echo ""
    echo "Installing GitCid into git repo..."
    echo ""
    source <(curl -sL https://tinyurl.com/gitcid) -e >/dev/null
    echo ""
  fi

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
    echo ""
    echo "Installing GitCid..."
    echo ""
    source <(curl -sL https://tinyurl.com/gitcid)
    echo ""
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
  else
    cd ~/repo1
    git pull 2>/dev/null
  fi

  # Install GitCid into current git repo.
  if [ ! -d ".gc/" ]; then
    echo ""
    echo "Installing GitCid into git repo..."
    echo ""
    source <(curl -sL https://tinyurl.com/gitcid) -e >/dev/null
    echo ""
  fi

  git remote -v

  # Start git instaweb: http://localhost:1234
  echo
  echo "Starting git instaweb..."
  cd ~/git

  sudo chown -R $USER: /home/pi/git/.git/gitweb
  sudo chown $USER: /home/pi/git/.git/pid

  echo ""
  git instaweb 2>/dev/null
  #GIT_DISCOVERY_ACROSS_FILESYSTEM=1 git instaweb 2>/dev/null

  if [ $? -ne 0 ]; then
    echo
    echo "Restarting git instaweb because it was already running..."
    echo
    git instaweb --stop
    sudo killall lighttpd

    echo ""
    git instaweb
    #GIT_DISCOVERY_ACROSS_FILESYSTEM=1 git instaweb
  fi

  echo ""

  cd ~/git-server

  # Install service discovery
  echo ""
  echo "Installing bind DNS service discovery feature..."
  echo ""

  if [ ! -d "discover-git-server-dns" ]; then
    git clone https://gitlab.com/defcronyke/discover-git-server-dns.git && \
    cd discover-git-server-dns
  else
    cd discover-git-server-dns && \
    git pull
  fi

  echo ""

  ./install.sh

  # Install GitCid into current git repo.
  if [ ! -d ".gc/" ]; then
    echo ""
    echo "Installing GitCid into git repo..."
    echo ""
    source <(curl -sL https://tinyurl.com/gitcid) -e >/dev/null
    echo ""
  fi

  echo ""

  # # Detect all git servers on the remote device's network,
  # # and list URLs for accessing their GitWeb interfaces.
  # echo ""
  # ./git-web.sh
  # echo ""

  cd ~

  # Remove bootstrap dir "git-server-master" if present.
  if [ -d "git-server-master" ]; then
    rm -rf git-server-master
  fi

  echo ""
  echo "git server utilities installed"
  echo ""
  echo "done"
  echo ""
}

git_server_install_main_routine
