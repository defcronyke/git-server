#!/bin/bash
# To use this, run the following command:
#
#   curl -sL https://tinyurl.com/git-server-init | bash
#

git_server_init_routine() {
  echo ""
  echo "Initializing device: ${USER}@$(hostname)"
  echo ""

  if [ $# -gt 0 ]; then
    echo "args: $@"
    echo ""

    if [ "$1" == "-s" ] || [ "$1" == "-so" ] || [ "$1" == "-os" ]; then
      echo "Running in sequential mode: $0 $@"
      echo ""
    else
      echo "Running in parallel mode: $0 $@"
      echo ""
      echo "Setting shell alias for non-interactive sudo: alias sudo='sudo -n'"
      # Run sudo non-interactively unless running in sequential mode because of flag: -s
      alias sudo='sudo -n'
      echo ""
    fi
  fi

  cd ~

  # ----------
  # Do some minimal git config setup to make some annoying yellow warning text stop 
  # showing on newer versions of git.

  # When doing "git pull", merge by default instead of rebase.
  git config --global pull.rebase >/dev/null 2>&1 || \
  git config --global pull.rebase false >/dev/null 2>&1

  # When doing "git init", use "master" for the default branch name.
  git config --global init.defaultBranch >/dev/null 2>&1 || \
  git config --global init.defaultBranch master >/dev/null 2>&1
  # ----------

	if [ -d "git-server" ]; then
		echo ""
		echo "This device has already been initialized. (Re-)Installing: ./install.sh"
		echo ""

    cd git-server && \
    ./install.sh $@

    return $?
	fi

	curl -sL https://gitlab.com/defcronyke/git-server/-/archive/master/git-server-master.tar.gz | \
  tar zxvf - && \
  cd git-server-master && \
  ./install.sh $@
}

git_server_init_routine $@
