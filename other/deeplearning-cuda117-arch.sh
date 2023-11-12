function error() {
    echo -e "\033[31m[-] $1\033[0m"
    exit 1
}

function info() {
    echo -e "\033[32m[+] $1\033[0m"
}

function execmd() {
    eval  $1 && info "exec $1 success" || error "exec $1 failed"
}


cuda11="Server = https://archive.archlinux.org/repos/2022/10/13/\$repo/os/\$arch"


pacman -S libva libva-intel-driver mhwd-nvidia mesa mesa-utils libva-mesa-driver libva-nvidia-driver libva-utils --noconfirm



if [ ! -f /etc/pacman.conf.bak ]; then
    execmd "mv /etc/pacman.conf /etc/pacman.conf.bak && cp ./temp/pacman.conf /etc/pacman.conf -f"
else
    if [ ! -f /etc/pacman.conf ]; then
        execmd "cp ./temp/pacman.conf /etc/pacman.conf -f"
    fi
    info "pacman.conf.bak already exists"
fi


if [ ! -f /etc/pacman.d/mirrorlist.bak ]; then
    execmd "mv /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak && echo $cuda11 > /etc/pacman.d/mirrorlist"
else
    if [ ! -f /etc/pacman.d/mirrorlist ]; then
        echo $cuda11 | tee /etc/pacman.d/mirrorlist
    fi
    info "mirrorlist.bak already exists"
fi



pacman -Syy
execmd "pacman -S nvidia-dkms --noconfirm"




# get GRUB_CMDLINE_LINUX_DEFAULT=... line from /etc/default/grub
kernel_args=$(cat /etc/default/grub | grep GRUB_CMDLINE_LINUX_DEFAULT=)
if [[ $kernel_args != *"nvidia-drm.modeset=1"* ]]; then
    execmd "sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=\"/&nvidia-drm.modeset=1 /' /etc/default/grub"
else
    info "nvidia-drm.modeset=1 already in GRUB_CMDLINE_LINUX_DEFAULT"
fi



mkinitcpio_mods=$(cat /etc/mkinitcpio.conf | grep 'MODULES=()')
if [[ $mkinitcpio_mods != *"nvidia"* ]]; then
    execmd "sed -i 's/MODULES=()/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf"
else
    info "nvidia modules already in mkinitcpio"
fi


mkdir -p /etc/pacman.d/hooks
# if /etc/pacman.d/hooks/nvidia.hook exists, skip
if [ ! -f /etc/pacman.d/hooks/nvidia.hook ]; then
    execmd "cp ./temp/nvidia.hook /etc/pacman.d/hooks/nvidia.hook"
else
    info "nvidia.hook already exists"
fi



execmd "grub-mkconfig -o /boot/grub/grub.cfg"
mkinitcpio -P


# recover pacman.conf and mirrorlist
execmd "rm /etc/pacman.conf && mv /etc/pacman.conf.bak /etc/pacman.conf"
execmd "rm /etc/pacman.d/mirrorlist && mv /etc/pacman.d/mirrorlist.bak /etc/pacman.d/mirrorlist"


# ignore nvidia packages
ignore=$(cat /etc/pacman.conf | grep 'IgnorePkg.*=')
if [[ $ignore != *"nvidia-dkms nvidia-utils opencl-nvidia"* ]]; then
    # if IgnorePkg whether be commented or not,if commented, uncomment it
    if [[ $ignore == *"#IgnorePkg"* ]]; then
        sed -i 's/#IgnorePkg/IgnorePkg/' /etc/pacman.conf
        sed -i 's/IgnorePkg.*=/& nvidia-dkms nvidia-utils opencl-nvidia/' /etc/pacman.conf
        info "nvidia-dkms nvidia-utils opencl-nvidia added to IgnorePkg"
    fi
else
    info "nvidia-dkms nvidia-utils opencl-nvidia already in IgnorePkg"
fi

execmd 'pacman -Scc --noconfirm'
execmd 'pacman -Syy'