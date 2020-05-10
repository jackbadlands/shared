#!/bin/bash

IFS='
'

# installation should be performed by root
if test "$UID" != "0"
then
	echo "run script by root"
	exit 2
fi

# make package dir
D=_spkgdir
mkdir -p $D

# copy files
mkdir -p $D/usr/share/lua/5.1
cp fsm.lua $D/usr/share/lua/5.1/

# set default permissions and owner
chown -R root:root $D
chmod -R ugo= $D
chmod -R u+rwX $D
chmod -R go+rX $D

# build package
pushd $D
P=luafsm-4-noarch-1_dd.tgz
makepkg -l y -c n ../$P || exit 2
popd

# install package
installpkg $P || exit 4

# cleanup
rm -r $D
rm $P

