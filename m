From: Konstantin Khlebnikov <koct9i-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: IPv4/IPv6 sysctl defaults in new namespace
Date: Mon, 15 Feb 2016 13:49:18 +0300
Message-ID: <CALYGNiNJ=LCyo4v7B1BUZH-27bc22ap-RQKpPQN7m0V3kBjkPw__25305.5897927426$1455533377$gmane$org@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linux Kernel Network Developers <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Cc: Vasily Averin <vvs-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>, Pavel Emelyanov <xemul-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

IPv6 initialized with default. That's ok.
IPv4 makes a copy from init_net. Looks like a bug, here
v2.6.24-2577-g752d14dc6aa9

root@zurg:~# sysctl net.ipv4.conf.all.forwarding=0
net.ipv6.conf.all.forwarding=0
net.ipv4.conf.all.forwarding = 0
net.ipv6.conf.all.forwarding = 0
root@zurg:~# unshare -n sysctl net.ipv4.conf.all.forwarding
net.ipv6.conf.all.forwarding
net.ipv4.conf.all.forwarding = 0
net.ipv6.conf.all.forwarding = 0
root@zurg:~# sysctl net.ipv4.conf.all.forwarding=1
net.ipv6.conf.all.forwarding=1
net.ipv4.conf.all.forwarding = 1
net.ipv6.conf.all.forwarding = 1
root@zurg:~# unshare -n sysctl net.ipv4.conf.all.forwarding
net.ipv6.conf.all.forwarding
net.ipv4.conf.all.forwarding = 1
net.ipv6.conf.all.forwarding = 0

This is nasty. Could we fix this or this bug set in stone?
