#!/usr/bin/env bash

dpkg --add-architecture i386
apt-get update

apt-get install -fy make ruby ruby-dev wget unzip zip git pkg-config gcc
apt-get install -fy libgtk2.0-dev libglib2.0-dev libgtksourceview2.0-dev

#i386
apt-get install -fy gcc-multilib multiarch-support libgtk2.0-0:i386 libglib2.0-0:i386 libglib2.0-0:i386 libpango-1.0.0:i386 libgdk-pixbuf2.0-0:i386

#fix cross linking i386
for library in $(ls /usr/lib/i386-linux-gnu/*.so.[0-9]); do
    library_src=${library%%.[0-9]}
    ln -s $library $library_src
done
ln -s /lib/i386-linux-gnu/libglib-2.0.so.0 /lib/i386-linux-gnu/libglib-2.0.so

#go lang
wget --quiet https://dl.google.com/go/go1.9.2.linux-amd64.tar.gz -O - | tar -C /usr/local -xzf -

cat <<EOF > /etc/profile.d/go.sh
export GOHOME=$HOME/go
export PATH=/usr/local/go/bin:$GOHOME/bin:$PATH
EOF


#ruby deps
gem install fpm

#m.windows deps
apt-get install -fy mingw-w64 nsis
