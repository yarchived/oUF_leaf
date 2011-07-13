#!/bin/sh

if [[ -f gsrd ]]; then
    svn up gsrd
else
    svn co svn://svn.wowace.com/wow/grid-status-raid-debuff/mainline/trunk gsrd
fi

#for f in gsrd/WotLK/*.lua; do
#    lua parse.lua $f
#done





