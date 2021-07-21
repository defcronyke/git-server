# Git Server

## Quickstart

NOTE: This installs a bunch of dependencies and does automatic things to your system. It's only meant to be run on a freshly installed Linux distro which will be dedicated to being a git remote server.

```shell
curl -sL https://tinyurl.com/git-server-init | bash
```

### Optional Suggestion

- Install GitCid into any existing git repo:

  ```shell
  source <(curl -sL https://tinyurl.com/gitcid) -e
  ```

- Commit and push using GitCid helper script:

  ```shell
  .gc/commit-push.sh A commit message.
  ```

## Related

- [https://gitlab.com/defcronyke/git-server](https://gitlab.com/defcronyke/git-server)
- [https://gitlab.com/defcronyke/gitcid](https://gitlab.com/defcronyke/gitcid)
- [https://gitlab.com/defcronyke/usb-mount-git](https://gitlab.com/defcronyke/usb-mount-git)
- [https://gitlab.com/defcronyke/discover-git-server-dns](https://gitlab.com/defcronyke/discover-git-server-dns)
