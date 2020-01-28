#/bin/bash

# ENVIRONMENT VARS
NFT='/usr/sbin/nft'
NFT_STATUS=$(/usr/bin/systemctl status nftables.service > /dev/null && echo $?) 
IP_FAMILY=${IP_FAMILY=inet}
IF_0='ens160'
IF_1='ens192'

# SETTING FLAGS
## if you would like to configure, change 'no' to 'yes'
FILTER='yes'
NAT='no'

# FUNCTIONS
apply_filter() {
	# CREATE TABLE and CHAINS
	$NFT add table ${IP_FAMILY} filter
	$NFT add chain ${IP_FAMILY} filter input \{ type filter hook input priority 0 \; policy drop\; \}
	$NFT add chain ${IP_FAMILY} filter input_tcp
	$NFT add chain ${IP_FAMILY} filter input_udp 
	$NFT add chain ${IP_FAMILY} filter input_icmp
	$NFT add chain ${IP_FAMILY} filter output \{ type filter hook output priority 0 \; policy drop\; \}
	$NFT add chain ${IP_FAMILY} filter forward \{ type filter hook forward priority 0 \; policy drop\; \}
	
	# INPUT BLOCK IP SET
	$NFT add set ${IP_FAMILY} filter input_block_ip_list \{ type ipv4_addr \; size 65536 \; flags interval\; \}
	$NFT add element ${IP_FAMILY} filter input_block_ip_list \{ 172.16.0.0/30 \}
	
	# INPUT DROP BLOCK IP RULE
	$NFT add rule ${IP_FAMILY} filter input ip saddr @input_block_ip_list counter log prefix \"NFTABLES_DROP: \" drop
	
	# INPUT LIMIT SET
	$NFT add set ${IP_FAMILY} filter input_limit_ssh_list \{ type ipv4_addr \; size 65536 \; flags timeout \; timeout 60s \; \}
	
	# INPUT LIMIT RULE
	$NFT add rule ${IP_FAMILY} filter input tcp flags syn tcp dport 22 meter flood size 128000 \{ ip saddr timeout 60s limit rate over 3/second \} \
	add @input_limit_ssh_list \{ ip saddr timeout 1d \} counter log prefix \"NFTABLES_DROP: \" drop
	
	# INPUT BASE CHAIN RULE
	$NFT add rule ${IP_FAMILY} filter input iif lo accept
	$NFT add rule ${IP_FAMILY} filter input ip protocol tcp ct state new jump input_tcp
	$NFT add rule ${IP_FAMILY} filter input ip protocol udp ct state new jump input_udp
	$NFT add rule ${IP_FAMILY} filter input ip protocol icmp goto input_icmp
	$NFT add rule ${IP_FAMILY} filter input ct state \{ established, related \} accept
	$NFT add rule ${IP_FAMILY} filter input ip protocol tcp counter log prefix \"NFTABLES_DROP: \" drop
	$NFT add rule ${IP_FAMILY} filter input ip protocol udp counter log prefix \"NFTABLES_DROP: \" drop
	$NFT add rule ${IP_FAMILY} filter input ct state invalid counter log prefix \"NFTABLES_DROP: \" drop
	$NFT add rule ${IP_FAMILY} filter input counter limit rate 500/second accept
	
	# INPUT TCP REGULAR CHAIN RULE
	$NFT add rule ${IP_FAMILY} filter input_tcp ip saddr 0.0.0.0/0 tcp dport 22 accept
	$NFT add rule ${IP_FAMILY} filter input_tcp ip saddr 0.0.0.0/0 tcp dport \{ 53, 80, 443 \} accept
	
	# INPUT UDP REGULAR CHAIN RULE
	$NFT add rule ${IP_FAMILY} filter input_udp ip saddr 0.0.0.0/0 udp dport \{ 53, 123 \} accept
	
	# INPUT PING REGULAR CHAIN RULE
	$NFT add rule ${IP_FAMILY} filter input_icmp ip protocol icmp limit rate over 2/second counter log prefix \"NFTABLES_DROP: \" drop
	$NFT add rule ${IP_FAMILY} filter input_icmp ip protocol icmp limit rate over 85 bytes/second counter log prefix \"NFTABLES_DROP: \" drop
	$NFT add rule ${IP_FAMILY} filter input_icmp ip protocol icmp limit rate 1/second accept
	
	# OUTPUT BASE CHAIN RULE
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
	$NFT add rule nat postrouting ip saddr 172.16.0.0/24 oif ${IF_1} snat 10.0.0.1
	
	# MASQUERADE
	$NFT add rule nat postrouting ip saddr 172.16.0.0/16 oif ${IF_1} masquerade
	
	# PRE ROUTING(DNAT)
	$NFT add chain ip nat prerouting \{ type nat hook prerouting priority 0 \; \}
	$NFT add rule nat prerouting iif ${IF_0} tcp dport \{ 80, 443 \} dnat 172.16.0.209:80
}

# START SETTINGS
if [[ ${NFT_STATUS} = 0 ]]; then
	$NFT list ruleset >> $(date '+%Y%m%d_%H%M%S')_nftables.txt
	$NFT flush ruleset 
	[[ ${FILTER} = 'yes' ]]  && apply_filter
	[[ ${NAT} = 'yes' ]]  && apply_nat
else
	echo Check nftables service or # lsmod | grep nf_tables
	exit 0
fi
