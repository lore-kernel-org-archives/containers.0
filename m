From: Alex Bligh <alex-rWA27mgs/Jz10XsdtD+oqA@public.gmane.org>
Subject: Kernel oops on 2.6.38 on destroying a container
Date: Wed, 07 Sep 2011 13:55:33 +0100
Message-ID: <F7CF23E684C645500BB4F7DE@nimrod.local>
Reply-To: Alex Bligh <alex-rWA27mgs/Jz10XsdtD+oqA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

We are seeing oops like this from 2.6.38-11 Ubuntu on deleting containers.

This one was somewhat complicated (but we grabbed the oops).
The trace below happened destroying a container. I believe the iptables
rules including conntrack rules would have been deleted immediately
before the container process exited; devices evrrXXXX and evrlXXXX
are veth pairs that would also just have been destroyed)

My colleague can replicate this on different hardware (his desktop) using
  lxc-create -n foo
  lxc-start -n foo
Send a ^C - entire system crashes. No exciting container activity
at all.

I haven't seen this on 2.6.32. Any ideas what it might be?

-- 
Alex Bligh


Sep  7 12:30:37 node-10-157-128-101 kernel: [12618.720258] IN=evrr-000000 
OUT= MAC=33:33:00:00:00:01:00:15:17:dd:af:37:86:dd 
SRC=fe80:0000:0000:0000:58c9:f1ff:fec3:01fc 
DST=ff02:0000:0000:0000:0000:0000:0000:0001 LEN=72 TC=0 HOPLIMIT=1 
FLOWLBL=0 PROTO=ICMPv6 TYPE=130 CODE=0
Sep  7 12:32:09 node-10-157-128-101 kernel: [12710.880245] IN=evrr-000002 
OUT= MAC=33:33:00:00:00:01:5e:68:7c:df:f9:b3:86:dd 
SRC=fe80:0000:0000:0000:6491:30ff:feff:f3ed 
DST=ff02:0000:0000:0000:0000:0000:0000:0001 LEN=72 TC=0 HOPLIMIT=1 
FLOWLBL=0 PROTO=ICMPv6 TYPE=130 CODE=0
Sep  7 12:32:43 node-10-157-128-101 kernel: [12744.160256] IN=evrr-000000 
OUT= MAC=33:33:00:00:00:01:00:15:17:dd:af:37:86:dd 
SRC=fe80:0000:0000:0000:58c9:f1ff:fec3:01fc 
DST=ff02:0000:0000:0000:0000:0000:0000:0001 LEN=72 TC=0 HOPLIMIT=1 
FLOWLBL=0 PROTO=ICMPv6 TYPE=130 CODE=0
Sep  7 12:34:15 node-10-157-128-101 kernel: [12836.320246] IN=evrr-000002 
OUT= MAC=33:33:00:00:00:01:5e:68:7c:df:f9:b3:86:dd 
SRC=fe80:0000:0000:0000:6491:30ff:feff:f3ed 
DST=ff02:0000:0000:0000:0000:0000:0000:0001 LEN=72 TC=0 HOPLIMIT=1 
FLOWLBL=0 PROTO=ICMPv6 TYPE=130 CODE=0
Sep  7 12:34:48 node-10-157-128-101 kernel: [12869.600263] IN=evrr-000000 
OUT= MAC=33:33:00:00:00:01:00:15:17:dd:af:37:86:dd 
SRC=fe80:0000:0000:0000:58c9:f1ff:fec3:01fc 
DST=ff02:0000:0000:0000:0000:0000:0000:0001 LEN=72 TC=0 HOPLIMIT=1 
FLOWLBL=0 PROTO=ICMPv6 TYPE=130 CODE=0
Sep  7 12:36:20 node-10-157-128-101 kernel: [12961.760251] IN=evrr-000002 
OUT= MAC=33:33:00:00:00:01:5e:68:7c:df:f9:b3:86:dd 
SRC=fe80:0000:0000:0000:6491:30ff:feff:f3ed 
DST=ff02:0000:0000:0000:0000:0000:0000:0001 LEN=72 TC=0 HOPLIMIT=1 
FLOWLBL=0 PROTO=ICMPv6 TYPE=130 CODE=0
Sep  7 12:36:27 node-10-157-128-101 kernel: [12968.370970] device 
evrl-000000 left promiscuous mode
Sep  7 12:36:27 node-10-157-128-101 kernel: [12968.370983] pvip-bridge: 
port 1(evrl-000000) entering forwarding state
Sep  7 12:36:28 node-10-157-128-101 kernel: [12969.439318] 70: port 
3(evrl-000002) entering forwarding state
Sep  7 12:36:28 node-10-157-128-101 kernel: [12969.840254] 70: port 
3(evrl-000002) entering disabled state
Sep  7 12:36:57 node-10-157-128-101 kernel: [12998.215331] 
ADDRCONF(NETDEV_UP): dummy: link is not ready
Sep  7 12:36:57 node-10-157-128-101 kernel: [12998.228780] 
ADDRCONF(NETDEV_CHANGE): dummy: link becomes ready
Sep  7 12:36:57 node-10-157-128-101 kernel: [12998.529428] 
ADDRCONF(NETDEV_UP): evrl-000000: link is not ready
Sep  7 12:36:57 node-10-157-128-101 kernel: [12998.564510] 
ADDRCONF(NETDEV_CHANGE): evrl-000000: link becomes ready
Sep  7 12:36:57 node-10-157-128-101 kernel: [12998.769811] 
ADDRCONF(NETDEV_UP): evrl-000002: link is not ready
Sep  7 12:36:57 node-10-157-128-101 kernel: [12998.806326] 
ADDRCONF(NETDEV_CHANGE): evrl-000002: link becomes ready
Sep  7 12:36:57 node-10-157-128-101 kernel: [12998.806907] device 
evrl-000000 entered promiscuous mode
Sep  7 12:36:57 node-10-157-128-101 kernel: [12998.806982] pvip-bridge: 
port 1(evrl-000000) entering forwarding state
Sep  7 12:36:57 node-10-157-128-101 kernel: [12998.806989] pvip-bridge: 
port 1(evrl-000000) entering forwarding state
Sep  7 12:36:57 node-10-157-128-101 kernel: [12998.810269] IN=evrr-000000 
OUT= MAC=33:33:00:00:00:01:00:15:17:dd:af:37:86:dd 
SRC=fe80:0000:0000:0000:58c9:f1ff:fec3:01fc 
DST=ff02:0000:0000:0000:0000:0000:0000:0001 LEN=72 TC=0 HOPLIMIT=1 
FLOWLBL=0 PROTO=ICMPv6 TYPE=130 CODE=0
Sep  7 12:37:07 node-10-157-128-101 kernel: [13008.742963] device 
evrl-000000 left promiscuous mode
Sep  7 12:37:07 node-10-157-128-101 kernel: [13008.742975] pvip-bridge: 
port 1(evrl-000000) entering forwarding state
Sep  7 12:37:15 node-10-157-128-101 kernel: [13016.820136] BUG: unable to 
handle kernel NULL pointer dereference at 0000000000000274
Sep  7 12:37:15 node-10-157-128-101 kernel: [13016.820281] IP: 
[<ffffffff81507269>] netlink_has_listeners+0x9/0x50
Sep  7 12:37:15 node-10-157-128-101 kernel: [13016.820394] PGD 90eb2c067 
PUD 90e760067 PMD 0
Sep  7 12:37:15 node-10-157-128-101 kernel: [13016.820487] Oops: 0000 [#1] 
SMP
Sep  7 12:37:15 node-10-157-128-101 kernel: [13016.820554] last sysfs file: 
/sys/devices/virtual/block/dm-0/stat
Sep  7 12:37:15 node-10-157-128-101 kernel: [13016.820651] CPU 0
Sep  7 12:37:15 node-10-157-128-101 kernel: [13016.820680] Modules linked 
in: nf_conntrack_netlink nfnetlink veth ip6t_LOG nf_conntrack_ipv6 
nf_defrag_ipv6 ip6table_filter ip6_tables ipt_LOG xt_limit xt_state 
xt_tcpudp iptable_filter ipt_MASQUERADE iptable_nat nf_nat 
nf_conntrack_ipv4 nf_conntrack nf_defrag_ipv4 iptable_mangle ip_tables 
ebt_ip ebtable_filter ebtables x_tables ib_iser rdma_cm ib_cm iw_cm ib_sa 
ib_mad ib_core ib_addr iscsi_tcp libiscsi_tcp libiscsi scsi_transport_iscsi 
bonding usbhid hid kvm_amd ghes kvm radeon ttm serio_raw amd64_edac_mod 
e1000e mptsas mptscsih mptbase drm_kms_helper scsi_transport_sas drm dcdbas 
i2c_piix4 i2c_algo_bit bridge edac_core k10temp edac_mce_amd hed shpchp 
8021q garp stp ixgbe dca mdio [last unloaded: scsi_transport_iscsi]
Sep  7 12:37:15 node-10-157-128-101 kernel: [13016.822113]
Sep  7 12:37:15 node-10-157-128-101 kernel: [13016.822137] Pid: 27390, 
comm: kworker/u:1 Not tainted 2.6.38-10-server #46~lucid1-Ubuntu Dell Inc. 
PowerEdge R905/0K552T
Sep  7 12:37:15 node-10-157-128-101 kernel: [13016.822344] RIP: 
0010:[<ffffffff81507269>]  [<ffffffff81507269>] 
netlink_has_listeners+0x9/0x50
Sep  7 12:37:15 node-10-157-128-101 kernel: [13016.822486] RSP: 
0018:ffff8802f48efbb0  EFLAGS: 00010246
Sep  7 12:37:15 node-10-157-128-101 kernel: [13016.822568] RAX: 
ffff88090e960000 RBX: ffff8802ee118000 RCX: 000000000000ffff
Sep  7 12:37:15 node-10-157-128-101 kernel: [13016.822678] RDX: 
0000000000000004 RSI: 0000000000000003 RDI: 0000000000000000
Sep  7 12:37:15 node-10-157-128-101 kernel: [13016.822787] RBP: 
ffff8802f48efbb0 R08: 0000000000000000 R09: 0000000000000000
Sep  7 12:37:15 node-10-157-128-101 kernel: [13016.822896] R10: 
0000000000000001 R11: 00000000ffffffff R12: ffff8802f48efc70
Sep  7 12:37:15 node-10-157-128-101 kernel: [13016.823005] R13: 
ffff8802ee118000 R14: 0000000000000000 R15: 0000000000000004
Sep  7 12:37:15 node-10-157-128-101 kernel: [13016.823116] FS: 
00007ff8f9141710(0000) GS:ffff8800d7800000(0000) knlGS:0000000000000000
Sep  7 12:37:15 node-10-157-128-101 kernel: [13016.823243] CS:  0010 DS: 
0000 ES: 0000 CR0: 000000008005003b
Sep  7 12:37:15 node-10-157-128-101 kernel: [13016.823330] CR2: 
0000000000000274 CR3: 000000090e8e3000 CR4: 00000000000006f0
Sep  7 12:37:15 node-10-157-128-101 kernel: [13016.823439] DR0: 
0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
Sep  7 12:37:15 node-10-157-128-101 kernel: [13016.823549] DR3: 
0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Sep  7 12:37:15 node-10-157-128-101 kernel: [13016.828501] Process 
kworker/u:1 (pid: 27390, threadinfo ffff8802f48ee000, task ffff8802f7a22dc0)
Sep  7 12:37:15 node-10-157-128-101 kernel: [13016.830020] Stack:
Sep  7 12:37:15 node-10-157-128-101 kernel: [13016.830020] 
ffff8802f48efbc0 ffffffffa0406155 ffff8802f48efc50 ffffffffa02b2be3
Sep  7 12:37:15 node-10-157-128-101 kernel: [13016.830020] 
0000000000000000 0000000000000003 ffff8802f48efc10 0000000094d75fe3
Sep  7 12:37:15 node-10-157-128-101 kernel: [13016.830020] 
000000041fa82080 ffff88090e960000 0000000200000003 ffff880200000000
Sep  7 12:37:15 node-10-157-128-101 kernel: [13016.830020] Call Trace:
Sep  7 12:37:15 node-10-157-128-101 kernel: [13016.830020] 
[<ffffffffa0406155>] nfnetlink_has_listeners+0x15/0x20 [nfnetlink]
Sep  7 12:37:15 node-10-157-128-101 kernel: [13016.830020] 
[<ffffffffa02b2be3>] ctnetlink_conntrack_event+0x643/0x810 
[nf_conntrack_netlink]
Sep  7 12:37:15 node-10-157-128-101 kernel: [13016.830020] 
[<ffffffff81038d09>] ? default_spin_lock_flags+0x9/0x10
Sep  7 12:37:15 node-10-157-128-101 kernel: [13016.830020] 
[<ffffffffa01df359>] death_by_timeout+0xb9/0x160 [nf_conntrack]
Sep  7 12:37:15 node-10-157-128-101 kernel: [13016.830020] 
[<ffffffffa01de280>] ? kill_all+0x0/0x10 [nf_conntrack]
Sep  7 12:37:15 node-10-157-128-101 kernel: [13016.830020] 
[<ffffffffa01df478>] nf_ct_iterate_cleanup+0x78/0x90 [nf_conntrack]
Sep  7 12:37:15 node-10-157-128-101 kernel: [13016.830020] 
[<ffffffff814da300>] ? cleanup_net+0x0/0x1c0
Sep  7 12:37:15 node-10-157-128-101 kernel: [13016.830020] 
[<ffffffffa01df4c1>] nf_conntrack_cleanup_net+0x31/0x110 [nf_conntrack]
Sep  7 12:37:15 node-10-157-128-101 kernel: [13016.830020] 
[<ffffffffa01df5c7>] nf_conntrack_cleanup+0x27/0x60 [nf_conntrack]
Sep  7 12:37:15 node-10-157-128-101 kernel: [13016.830020] 
[<ffffffffa01e11ca>] nf_conntrack_net_exit+0x4a/0x70 [nf_conntrack]
Sep  7 12:37:15 node-10-157-128-101 kernel: [13016.830020] 
[<ffffffff814da026>] ops_exit_list+0x36/0x70
Sep  7 12:37:15 node-10-157-128-101 kernel: [13016.830020] 
[<ffffffff814da40b>] cleanup_net+0x10b/0x1c0
Sep  7 12:37:15 node-10-157-128-101 kernel: [13016.830020] 
[<ffffffff8107f2d3>] process_one_work+0x123/0x450
Sep  7 12:37:15 node-10-157-128-101 kernel: [13016.830020] 
[<ffffffff81082467>] worker_thread+0x177/0x420
Sep  7 12:37:15 node-10-157-128-101 kernel: [13016.830020] 
[<ffffffff810822f0>] ? worker_thread+0x0/0x420
Sep  7 12:37:15 node-10-157-128-101 kernel: [13016.830020] 
[<ffffffff81086686>] kthread+0x96/0xa0
Sep  7 12:37:15 node-10-157-128-101 kernel: [13016.830020] 
[<ffffffff8100ce64>] kernel_thread_helper+0x4/0x10
Sep  7 12:37:15 node-10-157-128-101 kernel: [13016.830020] 
[<ffffffff810865f0>] ? kthread+0x0/0xa0
Sep  7 12:37:15 node-10-157-128-101 kernel: [13016.830020] 
[<ffffffff8100ce60>] ? kernel_thread_helper+0x0/0x10
Sep  7 12:37:15 node-10-157-128-101 kernel: [13016.830020] Code: 00 00 f6 
82 74 02 00 00 08 74 b5 49 89 ce ba 01 00 00 00 e9 5f ff ff ff 66 2e 0f 1f 
84 00 00 00 00 00 55 48 89 e5 66 66 66 66 90 <f6> 87 74 02 00 00 01 74 30 
0f b6 87 21 01 00 00 83 ee 01 48 8d
Sep  7 12:37:15 node-10-157-128-101 kernel: [13016.830020] RIP 
[<ffffffff81507269>] netlink_has_listeners+0x9/0x50
Sep  7 12:37:15 node-10-157-128-101 kernel: [13016.830020]  RSP 
<ffff8802f48efbb0>
Sep  7 12:37:15 node-10-157-128-101 kernel: [13016.830020] CR2: 
0000000000000274
Sep  7 12:37:15 node-10-157-128-101 kernel: [13016.982916] ---[ end trace 
d81ff2d8100f021e ]---
