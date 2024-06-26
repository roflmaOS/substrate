#/usr/bin/expect -f

set EXTRA [lassign $argv CD CDLABEL]
# builds/amd64/minimal/latest-systemd-amd64-minimal.iso roflmaOS_systemd
source builds/tests/failures.tcl

spawn virt-install --autoconsole text --os-variant gentoo --boot uefi --location $CD,kernel=boot/gentoo,initrd=boot/gentoo.igz --extra-args "console=ttyS0 root=live:CDLABEL=$CDLABEL quiet" --metadata title=$CD {*}$EXTRA

while true {
	expect {
		"Connected to domain" { exec virsh pool-refresh default }
		"roflmaOS login:" { send "root\r" }
		"root@roflmaOS ~ #" {
			if {$LIVE == 0} { send "systemd-repart --no-pager /dev/vda --empty=require --dry-run=no --tpm2-device=auto\r" }
			if {$LIVE == 1} { send "/lib/systemd/systemd-cryptsetup attach cryptoroot /dev/vda2 - tpm2-device=auto\r" }
			if {$LIVE == 2} { send "systemd-mount /dev/mapper/cryptoroot\r" }
			if {$LIVE == 3} { send "systemd-mount -o uid=0,gid=0,fmask=0077,dmask=0077 /dev/vda1 /run/media/system/root-x86-64/efi\r" }
			if {$LIVE == 4} { send "rsync --archive /run/rootfsbase/ /run/media/system/root-x86-64\r" }
			if {$LIVE == 5} { send "systemd-machine-id-setup --root /run/media/system/root-x86-64\r" }
			if {$LIVE == 6} { send "systemd-nspawn --bind /sys/firmware/efi -D/run/media/system/root-x86-64\r" }
			if {$LIVE == 11} { send "systemctl reboot\r" }
			set LIVE [expr $LIVE + 1]
		}
		"root@root-x86-64 ~ #" {
			if {$LIVE == 7} { send "bootctl install\r" }
			if {$LIVE == 8} { send "dracut --uefi --kernel-image=/boot/gentoo --kernel-cmdline=console=ttyS0\r" }
			if {$LIVE == 9} { send "exit\r" }
			set LIVE [expr $LIVE + 1]
		}
		"device-mapper: remove ioctl" ioctl
		"Please enter passphrase for disk" enter_passphrase
		"Last login:" { if {$LIVE >= 9} { exit } }
		$fat_clusters_msg fat_clusters
		-re $failures handle_failures
		"Control-D": { send "\r" }
		":/root# " {
			if {$LIVE <= 10} { send "\r" }
			if {$LIVE == 11} { send "systemd-cryptsetup attach root /dev/gpt-auto-root-luks\r" }
			if {$LIVE == 12} { send "mount /dev/mapper/root /sysroot\r" }
			if {$LIVE == 13} { send "systemctl default\r" }
		}
	}
}
