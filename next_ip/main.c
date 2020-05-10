#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>


#define TOHOSTIP(str) ntohl(inet_addr(str))

void print_host_addr (in_addr_t addr) {
	int i;
	printf("%d.",  (addr >> 24) & 0xFF);
	printf("%d.",  (addr >> 16) & 0xFF);
	printf("%d.",  (addr >> 8)  & 0xFF);
	printf("%d\n", (addr >> 0)  & 0xFF);
}

/*
in_addr_t nmask8  = 0xFF000000;
in_addr_t nmask12 = 0xFFF00000;
in_addr_t nmask24 = 0xFFFFFF00;
in_addr_t nmask16 = 0xFFFF0000;
*/

int main (int argc, char **argv)
{
	in_addr_t ip_bin = 0;
	in_addr_t next_ip_bin = 0;
	in_addr_t l8, l12, l24, lh, nacfg;
	in_addr_t l8_e, l12_e, l24_e, lh_e, nacfg_e;
	if (argc < 2) {
		fprintf(stderr, "address is not specified\n");
		exit(2);
	}
	ip_bin = TOHOSTIP(argv[1]);
	if (ip_bin == 0xFFFFFFFF && (0 != strcmp(argv[1], "255.255.255.255"))) {
		fprintf(stderr, "wrong address format\n");
		exit(3);
	}
	// calculation caching
	l8 = TOHOSTIP("10.0.0.0");     l8_e  = TOHOSTIP("10.255.255.255");
	l12 = TOHOSTIP("172.16.0.0");  l12_e = TOHOSTIP("172.31.255.255");
	l24 = TOHOSTIP("192.168.0.0"); l24_e = TOHOSTIP("192.168.255.255");
	lh = TOHOSTIP("127.0.0.1");    lh_e  = TOHOSTIP("127.255.255.255");
	nacfg = TOHOSTIP("169.254.0.0"); nacfg_e = TOHOSTIP("169.254.255.255");
	// calculate next addr
	next_ip_bin = ip_bin + 1;

	// DEBUG
	//printf("DEBUG nm a lh %0lX\n", next_ip_bin & nmask8);
	//printf("DEBUG nm m lh %0lX\n", lh);
	//printf("DEBUG nm a == lh %d\n", next_ip_bin & nmask8 == lh);
	while (
			((next_ip_bin >= l8) && (next_ip_bin <= l8_e))
			||
			((next_ip_bin >= l12) && (next_ip_bin <= l12_e))
			||
			((next_ip_bin >= l24) && (next_ip_bin <= l24_e))
			||
			((next_ip_bin >= lh) && (next_ip_bin <= lh_e))
			||
			((next_ip_bin >= nacfg) && (next_ip_bin <= nacfg_e))
	)
	{
		next_ip_bin++;
	}
	//printf("ip_bin %X\n", next_ip_bin);
	print_host_addr(next_ip_bin);
	return 0;
}
