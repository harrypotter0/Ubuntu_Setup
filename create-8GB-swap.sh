#!/bin/bash
df -h;

sudo swapoff -a;

sudo /bin/dd if=/dev/zero of=/var/swap.1 bs=512 count=16777216;
sudo chmod 600 /var/swap.1;
sudo /sbin/mkswap /var/swap.1;
sudo /sbin/swapon /var/swap.1;

sudo vi /etc/fstab; # add this at the end
# /var/swap.1   none    swap    sw    0   0

free -m;
