From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: [patch 0/2][NETNS49][IPV4][IGMP] activate multicast per namespace
Date: Fri, 12 Oct 2007 19:10:13 +0200
Message-ID: <20071012171013.105324992@mai.toulouse-stg.fr.ibm.com>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

The following patches activate the multicast sockets for
the namespaces. The results is a traffic going through 
differents namespaces. So if there are several applications
listenning to the same multicast group/port, running in
different namespaces, they will receive multicast packets.

The following program helps to test that.

Note that the TTL field is set to 2 to avoid to packets to
be dropped while going through the network namespace.

#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <unistd.h>
#include <netinet/in.h>
#include <arpa/inet.h>

int run(int server, int daddr, int dport, int saddr, int nbmsg, int delay, int timeout)
{
        int fd,i;
        struct ip_mreq mreq;
        struct sockaddr_in addr;

        socklen_t len = sizeof(addr);
        int val;

        memset(&addr,0,len);
        memset(&mreq, 0, sizeof(mreq));

        mreq.imr_multiaddr.s_addr  = daddr;
        mreq.imr_interface.s_addr  = saddr;

        addr.sin_family       = AF_INET;
        addr.sin_port         = dport;
        addr.sin_addr.s_addr  = INADDR_ANY;

        if ((fd = socket(AF_INET,SOCK_DGRAM,0)) == -1) {
                perror("socket");
                return 1;
        }

        if (server)
                if (bind(fd, (struct sockaddr*)&addr, sizeof(addr))) {
                        perror("bind");
                        return 1;
                }

        if (setsockopt(fd, IPPROTO_IP, IP_ADD_MEMBERSHIP, &mreq, sizeof(mreq))) {
                perror("setsockopt ADD_MEMBER_SHIP");
                return 1;
        }

        val = 2;
        if (setsockopt(fd, IPPROTO_IP, IP_MULTICAST_TTL, &val, sizeof(val))) {
                perror("setsockopt MULTICAST_TTL");
                return 1;
        }

        /* val = 0; */
        val = 1;
        if (setsockopt(fd, IPPROTO_IP, IP_MULTICAST_LOOP, &val, sizeof(val))) {
                perror("setsockopt MULTICAST_LOOP");
                return 1;
        }

        addr.sin_addr.s_addr  = daddr;

        if (server) {
                for (i = 0; i < nbmsg; i++) {
                        alarm(timeout);
                        if (recv(fd,&i,sizeof(i),0) == -1) {
                                perror("recv");
                                return 1;
                        }
                        fprintf(stderr, ".");
                }
        } else {
                for (i = 0; i < nbmsg; i++) {
                        if (sendto(fd, &i, sizeof(i), MSG_CONFIRM,
                                   (const struct sockaddr*)&addr, len) == -1) {
                                perror("sendto");
                                return 1;
                        }
                        usleep(delay);
                }
        }

        fprintf(stderr," - done.\n");
        return 0;
}

int main(int argc, char* argv[])
{
        in_addr_t dest = inet_addr("234.5.6.7");
        int port = htons(10000);

        return run(argc > 1, dest, port, 0, 1000, 50000, 60);
}

-- 
