#!/bin/bash

SUPER_VARIABLE=`date +%C%y%m%d-%H%M%S`

echo TurtleShell Backup Routine
echo We\'ll create ts.$SUPER_VARIABLE.tar.bzip2 ?
echo Hit Enter to Proceed..
read

cd ~b1/pl
cp -r ts/ ~b1/bak/ts-$SUPER_VARIABLE

cd ~b1/bak
tar jcvf ts/ts.$SUPER_VARIABLE.tar.bzip2 ts-$SUPER_VARIABLE/*
rm -rf ts-$SUPER_VARIABLE/

echo
echo Current TurtleShell Code Backed Up into ~b1/bak/ts/ts.$SUPER_VARIABLE.tar.bzip2
echo

echo enter any comments for the backup:
echo end with ^D
echo

cat > ~b1/bak/ts/ts.$SUPER_VARIABLE.note




