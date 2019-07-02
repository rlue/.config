.config
=======

My `$XDG_CONFIG_HOME` for user accounts on \*NIX systems (mostly Linux, but should still work on macOS).

This repo also contains the dotfiles that typically belong at the top level of the user’s `$HOME` directory, and relies on [GNU Stow](https://www.gnu.org/software/stow/) to generate symlinks accordingly.

Installation
------------

```
# --recursive is for including submodules
$ git clone --recursive https://github.com/rlue/.config ~/.config

$ cd ~/.config

# add the ‘-n’ flag to perform a dry-run and manually audit what stow would do
$ stow -Sv .
```

### Dependencies

* GNU Stow

Notes
-----

### Secrets

Some config files contain data that should not be publicly exposed, such as API keys and password hashes. These config files have been PGP-encrypted for safe dissemination. To restore them:

```
$ cd ~/.config
$ gpg -d secrets.tar.gpg | tar xv
$ stow -Sv .
```
