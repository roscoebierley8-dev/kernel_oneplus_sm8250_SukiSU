# AnyKernel3 Ramdisk Mod Script — SM8250 SukiSU-Ultra
# osm0sis @ xda-developers

properties() { '
kernel.string=SukiSU-Ultra + SUSFS for SM8250 (__DEVICE__) on Evolution X A16
do.devicecheck=1
do.modules=0
do.systemless=1
do.cleanup=1
do.cleanuponabort=0
device.name1=__DEVICE__
device.name2=instantnoodle
device.name3=instantnoodlep
device.name4=kebab
device.name5=lemonadep
supported.versions=
supported.patchlevels=
'; }

# shell variables
block=/dev/block/bootdevice/by-name/boot;
is_slot_device=1;
ramdisk_compression=auto;
patch_vbmeta_flag=auto;

# import functions/variables and setup patching
. tools/ak3-core.sh;

# boot image: replace kernel + dtb
split_boot;
flash_boot;

# dtbo (some SM8250 ROMs ship dtbo separately; flash if present)
if [ -f $home/dtbo.img ]; then
  dd if=$home/dtbo.img of=/dev/block/bootdevice/by-name/dtbo;
fi;
