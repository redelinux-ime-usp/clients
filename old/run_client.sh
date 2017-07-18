#!/bin/bash -e

DIR="$( cd "$( dirname "$0" )" && pwd )"

pushd .

cd $DIR

chmod +x client.sh

# Decrypt thy Secrets
gpg -d secrets.tar.gz.gpg | tar -xz

# To encrypt:
#tar cz secrets | gpg -o secrets.tar.gz.gpg --cipher-algo AES256 --digest-algo SHA512 --s2k-mode 3 --s2k-count 65011712 --compress-algo BZIP2 --bzip2-compress-level 9 --s2k-digest-algo SHA512 --symmetric

popd
nohup $DIR/client.sh &
