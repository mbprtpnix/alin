### select keyboard
```
loadkeys uk
```
### activate network
```
dhcpcd
```
### verify network
```
ping -c 3 www.archlinux.org
```
### set and sync date and time
```
timedatectl set-timezone Europe/Bucharest
timedatectl set-ntp true
hwclock --systohc
timedatectl status
```
### sync pacman
```
pacman -Syyy
```
### install reflector
```
pacman -S reflector
```
### generate mirrorlist with reflector
```
reflector --verbose --latest 5 --age 24 --sort rate --save /etc/pacman.d/mirrorlist
```
### verify disks
```
lsblk
```
### partitioning disk
```
parted -a optimal /dev/sda
(parted) mklabel gpt
(parted) mkpart ESP fat32 1MiB 512MiB
(parted) set 1 boot on
(parted) name 1 efi
(parted) mkpart primary ext4 512MiB 100%
(parted) name 2 lvm
(parted) print
(parted) quit
parted /dev/sda set 2 lvm on
```
### verify partitions
```
parted /dev/sda print
```
### create physical volume
```
pvcreate /dev/sda2
```
### create volume group
```
vgcreate VG /dev/sda2
```
### create logical volume
```
lvcreate -n HOME -l 50G VG
lvcreate -n ROOT -L 100%FREE VG
```
### format and create file systems
```
mkfs.fat -F32 -n EFI /dev/sda1
mkfs.ext4 -L ROOT /dev/VG/ROOT
mkfs.ext4 -L HOME /dev/VG/HOME
```
### create mount points and mount the file systems
```
mount /dev/VG/ROOT /mnt
mkdir /mnt/{boot,home}
mkdir /mnt/boot/efi
mount /dev/sda1 /mnt/boot/efi
mount /dev/VG/HOME /mnt/home
```
### pacstrap base system
```
pacstrap -i /mnt base base-devel linux-lts linux-lts-headers linux-firmware lvm2 intel-ucode git curl wget rsync rclone reflector vim neovim bash-completion
```
### do system configuration
```
genfstab -U -p /mnt >> /mnt/etc/fstab
```
### chroot into archlinux
```
arch-chroot /mnt
```
### edit /etc/mkinitcpio.conf to include needed module
```
vim /etc/mkinitcpio.conf
```
> look for line starting with HOOKS="..." and add 'lvm2' AFTER 'block' and BEFORE 'filesystems'
### regenerate initrd image
```
mkinitcpio -p linux-lts
```
### edit locale
```
vim /etc/locale.gen
```
> uncomment en_US.UTF-8
### generate locale
```
locale-gen
```
### add locale.conf
```
echo LANG=en_US.UTF-8 > /etc/locale.conf
```
### add vconsole.conf
```
echo KEYMAP=uk > /etc/vconsole.conf
echo FONT=sun12x22 > /etc/vconsole.conf
```
### add localtime
```
ln -sf /usr/share/zoneinfo/Europe/Bucharest /etc/localtime
```
### set hostname
```
echo archlinux-pc > /etc/hostname
```
### edit hosts
```
vim /etc/hosts
127.0.0.1   localhost
::1         localhost
127.0.1.1   archlinux-pc.local      archlinux-pc
```
### set root user password
```
passwd
```
### rest of base packages
```
pacman -S grub sudo netctl dialog wpa_supplicant wireless_tools networkmanager network-manager-apple efibootmgr dosfstools os-prober mtools
```
### install grub
```
grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory=/boot/efi --recheck
```
### config grub
```
grub-mkconfig -o /boot/grub/grub.cfg
```
### enable networkmanager
```
systemctl enable NetworkManager
```
### exit chroot
```
exit
```
### umount partitions
```
umount -R /mnt/boot/efi
umount -R /mnt/home
umount -R /mnt
```
### reboot into new system
```
reboot
```
### add new regular user
```
useradd -mG wheel -s /bin/bash user
```
### set user password
```
passwd user
```
### edit sudoers
```
vim /etc/sudoers
```
> uncomment wheel group
### audio
```
pacman -S pulseaudio pulseaudio-alsa alsa-utils pavucontrol
```
> if no sound, execute 'alsactl init'
### video
```
pacman -S xf86-video-intel xf86-video-amdgpu xf86-video-ati xorg xorg-server xorg-xinit
```
### install desktop environment
```
pacman -S xfce4 xfce4-goodies xfce4-terminal firefox
```
### install login manager
```
pacman -S lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings
```
### enable login manager
```
systemctl enable lightdm
```
### reboot
```
reboot
```