#! /bin/bash
set -exu

[[ -f reset ]] ||
touch reset

command -v docker ||
curl https://raw.githubusercontent.com/InnovAnon-Inc/repo/master/get-docker.sh | bash

sudo             -- \
nice -n +20      -- \
sudo -u `whoami` -- \
docker build -t innovanon/install-all .

docker push innovanon/install-all:latest || :

sudo             -- \
nice -n +20      -- \
sudo -u `whoami` -- \
docker run   -t innovanon/install-all

