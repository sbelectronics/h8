# turn off swap to avoid SD-Card writes
sudo dphys-swapfile swapoff
sudo dphys-swapfile uninstall
sudo update-rc.d dphys-swapfile remove
sudo sync
sudo swapoff -a
sudo apt-get purge -y dphys-swapfile
sudo rm /var/swap
sudo sync

# add to /etc/fstab to avoid SD-Card writes
sudo emacs /etc/fstab
  tmpfs    /tmp            tmpfs    defaults,noatime,nosuid,size=100m    0 0
  tmpfs    /var/tmp        tmpfs    defaults,noatime,nosuid,size=30m    0 0
  tmpfs    /var/log        tmpfs    defaults,noatime,nosuid,mode=0755,size=100m    0 0

# dependencies
sudo apt install python3-dev
sudo apt-get install python3-pip
sudo pip3 install RPi.GPIO

# make the library and extension
make smbvdip