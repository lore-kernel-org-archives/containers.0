From: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Subject: Re: [PATCH 33/33] Enable netfilter in netns
Date: Thu, 02 Oct 2008 12:00:33 +0200
Message-ID: <48E49BC1.9060800__2347.92238702557$1222941836$gmane$org@trash.net>
References: <48C01046.2070704@trash.net>
	<1220842990-30500-33-git-send-email-adobriyan@gmail.com>
	<48E49068.5070305@trash.net>
	<20081002095112.GA31919@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20081002095112.GA31919-2ev+ksY9ol182hYKe6nXyg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Alexey Dobriyan wrote:
> On Thu, Oct 02, 2008 at 11:12:08AM +0200, Patrick McHardy wrote:
>   
>> Is there an easy way to test all this stuff?
>>     
>
> I used the following:
>
> 0) netns is currently mutually exclusive with sysfs, so depending on
>    sanity of distro initscripts booting sysfs-less kernel can be tricky.
>
>    In Gentoo, for example a) rm -rf /sys (sic!), b) RC_USE_FSTAB="yes",
>    c) RC_DEVICES="static" in /etc/conf.d/rc are needed.
>
> 1) netns creation tool (attached, some container guy posted it somewhere)
>
> 	# ns_exec -n /bin/sh
>
> 2) shutdown network in init_net
>
> 	sudo /etc/init.d/ntpd stop
> 	sudo /etc/init.d/sshd stop
> 	sudo /etc/init.d/iptables stop
> 	sudo /etc/init.d/ip6tables stop
> 	sudo /etc/init.d/net.eth1 stop
> 	sudo /etc/init.d/net.eth0 stop
>
> 3) move netdevices to netns
>
> 	ip l s dev eth0 netns "$1"
> 	ip l s dev eth1 netns "$1"
>
> 	where $1 is PID of shell from 1)
>
> 4) in netns start everything back
>
> 	sudo /etc/init.d/net.eth0 start
> 	sudo /etc/init.d/net.eth1 start
> 	sudo /etc/init.d/iptables start
> 	sudo /etc/init.d/ip6tables start
> 	sudo /etc/init.d/sshd start
> 	sudo /etc/init.d/ntpd start
>
> 5) at this point my usual NAT setup is back working for me and everything should
>    be like in init_net (modulo aforementioned exceptions) and
>    independent from init_net.
>
> Leaked netns are in /proc/slabinfo under "net_namespace".
>
> Some IPv6 printks can be annoying, so mute them.
>
> Object poisoning with SLUB won't work for irrelevant reasons, so use SLAB.
>
> Something like that.
>   

Thanks, I'll give it a try.
