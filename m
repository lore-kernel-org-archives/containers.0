From: Minoru Usui <usui-vEbCzmPPqHe45+QrQBaojngSJqDPrsil@public.gmane.org>
Subject: Re: [HELP] for using class group classifier network controller
Date: Mon, 15 Jun 2009 17:18:14 +0900
Message-ID: <20090615171814.db942957.usui__23622.1909094185$1245054242$gmane$org@mxm.nes.nec.co.jp>
References: <9f8101c9ed80$b730b830$8310fe81@etri.info>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <9f8101c9ed80$b730b830$8310fe81-tRM8rG9f+DVhl2p70BpVqQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Chei-Yol Kim <gauri-mINagvnPBMnWF1p7bDn8Kw@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, tgraf-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, 15 Jun 2009 15:15:44 +0900
"Chei-Yol Kim" <gauri-mINagvnPBMnWF1p7bDn8Kw@public.gmane.org> wrote:

> 
> 
> >Hi, Cheiyol 
> > 
> >> # classid 1:10 
> >> 
> >> echo 0x1000A > /dev/cpuctl/foo/net_cls.classid 
> >> 
> >> #classid 1:20 
> >> 
> >> echo 0x10014 > /dev/cpuctl/bob/net_cls.classid 
> > 
> >(snip) 
> > 
> >> # add class 1:10 for foo group 
> >> 
> >> $TC class add dev eth0 parent 1:0 classid 1:10 htb rate 50mbit 
> >> 
> >> # add class 1:20 for bob group 
> >> 
> >> $TC class add dev eth0 parent 1:0 classid 1:20 htb rate 30mbit 
> >> 
> >> # default class 
> >> 
> >> $TC class add dev eth0 parent 1:0 classid 1:30 htb rate 10mbit 
> 
> >In class ID to use TC, both a major number and a minor number are hexadecimal. 
> >So 1:10 equals 0x00010010. 
> > 
> >I think, you should set 0x10010 to net_cls.classid if you classify to 1:10. 
> 
> 
> I have done this by your advice. But it didn't work.
> I followed the instructions by http://thread.gmane.org/gmane.linux.network/108551/focus=108661
> So I supposed classid 1:10 is the decimal number, so I set the 0xA0001 as 1:10.
>  
> I'm curious if this patch net_cls operates well in other's hands.
> How about you?
> Does your system using net_cls operate well?
> If then, would you let me know the environment and configuration of your system.
> I would reference your environment for solving my problem.

Which is your problem?

  a) network packet can't be classified into the class which is set to net_cls.classid

  b) network packet can be classified into the class which is set to net_cls.classid, 
     but its bandwidth limit doesn't work correctly.

If your problem is b), unfortunately I can't help you. 
Because I am a begginer of cls_cgroup, and I haven't tested enough.
(But I think I might be facing same problem.)

If your problem is a), you should check 'tc -s filter show'.
You can see the result of classifing by cls_cgroup.
I can classified to the class which is set to root's net_cls.classid.

Environment: 
  kernel: 2.6.30
  tc: iproute2-2.6.29-1 with tc/f_cgroup.c patch in latest git.
      (I think it's same, probably)

How to use:
  1) set to qdisc, class, filter

     # tc qdisc add dev bond0 root handle 1: htb default 30

     # tc class add dev bond0 parent 1:0 classid 1:10 htb rate 1mbit
     # tc class add dev bond0 parent 1:0 classid 1:20 htb rate 2mbit
     # tc class add dev bond0 parent 1:0 classid 1:30 htb rate 3mbit

     # tc filter add dev bond0 protocol ip parent 1: prio 1 handle 0x1 cgroup

     # tc -s class show dev bond0
     class htb 1:10 root prio 0 rate 1000Kbit ceil 1000Kbit burst 1724b cburst 1724b 
      Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)                         <- packet count is 0
      rate 0bit 0pps backlog 0b 0p requeues 0 
      lended: 0 borrowed: 0 giants: 0
      tokens: 13476 ctokens: 13476

     class htb 1:20 root prio 0 rate 2000Kbit ceil 2000Kbit burst 1849b cburst 1849b 
      Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0) 
      rate 0bit 0pps backlog 0b 0p requeues 0 
      lended: 0 borrowed: 0 giants: 0
      tokens: 7226 ctokens: 7226

     class htb 1:30 root prio 0 rate 3000Kbit ceil 3000Kbit burst 1974b cburst 1974b 
      Sent 25804 bytes 214 pkt (dropped 0, overlimits 0 requeues 0) 
      rate 3992bit 4pps backlog 0b 0p requeues 0 
      lended: 214 borrowed: 0 giants: 0
      tokens: 4851 ctokens: 4851

  2) mount cls_cgroup and set root's net_cls.classid

     # mount -t cgroup -onet_cls none /cgroup/net/
     # cd /cgroup/net/
     # ls
     net_cls.classid  notify_on_release  release_agent  tasks

     # echo 0x10010 > net_cls.classid                 # I want to classify 1:10
     # cat net_cls.classid 
     65552                                            # 65552 = 65536 + 16 = 0x10010

  3) using network

  4) check the packet which is classified to the class which is set to net_cls.classid.

     # /home/usui/src/iproute2-2.6.29-1/tc/tc -s class show dev bond0
     class htb 1:10 root prio 0 rate 1000Kbit ceil 1000Kbit burst 1724b cburst 1724b 
      Sent 11238 bytes 95 pkt (dropped 0, overlimits 0 requeues 0)                    <- increase packet count
      rate 2944bit 3pps backlog 0b 0p requeues 0 
      lended: 95 borrowed: 0 giants: 0
      tokens: 12601 ctokens: 12601

     class htb 1:20 root prio 0 rate 2000Kbit ceil 2000Kbit burst 1849b cburst 1849b 
      Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0) 
      rate 0bit 0pps backlog 0b 0p requeues 0 
      lended: 0 borrowed: 0 giants: 0
      tokens: 7226 ctokens: 7226

     class htb 1:30 root prio 0 rate 3000Kbit ceil 3000Kbit burst 1974b cburst 1974b 
      Sent 46092 bytes 342 pkt (dropped 0, overlimits 0 requeues 0) 
      rate 320bit 0pps backlog 0b 0p requeues 0 
      lended: 342 borrowed: 0 giants: 0
      tokens: 5017 ctokens: 5017


-- 
Minoru Usui <usui-vEbCzmPPqHe45+QrQBaojngSJqDPrsil@public.gmane.org>
