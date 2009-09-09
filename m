From: Mathieu Lacage <mathieu.lacage-0GlwE4rufLnvuXihggDW+w@public.gmane.org>
Subject: netns+qdisc+veth
Date: Wed, 09 Sep 2009 09:03:29 +0200
Message-ID: <1252479809.3029.5.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
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
To: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

hi,

I am trying to create a network namespace with a vethX device in it and
a special qdisc but without much luck. I wonder if this is something
which is unsupported or is just a bug.

[mathieu@mathieu-laptop netns]$ uname -a
Linux mathieu-laptop 2.6.30.5-43.fc11.x86_64 #1 SMP Thu Aug 27 21:39:52
EDT 2009 x86_64 x86_64 x86_64 GNU/Linux

shell in default namespace:

[mathieu@mathieu-laptop netns]$ sudo ip link add type veth
[mathieu@mathieu-laptop netns]$ sudo tc qdisc add dev veth0 root netem
delay 100ms
[mathieu@mathieu-laptop netns]$ sudo ip link set dev veth0 netns 3104
[mathieu@mathieu-laptop netns]$ 


shell in other network namespace:

[mathieu@mathieu-laptop netns]$ sudo ./netunshare /bin/bash
[sudo] password for mathieu: 
[root@mathieu-laptop netns]# echo $$
3104
[root@mathieu-laptop netns]# sudo ip link show veth0
11: veth0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN qlen
1000
    link/ether 9a:bb:18:b6:1b:06 brd ff:ff:ff:ff:ff:ff
[root@mathieu-laptop netns]# sudo tc qdisc add dev veth0 root netem
delay 100ms
RTNETLINK answers: Invalid argument
[root@mathieu-laptop netns]# 

any kind of idea would be welcome.

Mathieu
