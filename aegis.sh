#!/bin/sh
# aegis.sh:  agnostic minimal posix secrets-vault


gpg_id=`gpg --list-secret-keys | head -5 | grep uid | xargs | cut -d ' ' -f 5 | tr '<>' '  ' | tee`
gpg_hash=`gpg --list-secret-keys | head -5 | grep 'sec ' | xargs | cut -d ' ' -f 2`

cd ~
mkdir -p .password-store
git init .password-store

pass init .password-store $gpg_id
pass git init

