$TTL    604800
@	IN	SOA	ns.intranet.gsx. root.ns.intranet.gsx. (
			      2		; Serial
			 604800		; Refresh
			  86400		; Retry
			2419200		; Expire
			 604800 )	; Negatice Cache TTL

; NS Record
@	IN	NS	ns.intranet.gsx.
ns	IN	A	198.18.127.254

; A Record
router  IN	A	172.24.0.1
dhcp    IN	A	172.24.127.254

;CNAME
www	IN	CNAME	ns
server  IN	CNAME	ns
