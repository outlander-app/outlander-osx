#!/bin/sh
set -e

gem install xcpretty

if [ $? -eq 0 ]
then
  echo "Dependencies installed"
  exit 0
else
  echo "Dependency intalls failed"
  exit 1
fi