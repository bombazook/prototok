#!/bin/sh
set -e
# check to see if protobuf folder is empty
if [ ! -d "$HOME/protoc/bin" ]; then
  wget https://github.com/google/protobuf/releases/download/v3.5.1/protoc-3.5.1-linux-x86_32.zip
  unzip protoc-3.5.1-linux-x86_32.zip -d $HOME/protoc
else
  echo "Using cached protobuf."
fi
