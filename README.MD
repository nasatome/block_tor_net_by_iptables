#Block Tor Exit Nodes by UFW IPTABLES

Search for all Tor exit nodes from the past 16 hours and by means of UFW add Deny Rules to Firewall IPTABLES

usage: 

> block_tor_iptables.sh enp0s31f6 80 443 22 21

> block_tor_iptables.sh eth0 80 443 22 21

> block_tor_iptables.sh null 80 443 22 21  

In Crontab:

- 1 -> crontab -e
- 2 -> add
> 25 1 * * * sudo /path/to/file/block_tor_net_by_iptables/block_tor_iptables.sh eth0 80 443 21 22 >> /path/to/file/block_tor_net_by_iptables/output.log  

####Requirements
- root user
- UFW enable
- internet ;)

PR are welcome