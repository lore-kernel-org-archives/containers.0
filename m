From: chris-SqNQQPNds68nxqbYAscKCQ@public.gmane.org
Subject: Re: Net containers config and usage
Date: Tue, 13 Jan 2009 13:47:47 -0800
Message-ID: <20090113214747.GA23742@versecorp.net>
References: <20090112223545.GA15781@versecorp.net>
	<20090112225140.GA29834@us.ibm.com>
	<20090113005436.GA26167@versecorp.net> <496C4EB0.30203@free.fr>
	<20090113142925.GA11767@us.ibm.com>
	<20090113191837.GA29900@versecorp.net> <496CF11A.7090908@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <496CF11A.7090908-GANU6spQydw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Jan 13, 2009 at 08:52:58PM +0100, Daniel Lezcano wrote:
> >I tried getting 2.6.26 and I have the same problem:
> >
> >[root@C100273 iproute2-2.6.26]# ip/ip link set eth4 netns 24755
> >RTNETLINK answers: Invalid argument
> >
> >I'm pretty certain I'm running the right "version" of the command.  It
> >does install it to /usr/sbin/ip, but if I run the version that came with 
> >the
> >distribution (in /sbin/ip), I get a different error reporting netns as 
> >garbage.
> >So.. since it at least parses the netns argument and sends the netlink 
> >request,
> >it at least seems to be making it to the kernel.
> >
> >Does the kernel.org version of 2.6.29-rc1 have everything I need?
> >
> >Any other ideas?
> >  
> Is eth4 a physical network device or a virtual device (like a tunnel) 
> renamed eth4 ?
> 
> Can you send the output of the "ip link" command and the value of
> /sys/class/net/eth4/features to check if the network device is not 
> flagged as a non-movable.
> 
> thanks.
>  -- Daniel

It's a physical device - uses the e1000e driver.
Here's the output of both commands.

[root@C100273 iproute2-2.6.26]# ip link
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue 
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast qlen 1000
    link/ether 00:1c:c4:dc:44:b2 brd ff:ff:ff:ff:ff:ff
3: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop qlen 1000
    link/ether 00:1c:c4:48:35:f5 brd ff:ff:ff:ff:ff:ff
4: eth2: <BROADCAST,MULTICAST> mtu 1500 qdisc noop qlen 1000
    link/ether 00:1c:c4:dc:44:b0 brd ff:ff:ff:ff:ff:ff
5: eth3: <BROADCAST,MULTICAST> mtu 1500 qdisc noop qlen 1000
    link/ether 00:1c:c4:48:35:f4 brd ff:ff:ff:ff:ff:ff
6: eth4: <BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast qlen 1000
    link/ether 00:1c:c4:48:35:f7 brd ff:ff:ff:ff:ff:ff
7: eth5: <BROADCAST,MULTICAST> mtu 1500 qdisc noop qlen 1000
    link/ether 00:1c:c4:48:35:f6 brd ff:ff:ff:ff:ff:ff
8: br1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue 
    link/ether 66:f4:32:9f:12:df brd ff:ff:ff:ff:ff:ff

[root@C100273 iproute2-2.6.26]# cat /sys/class/net/eth4/features
0x111ba9

Thanks,
Chris
