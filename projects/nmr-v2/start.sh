#! /bin/sh

apps_dir=/media/mmcblk0p1/apps

. $apps_dir/stop.sh

cat $apps_dir/nmr-v2/nmr-v2.bit > /dev/xdevcfg
