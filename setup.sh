#!/bin/bash

case "${OSTYPE}" in
msys*)
  dotfiles="target.msys";;
darwin*)
  dotfiles="target.darwin";;
linux*)
  dotfiles="target.linux";;
esac

case $1 in
  "link")
    cwd=`pwd`
    cat $dotfiles | while read i; do
      mkdir -p "`dirname "$HOME/$i"`"
      rm -f "$HOME/$i"
      ln -s "$cwd/$i" "$HOME/$i"
    done;;

  "unlink")
    cat $dotfiles | while read i; do
      rm -f "$HOME/$i"
    done;;

  *)
    echo 'usage: ./setup.sh (link|unlink)';;
esac

