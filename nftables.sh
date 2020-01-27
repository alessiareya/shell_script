#/bin/bash

# ENVIRONMENT
NFT='/usr/sbin/nft'
NFT_STATUS=$(/usr/bin/systemctl status nftables.service > /dev/null && echo $?) 
IP_FAMILY=${IP_FAMILY=inet}
NIC_0='ens160'
NIC_1='ens192'

# SETTING FLAG
## if you would like to configure, change 'no' to 'yes'
FILTER='yes'
NAT='no'
#MANGLE='no'
#RAW='no'
#SECURITY='no'

# FUNCTIONS
apply_filter() {
  $NFT add table ${IP_FAMILY} filter
  $NFT add chain ${IP_FAMILY} filter input \{ type filter hook input priority 0 \; policy drop\; \}
  $NFT add chain ${IP_FAMILY} filter input_tcp 
  $NFT add chain ${IP_FAMILY} filter input_udp 
  $NFT add chain ${IP_FAMILY} filter input_icmp
  $NFT add chain ${IP_FAMILY} filter output \{ type filter hook output priority 0 \; policy drop\; \}
  $NFT add chain ${IP_FAMILY} filter forward \{ type filter hook forward priority 0 \; policy drop\; \}

  # INET INPUT RULE
  $NFT add rule ${IP_FAMILY} filter input ct state \{ established, related \} accept
  $NFT add rule ${IP_FAMILY} filter input ct state invalid drop
  $NFT add rule ${IP_FAMILY} filter input iif lo accept
  $NFT add rule ${IP_FAMILY} filter input ip protocol tcp ct state new jump input_tcp
  $NFT add rule ${IP_FAMILY} filter input ip protocol udp ct state new jump input_udp
  $NFT add rule ${IP_FAMILY} filter input ip protocol icmp ct state new jump input_icmp
  $NFT add rule ${IP_FAMILY} filter input ip protocol tcp drop
  $NFT add rule ${IP_FAMILY} filter input ip protocol udp drop
  $NFT add rule ${IP_FAMILY} filter input counter log limit rate 500/second drop 

  # INET INPUT TCP REGULAR CHAIN RULE
  $NFT add rule ${IP_FAMILY} filter input_tcp ip saddr 0.0.0.0/0 tcp dport 22 accept
  $NFT add rule ${IP_FAMILY} filter input_tcp ip saddr 0.0.0.0/0 tcp dport \{ 53, 80, 443 \} accept

  # INET INPUT UDP REGULAR CHAIN
  $NFT add rule ${IP_FAMILY} filter input_udp ip saddr 0.0.0.0/0 udp dport \{ 53, 123 \} accept

  # INET INPUT PING REGULAR CHAIN RULE
  $NFT add rule ${IP_FAMILY} filter input_icmp ip protocol icmp limit rate 10/second accept
  $NFT add rule ${IP_FAMILY} filter input_icmp ip protocol icmp limit rate over 128 bytes/second drop
  
  # INET OUTPUT RULE
  $NFT add rule ${IP_FAMILY} filter output ct state \{ established, related, \} accept
  $NFT add rule ${IP_FAMILY} filter output ip daddr 0.0.0.0/0 tcp dport \{ 22, 25, 53, 80, 123, 443 \} accept
  $NFT add rule ${IP_FAMILY} filter output ip daddr 0.0.0.0/0 udp dport \{ 53, 123, 161, 162 \} accept
  $NFT add rule ${IP_FAMILY} filter output ip daddr 0.0.0.0/0 ip protocol icmp accept
}

apply_nat() {
  /usr/sbin/sysctl -w net.ipv4.ip_forward=1 > /dev/null
  $NFT add table ip nat 
  
  # POST ROUTING(SNAT)
  $NFT add chain ip nat postrouting \{ type nat hook postrouting priority 0 \; \}
  $NFT add rule nat postrouting ip saddr 172.16.0.0/24 oif ${NIC_1} snat 10.0.0.1

  # MASQUERADE
  $NFT add rule nat postrouting ip saddr 172.16.0.0/16 oif ${NIC_1} masquerade

  # PRE ROUTING(DNAT)
  $NFT add chain ip nat prerouting \{ type nat hook prerouting priority 0 \; \}
  $NFT add rule nat prerouting iif ${NIC_0} tcp dport \{ 80, 443 \} dnat 172.16.0.209:80
}

# START SETTINGS
if [[ ${NFT_STATUS} = 0 ]]; then
  $NFT list ruleset >> $(date '+%Y%m%d_%H%M%S')_nftables.txt
  $NFT flush ruleset 
  [[ ${FILTER} = 'yes' ]]  && apply_filter
  [[ ${NAT} = 'yes' ]]  && apply_nat
else
  echo "Check nftables service or # lsmod | grep nf_tables"
  exit 0
fi
