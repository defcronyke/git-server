#!/usr/bin/env bash

# Allow sudo without password for the current user. 
# Needed for parallel mode operation.
git_server_sudo_setup() {
  echo ""
  echo "Checking sudo config..."
  echo ""

  if [ $# -gt 0 ]; then
    echo "sudo config args: $@"
    echo ""
  fi

  if [ "$1" == "-s" ] || [ "$1" == "-so" ] || [ "$1" == "-os" ]; then
    echo "Running in sequential mode: $0 $@"
    echo ""

    # Try to grant sudo permission and exit if unavailable.
    sudo cat /dev/null
    res=$?
  else
    echo "Running in parallel mode: $0 $@"
    echo ""
    # echo "Setting shell alias for non-interactive sudo: alias sudo='sudo -n'"
    # # Run sudo non-interactively unless running in sequential mode because of flag: -s
    # alias sudo='sudo -n'
    # echo ""

    # Try to grant sudo permission and exit if unavailable.
    sudo -n cat /dev/null
    exit $?
    # res=$?
  fi

  if [ $res -ne 0 ]; then
    echo ""
    echo "ERROR: [ HOST: $USER@$(hostname) ]: Failed getting sudo permission."
    echo ""
    echo "ERROR: You can grant passwordless sudo if you want by running the following command:"
    echo ""
    echo "  .gc/new-git-server.sh -s $USER@$(hostname)"
    echo ""
    return 17
  fi

  for i in `sudo ls -1 /etc/sudoers.d/ | grep "_${USER}-nopasswd"`; do echo "/etc/sudoers.d/$i"; done | xargs sudo cat 2>/dev/null | grep "$USER ALL=(ALL) NOPASSWD: ALL" >/dev/null
  res=$?
  if [ $res -ne 0 ]; then
    echo ""
    echo "Setting up passwordless sudo for user: $USER"
    echo ""

    sudo mkdir /etc/sudoers.d/ 2>/dev/null && \
    sudo chmod 750 /etc/sudoers.d/
    
    echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/010_$USER-nopasswd >/dev/null 2>&1 && \
    sudo chmod 440 /etc/sudoers.d/010_$USER-nopasswd

    echo ""
    echo "Finished setting up passwordless sudo for user: $USER"
    echo ""
    echo "You can re-run installation in parallel mode now if you prefer. Exiting..."
    echo ""

    return 19
  fi

  # return 19

  # return $res
  # return 18
  # return $res

  return 0
}

git_server_sudo_setup $@
