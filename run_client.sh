#!/bin/bash -e

DIR="$( cd "$( dirname "$0" )" && pwd )"

chmod +x $DIR/client.sh

# Decrypt thy Secrets
gpg -d $DIR/secrets.tar.gz.gpg | tar -xz

# To encrypt:
# tar cz secrets | gpg -o secrets.tar.gz.gpg --cipher-algo AES256 --digest-algo SHA512 --s2k-mode 3 --s2k-count 65011712 --compress-algo BZIP2 --bzip2-compress-level 9 --s2k-digest-algo SHA512 --symmetric

nohup client.sh &