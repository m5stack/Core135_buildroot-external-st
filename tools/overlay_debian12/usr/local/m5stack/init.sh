#!/bin/bash
/sbin/modprobe fb_ili9342c
. /usr/local/m5stack/bashrc
printf "q\r\n" | fbv /usr/local/m5stack/logo.jpg 2>&1 > /dev/null &
/usr/local/m5stack/lt8618sxb_mcu_config 2>&1 > /dev/null &
echo 1 4 1 7 > /proc/sys/kernel/printk
tinyplay /usr/local/m5stack/logo.wav 2>&1 > /dev/null &



