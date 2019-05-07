#!/bin/sh
# shellcheck disable=SC2069

# newsboat’s bookmark-cmd

# url="$1"
# title="$2"
# description="$3"
# current_feed="$4"

if hash pocket-cli >/dev/null 2>&1; then
  pocket-cli add --url "$1" 2>&1 >/dev/null
else
  echo 'pocket-cli does not exist' 1>&2
  exit 1
fi
