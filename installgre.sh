read -p "Enter VPS IP (local IP for GRE tunnel): " VPS_IP
read -p "Enter Source IP (remote IP for GRE tunnel): " SRC_IP
read -p "Enter Local IP (private IP for GRE tunnel ***with subnet like /24***): " LOCAL_IP
systemctl stop systemd-resolved
systemctl mask systemd-resolved
rm /etc/resolv.conf
cat <<EOF > /etc/resolv.conf
nameserver 1.1.1.1
nameserver 8.8.8.8
EOF
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
echo "net.ipv4.ip_local_port_range = 1024 65535" >> /etc/sysctl.conf
echo "net.ipv4.tcp_fin_timeout = 30" >> /etc/sysctl.conf
echo "net.ipv4.tcp_tw_reuse = 1" >> /etc/sysctl.conf
echo "fs.file-max = 34000000" >> /etc/sysctl.conf
echo "fs.nr_open = 801000000" >> /etc/sysctl.conf
echo "net.core.somaxconn = 65535000" >> /etc/sysctl.conf
echo "net.ipv4.tcp_max_syn_backlog = 65535000" >> /etc/sysctl.conf
echo "net.core.netdev_max_backlog = 16386000" >> /etc/sysctl.conf
echo "net.ipv4.tcp_syn_retries = 1" >> /etc/sysctl.conf
echo "net.ipv4.tcp_synack_retries = 1" >> /etc/sysctl.conf
echo "net.ipv4.tcp_fin_timeout = 5" >> /etc/sysctl.conf
echo "net.ipv4.tcp_syncookies = 0" >> /etc/sysctl.conf
echo "kernel.threads-max = 32617800" >> /etc/sysctl.conf
echo "net.netfilter.nf_conntrack_max = 999999999" >> /etc/sysctl.conf
cd /root
cat <<EOF > /root/gre.sh
ip tunnel add gre1 mode gre local $VPS_IP remote $SRC_IP ttl 255
ip addr add $LOCAL_IP dev gre1
ip link set gre1 up
EOF
chmod +x /root/gre.sh
iptables -t nat -A POSTROUTING -j MASQUERADE
sysctl -p
(crontab -l 2>/dev/null; echo "@reboot /root/gre.sh") | crontab -
apt install iptables-persistent -y
