$TTL    604800
@	IN	SOA	ns.dmz.gsx. root.ns.dmz.gsx. (
			      2		; Serial
			 604800		; Refresh
			  86400		; Retry
			2419200		; Expire
			 604800 )	; Negatice Cache TTL

; NS Record
@	IN	NS	ns.dmz.gsx.
ns	IN	A	198.18.127.254

; A Record
router  IN	A	198.18.112.1

; CNAME Records
server	IN	CNAME	ns
www	IN	CNAME	ns

