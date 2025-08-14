# SXBOX

## Инструкция по установке
### LiveISO
1. Удаляем все существующие разделы
```bash
    wipefs -a /dev/sda /dev/sdb /dev/nvme0n1
    sgdisk --zap-all /dev/nvme0n1
    vgchange -an
    sgdisk --zap-all /dev/sda
    sgdisk --zap-all /dev/sdb
    dd if=/dev/zero of=/dev/sda bs=1M count=10
    dd if=/dev/zero of=/dev/sdb bs=1M count=10
```
2. Создаем разделы
```bash
    echo -e "g\nn\n\n\n+1G\nt\n1\nn\n\n\n\nw" | fdisk /dev/nvme0n1
    echo -e "g\nn\n\n\n\nw" | fdisk /dev/sda
    echo -e "g\nn\n\n\n\nw" | fdisk /dev/sdb
    pvcreate /dev/sda1 /dev/sdb1
    vgcreate sdgroup /dev/sda1 /dev/sdb1
    lvcreate -i 2 -I 64 -l 100%FREE -n homeland sdgroup
```
3. Форматирование и монтирование
```bash
    mkfs.fat -F 32 /dev/nvme0n1p1
    mkfs.ext4 /dev/nvme0n1p2
    mkfs.ext4 /dev/sdgroup/homeland
    mount /dev/nvme0n1p2 /mnt
    mkdir -p /mnt/{boot/efi,home}
    mount /dev/nvme0n1p1 /mnt/boot/efi
    mount /dev/sdgroup/homeland /mnt/home
```
4. Создаем SWAP-файл
```bash
    cd /mnt/home && fallocate -l 32G .swapfile
    dd if=/dev/zero of=/mnt/home/.swapfile bs=1G count=32 status=progress
    chmod 600 /mnt/home/.swapfile
    mkswap /mnt/home/.swapfile
    swapon /mnt/home/.swapfile && cd
```
5. Редактируем pacman.conf
```bash
    sed -i -e 's/^#ParallelDownloads = 5/ParallelDownloads = 10/' -e '/^#\[multilib\]/{N;s/#\[multilib\]\n#/[multilib]\n/}' /etc/pacman.conf
```
6. Установка программ
```bash
    pacstrap /mnt base linux linux-firmware linux-headers sudo dhcpcd lvm2 \
    vim nano glances fastfetch iwd samba openssh git base-devel zsh
```
7. Перенос pacman.conf, создание fstab и вход в систему
```bash
    cp /etc/pacman.conf /mnt/etc/pacman.conf
    genfstab -U /mnt >> /mnt/etc/fstab
    arch-chroot /mnt
```

---

#### Chroot
1. Настройка SSH
```bash
    sed -i 's/^#\s*PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
```
2. Пользователи
```bash
    sed -i 's/^# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/' /etc/sudoers
    useradd -mG wheel -g users -s /bin/zsh statix
    echo 'statix:1234' | sudo chpasswd
    echo 'root:1234' | sudo chpasswd
```
3. Запуск основных служб
```bash
    systemctl enable sshd dhcpcd iwd
```
4. Время и часовой пояс
```bash
    ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime
    hwclock --systohc
```
5. GRUB и выход из Chroot
```bash
    pacman -Syy grub efibootmgr
    grub-install --target=x86_64-efi --efi-directory=/boot/efi
    grub-mkconfig -o /boot/grub/grub.cfg && exit
```

---

### Reboot
```bash
    umount -R /mnt
    reboot
```

### Первый запуск
1. Графика (Nvidia)
```bash
    sudo pacman -Syu nvidia nvidia-utils vulkan-icd-loader lib32-nvidia-utils lib32-vulkan-icd-loader opencl-nvidia lib32-opencl-nvidia
```
2. X11
```bash
    sudo pacman -S xorg xorg-server xorg-xinit xorg-xrandr xdotool numlockx
``` 
3. Перенос настроек
```bash
    git clone https://github.com/statix05/sxbox
    chmod +x sxbox/todo/01.sh && ./sxbox/todo/01.sh
```
4. Установка oh-my-zsh
```bash
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```
5. Настройка ZSH
```bash
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install
    sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="af-magic"/' ~/.zshrc 
    echo "setopt CORRECT" >> ~/.zshrc && exec zsh
```
