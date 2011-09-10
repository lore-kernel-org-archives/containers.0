From: Alex Bligh <alex-rWA27mgs/Jz10XsdtD+oqA@public.gmane.org>
Subject: [PATCH] Fix repeatable Oops on container destroy with conntrack
Date: Sat, 10 Sep 2011 19:48:43 +0100
Message-ID: <2184C0CE5A5EDC94CDDA5053__40674.2786210545$1315680646$gmane$org@Ximines.local>
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
To: netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netfilter-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, coreteam-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Linux
List-Id: containers.vger.kernel.org

Problem:

A repeatable Oops can be caused if a container with networking
unshared is destroyed when it has nf_conntrack entries yet to expire.

A copy of the oops follows below. A perl program generating the oops
repeatably is attached inline below.

Analysis:

The oops is called from cleanup_net when the namespace is
destroyed. conntrack iterates through outstanding events and calls
death_by_timeout on each of them, which in turn produces a call to
ctnetlink_conntrack_event. This calls nf_netlink_has_listeners, which
oopses because net->nfnl is NULL.

The perl program generates the container through fork() then
clone(NS_NEWNET). I does not explicitly	set up netlink
explicitly set up netlink, but I presume it was set up else net->nfnl
would have been NULL earlier (i.e. when an earlier connection
timed out). This would thus suggest that net->nfnl is made NULL
during the destruction of the container, which I think is done by
nfnetlink_net_exit_batch.

I can see that the various subsystems are deinitialised in the opposite
order to which the relevant register_pernet_subsys calls are called,
and both nf_conntrack and nfnetlink_net_ops register their relevant
subsystems. If nfnetlink_net_ops registered later than nfconntrack,
then its exit routine would have been called first, which would cause
the oops described. I am not sure there is anything to prevent this
happening in a container environment.

Whilst there's perhaps a more complex problem revolving around ordering
of subsystem deinit, it seems to me that missing a netlink event on a
container that is dying is not a disaster. An early check for net->nfnl
being non-NULL in ctnetlink_conntrack_event appears to fix this. There
may remain a potential race condition if it becomes NULL immediately
after being checked (I am not sure any lock is held at this point or
how synchronisation for subsystem deinitialization works).

Patch:

The patch attached should apply on everything from 2.6.26 (if not before)
onwards; it appears to be a problem on all kernels. This was taken against
Ubuntu-3.0.0-11.17 which is very close to 3.0.4. I have torture-tested it
with the above perl script for 15 minutes or so; the perl script hung the
machine within 20 seconds without this patch.

Applicability:

If this is the right solution, it should be applied to all stable kernels
as well as head. Apart from the minor overhead of checking one variable
against NULL, it can never 'do the wrong thing', because if net->nfnl
is NULL, an oops will inevitably result. Therefore, checking is a reasonable
thing to do unless it can be proven than net->nfnl will never be NULL.

-- 
Alex Bligh

Check net->nfnl for NULL in ctnetlink_conntrack_event to avoid Oops on container destroy

Signed-off-by: Alex Bligh <alex-rWA27mgs/Jz10XsdtD+oqA@public.gmane.org>
---
 net/netfilter/nf_conntrack_netlink.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 482e90c..0790d0a 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -570,6 +570,11 @@ ctnetlink_conntrack_event(unsigned int events, struct nf_ct_event *item)
 		return 0;

 	net = nf_ct_net(ct);
+
+	/* container deinit, netlink may have died before death_by_timeout */
+	if (!net->nfnl)
+		return 0;
+
 	if (!item->report && !nfnetlink_has_listeners(net, group))
 		return 0;

-- 
1.7.5.4


Perl script to replicate bug (and demonstrate fixed)

#!/usr/bin/perl

# Reprequisites:
# Install Linux::Unshare from CPAN
# Ensure conntrack is installed

use strict;
use warnings;

use POSIX "setsid";
use Linux::Unshare qw(unshare :clone); # get this from CPAN

# Parent returns PID, child returns 0
sub daemonize {
    chdir("/")                      || die "can't chdir to /: $!";
    open(STDIN,  "< /dev/null")     || die "can't read /dev/null: $!";
    open(STDOUT, "> /dev/null")     || die "can't write to /dev/null: $!";
    defined(my $pid = fork())       || die "can't fork: $!";
    return $pid if $pid;               # non-zero now means I am the parent
    (setsid() != -1)                || die "Can't start a new session: $!";
    open(STDERR, ">&STDOUT")        || die "can't dup stdout: $!";
    return 0;
}

sub docontainer
{
    print STDERR "Child: container starting\n";
    sleep (5);
    print STDERR "Child: setting ip addresses\n";
    system("ip link set vethr up");
    system("ip link show");
    system("ip addr add 10.99.99.2/24 dev vethr");
    system("ip addr add 127.0.0.1/8 dev lo");
    system("ip link set lo up");
    system("echo 1 > /proc/sys/net/ipv4/ip_forward");
    system("echo 1 > /proc/sys/net/ipv4/conf/all/forwarding");
    system("echo 1 > /proc/sys/net/ipv6/conf/all/forwarding");

    system("echo 2 > /proc/sys/net/ipv4/conf/all/rp_filter");
    system("echo 0 > /proc/sys/net/ipv4/conf/all/accept_source_route");
    system("echo 0 > /proc/sys/net/ipv4/conf/all/send_redirects");
    system("echo 0 > /proc/sys/net/ipv4/conf/all/accept_redirects");
    system("echo 1 > /proc/sys/net/ipv4/conf/all/proxy_arp");
    system("iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT");
    system("iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT");
    print STDERR "Child: pinging parent and running conntrack\n";
    while (1)
    {
	system("conntrack -L");
	system("ping -n -c1 10.99.99.2");
	sleep(1);
    }
    exit(0);
}

sub startcontainer
{
    system("ip link add vethl type veth peer name vethr");
    system("ip addr add 10.99.99.1/24 dev vethl");
    system("ip link set vethl up");

    print "Parent: Start container\n";

    defined(my $cpid = fork())       || die "can't fork: $!";
	
    if (!$cpid)
    {
	print STDERR "Child: starting\n";
	unshare(CLONE_NEWNET);
	docontainer();
	exit 0;
    }
	
    print STDERR "Parent: Container started pid $cpid\n";
    system("ip addr show | fgrep veth");
    sleep(1);
    print STDERR "Parent: running ip link set vethr netns $cpid\n";
    (system("ip link set vethr netns $cpid") ==0) || print STDERR "WARNING!: ip link netns failed\n";
    sleep(1);
    system("ip addr show | fgrep veth");
    print STDERR "Parent: Moved vethr, parent pinging child\n";
    system("ping -n -c5 10.99.99.2");
    print STDERR "Parent: Moved vethr, ping done\n";
    sleep(2);
    system("kill -KILL $cpid");
}

while (1)
{
    startcontainer;
}


The oops:

root@node-10-157-128-100:~# uname -a
Linux node-10-157-128-100 3.0.0-10-server #16-Ubuntu SMP Fri Sep 2 18:51:05 UTC 2011 x86_64 GNU/Linux


Sep  9 14:30:56 node-10-157-128-100 kernel: [79418.880263] IN=evrr-000000 OUT= MAC=33:33:00:00:00:01:00:15:17:a6:cd:49:86:dd SRC=fe80:0000:0000:0000:0215:17ff:fea6:cd
49 DST=ff02:0000:0000:0000:0000:0000:0000:0001 LEN=72 TC=0 HOPLIMIT=1 FLOWLBL=0 PROTO=ICMPv6 TYPE=130 CODE=0
Sep  9 14:30:56 node-10-157-128-100 kernel: [79418.880332] IN=evrr-000008 OUT= MAC=33:33:00:00:00:01:0e:f1:9d:53:b5:1e:86:dd SRC=fe80:0000:0000:0000:58e8:01ff:fe0b:0d
b2 DST=ff02:0000:0000:0000:0000:0000:0000:0001 LEN=72 TC=0 HOPLIMIT=1 FLOWLBL=0 PROTO=ICMPv6 TYPE=130 CODE=0
Sep  9 14:33:01 node-10-157-128-100 kernel: [79544.160335] IN=evrr-000000 OUT= MAC=33:33:00:00:00:01:00:15:17:a6:cd:49:86:dd SRC=fe80:0000:0000:0000:0215:17ff:fea6:cd
49 DST=ff02:0000:0000:0000:0000:0000:0000:0001 LEN=72 TC=0 HOPLIMIT=1 FLOWLBL=0 PROTO=ICMPv6 TYPE=130 CODE=0
Sep  9 14:33:01 node-10-157-128-100 kernel: [79544.160417] IN=evrr-000008 OUT= MAC=33:33:00:00:00:01:0e:f1:9d:53:b5:1e:86:dd SRC=fe80:0000:0000:0000:58e8:01ff:fe0b:0d
b2 DST=ff02:0000:0000:0000:0000:0000:0000:0001 LEN=72 TC=0 HOPLIMIT=1 FLOWLBL=0 PROTO=ICMPv6 TYPE=130 CODE=0
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.780106] BUG: unable to handle kernel NULL pointer dereference at 0000000000000274
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.780274] IP: [<ffffffff81511959>] netlink_has_listeners+0x9/0x50
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.780398] PGD 0
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.780441] Oops: 0000 [#1] SMP
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.780515] CPU 7
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.780547] Modules linked in: ipt_REJECT nf_conntrack_netlink nfnetlink dm_round_robin dm_multipath veth ip6t_LOG nf_conntrack_ipv6 nf_defrag_ipv6 ip6table_filter ip6_tables ipt_LOG xt_limit xt_state xt_tcpudp iptable_filter ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_conntrack nf_defrag_ipv4 iptable_mangle ip_tables ebt_ip ebtable_filter ebtables x_tables ib_iser rdma_cm ib_cm iw_cm ib_sa ib_mad ib_core ib_addr iscsi_tcp libiscsi_tcp 
libiscsi scsi_transport_iscsi bonding usb_storage uas joydev usbhid hid radeon ttm ses enclosure drm_kms_helper drm kvm_amd psmouse kvm amd64_edac_mod dcdbas serio_raw e1000e megaraid_sas edac_core i2c_algo_bit k8temp edac_mce_amd pata_serverworks shpchp i2c_piix4 bridge 8021q garp stp ixgbe dca mdio [last unloaded: multipath]
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.786143]
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.790033] Pid: 25711, comm: kworker/u:2 Not tainted 3.0.0-10-server #16-Ubuntu Dell Inc. PowerEdge 6950/0GK775
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.790033] RIP: 0010:[<ffffffff81511959>]  [<ffffffff81511959>] netlink_has_listeners+0x9/0x50
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.790033] RSP: 0018:ffff880801109c00  EFLAGS: 00010246
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.790033] RAX: 0000000000000004 RBX: ffff880c0f796af8 RCX: 000000000000ffff
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.790033] RDX: ffff8803f1700000 RSI: 0000000000000003 RDI: 0000000000000000
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.790033] RBP: ffff880801109c00 R08: ffff880801108000 R09: 0000000000000000
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.790033] R10: 0000000000000001 R11: dead000000200200 R12: ffff880801109cb0
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.790033] R13: ffff880c0f796af8 R14: ffff880c0f796af8 R15: 0000000000000004
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.790033] FS: 00007fe2d2d57710(0000) GS:ffff881027d00000(0000) knlGS:0000000000000000
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.790033] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.790033] CR2: 0000000000000274 CR3: 0000000001c03000 CR4: 00000000000006e0
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.790033] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.790033] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.790033] Process kworker/u:2 (pid: 25711, threadinfo ffff880801108000, task ffff88080f5f9720)
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.790033] ffff880801109c10 ffffffffa048f145 ffff880801109c90 ffffffffa049943b
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.790033] ffff880801109c70 7fffffffffffffff ffff8803f1700000 0000000300000004
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.790033] ffff880800000000 ffffffff00000002 ffff880c0fc80000 ffff880c0f796b98
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.790033] Call Trace:
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.790033] [<ffffffffa048f145>] nfnetlink_has_listeners+0x15/0x20 [nfnetlink]
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.790033] [<ffffffffa049943b>] ctnetlink_conntrack_event+0x5cb/0x890 [nf_conntrack_netlink]
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.790033] [<ffffffff814e34d0>] ? net_drop_ns+0x50/0x50
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.790033] [<ffffffffa04062d8>] death_by_timeout+0xc8/0x1c0 [nf_conntrack]
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.790033] [<ffffffffa0405270>] ? nf_conntrack_attach+0x50/0x50 [nf_conntrack]
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.790033] [<ffffffffa0406448>] nf_ct_iterate_cleanup+0x78/0x90 [nf_conntrack]
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.790033] [<ffffffffa0406491>] nf_conntrack_cleanup_net+0x31/0x100 [nf_conntrack]
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.790033] [<ffffffffa0407f97>] nf_conntrack_cleanup+0x27/0x60 [nf_conntrack]
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.790033] [<ffffffffa04081f0>] nf_conntrack_net_exit+0x60/0x80 [nf_conntrack]
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.790033] [<ffffffff814e2d28>] ops_exit_list.isra.1+0x38/0x60
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.790033] [<ffffffff814e35e2>] cleanup_net+0x112/0x1b0
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.790033] [<ffffffff8107bb0a>] process_one_work+0x11a/0x480
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.790033] [<ffffffff8107c7d5>] worker_thread+0x165/0x370
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.790033] [<ffffffff8107c670>] ? manage_workers.isra.30+0x130/0x130
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.790033] [<ffffffff81080c1c>] kthread+0x8c/0xa0
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.950699] [<ffffffff81607c24>] kernel_thread_helper+0x4/0x10
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.950699] [<ffffffff81080b90>] ? flush_kthread_worker+0xa0/0xa0
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.950699] [<ffffffff81607c20>] ? gs_change+0x13/0x13
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.950699] Code: 00 00 48 85 f6 74 0c 48 83 ee 01 48 89 df e8 cf f6 ff ff 48 8b 5d f0 4c 8b 65 f8 c9 c3 0f 1f 44 00 00 55 48 89 e5 66 66 66 66 90 <f6> 87 74 02 00 00 01 74 30 0f b6 87 21 01 00 00 4c 8b 05 38 8d
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.950699] RIP [<ffffffff81511959>] netlink_has_listeners+0x9/0x50
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.950699]  RSP <ffff880801109c00>
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.950699] CR2: 0000000000000274
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.954892] ---[ end trace 73540474560834fd ]---
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.954941] BUG: unable to handle kernel paging request at fffffffffffffff8
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.954945] IP: [<ffffffff810810b1>] kthread_data+0x11/0x20
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.954950] PGD 1c05067 PUD 1c06067 PMD 0
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.954954] Oops: 0000 [#2] SMP
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.954957] CPU 7
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.954959] Modules linked in: ipt_REJECT nf_conntrack_netlink nfnetlink dm_round_robin dm_multipath veth ip6t_LOG nf_conntrack_ipv6 nf_defrag_ipv6 ip6table_filter ip6_tables ipt_LOG xt_limit xt_state xt_tcpudp iptable_filter ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_conntrack nf_defrag_ipv4 iptable_mangle ip_tables ebt_ip ebtable_filter ebtables x_tables ib_iser rdma_cm ib_cm iw_cm ib_sa ib_mad ib_core ib_addr iscsi_tcp libiscsi_tcp 
libiscsi scsi_transport_iscsi bonding usb_storage uas joydev usbhid hid radeon ttm ses enclosure drm_kms_helper drm kvm_amd psmouse kvm amd64_edac_mod dcdbas serio_raw e1000e megaraid_sas edac_core i2c_algo_bit k8temp edac_mce_amd pata_serverworks shpchp i2c_piix4 bridge 8021q garp stp ixgbe dca mdio [last unloaded: multipath]
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.955032]
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.955034] Pid: 25711, comm: kworker/u:2 Tainted: G      D     3.0.0-10-server #16-Ubuntu Dell Inc. PowerEdge 6950/0GK775
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.955040] RIP: 0010:[<ffffffff810810b1>]  [<ffffffff810810b1>] kthread_data+0x11/0x20
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.955046] RSP: 0018:ffff880801109870  EFLAGS: 00010096
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.955048] RAX: 0000000000000000 RBX: 0000000000000007 RCX: 0000000000000007
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.955051] RDX: 0000000000000007 RSI: 0000000000000007 RDI: ffff88080f5f9720
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.955054] RBP: ffff880801109888 R08: 0000000000989680 R09: 0000000000000001
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.955057] R10: 0000000000000400 R11: ffff88080f65c118 R12: 0000000000000007
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.955060] R13: ffff88080f5f9ae8 R14: 0000000000000000 R15: 0000000000000246
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.955064] FS: 00007fe2d2d57710(0000) GS:ffff881027d00000(0000) knlGS:0000000000000000
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.955067] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.955070] CR2: fffffffffffffff8 CR3: 0000000001c03000 CR4: 00000000000006e0
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.955073] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.955076] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.955079] Process kworker/u:2 (pid: 25711, threadinfo ffff880801108000, task ffff88080f5f9720)
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.955082] Stack:
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.955083] ffffffff8107cd25 ffff880801109888 ffff881027d12a40 ffff880801109908
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.955089] ffffffff815fc737 ffff88080f5f9720 0000000000000000 ffff880801109fd8
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.955094] ffff880801109fd8 ffff880801109fd8 0000000000012a40 0000000000000011
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.955100] Call Trace:
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.955103] [<ffffffff8107cd25>] ? wq_worker_sleeping+0x15/0xa0
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.955108] [<ffffffff815fc737>] schedule+0x637/0x770
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.955114] [<ffffffff81063053>] do_exit+0x273/0x440
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.955119] [<ffffffff815ffbd0>] oops_end+0xb0/0xf0
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.955124] [<ffffffff815e7104>] no_context+0x145/0x152
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.955128] [<ffffffff815e729f>] __bad_area_nosemaphore+0x18e/0x1b1
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.955133] [<ffffffff815e72d5>] bad_area_nosemaphore+0x13/0x15
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.955138] [<ffffffff816024fd>] do_page_fault+0x43d/0x530
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.955144] [<ffffffff8100969a>] ? __switch_to+0xca/0x310
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.955148] [<ffffffff815fe73e>] ? _raw_spin_lock+0xe/0x20
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.955154] [<ffffffff8104e749>] ? finish_task_switch+0x49/0xf0
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.955158] [<ffffffff815fef15>] page_fault+0x25/0x30
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.955162] [<ffffffff81511959>] ? netlink_has_listeners+0x9/0x50
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.955167] [<ffffffffa048f145>] nfnetlink_has_listeners+0x15/0x20 [nfnetlink]
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.955172] [<ffffffffa049943b>] ctnetlink_conntrack_event+0x5cb/0x890 [nf_conntrack_netlink]
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.955177] [<ffffffff814e34d0>] ? net_drop_ns+0x50/0x50
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.955183] [<ffffffffa04062d8>] death_by_timeout+0xc8/0x1c0 [nf_conntrack]
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.955189] [<ffffffffa0405270>] ? nf_conntrack_attach+0x50/0x50 [nf_conntrack]
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.955195] [<ffffffffa0406448>] nf_ct_iterate_cleanup+0x78/0x90 [nf_conntrack]
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.955202] [<ffffffffa0406491>] nf_conntrack_cleanup_net+0x31/0x100 [nf_conntrack]
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.955209] [<ffffffffa0407f97>] nf_conntrack_cleanup+0x27/0x60 [nf_conntrack]
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.955215] [<ffffffffa04081f0>] nf_conntrack_net_exit+0x60/0x80 [nf_conntrack]
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.955220] [<ffffffff814e2d28>] ops_exit_list.isra.1+0x38/0x60
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.955224] [<ffffffff814e35e2>] cleanup_net+0x112/0x1b0
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.955229] [<ffffffff8107bb0a>] process_one_work+0x11a/0x480
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.955233] [<ffffffff8107c7d5>] worker_thread+0x165/0x370
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.955237] [<ffffffff8107c670>] ? manage_workers.isra.30+0x130/0x130
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.955241] [<ffffffff81080c1c>] kthread+0x8c/0xa0
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.955245] [<ffffffff81607c24>] kernel_thread_helper+0x4/0x10
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.955250] [<ffffffff81080b90>] ? flush_kthread_worker+0xa0/0xa0
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.955254] [<ffffffff81607c20>] ? gs_change+0x13/0x13
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.955256] Code: 41 5f 5d c3 be 3e 01 00 00 48 c7 c7 88 90 9e 81 e8 b5 d7 fd ff e9 74 fe ff ff 55 48 89 e5 66 66 66 66 90 48 8b 87 70 03 00 00 5d
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.955311] RIP [<ffffffff810810b1>] kthread_data+0x11/0x20
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.955315]  RSP <ffff880801109870>
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.955317] CR2: fffffffffffffff8
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.955319] ---[ end trace 73540474560834fe ]---
Sep  9 14:34:00 node-10-157-128-100 kernel: [79602.955322] Fixing recursive fault but reboot is needed!
Sep  9 14:35:00 node-10-157-128-100 kernel: [79663.120046] INFO: rcu_sched_state detected stalls on CPUs/tasks: { 1 7} (detected by 6, t=6002 jiffies)
Sep  9 14:35:05 node-10-157-128-100 kernel: [79667.970047] INFO: rcu_bh_state detected stalls on CPUs/tasks: { 1 7} (detected by 6, t=6002 jiffies)
Sep  9 14:38:00 node-10-157-128-100 kernel: [79843.440048] INFO: rcu_sched_state detected stalls on CPUs/tasks: { 1 7} (detected by 6, t=24034 jiffies)
Sep  9 14:38:05 node-10-157-128-100 kernel: [79848.290046] INFO: rcu_bh_state detected stalls on CPUs/tasks: { 1 7} (detected by 6, t=24034 jiffies)
Sep  9 14:41:00 node-10-157-128-100 kernel: [80023.760051] INFO: rcu_sched_state detected stalls on CPUs/tasks: { 1 7} (detected by 6, t=42066 jiffies)
Sep  9 14:41:05 node-10-157-128-100 kernel: [80028.610044] INFO: rcu_bh_state detected stalls on CPUs/tasks: { 1 7} (detected by 6, t=42066 jiffies)
Sep  9 14:44:01 node-10-157-128-100 kernel: [80204.080047] INFO: rcu_sched_state detected stalls on CPUs/tasks: { 1 7} (detected by 6, t=60098 jiffies)
Sep  9 14:44:06 node-10-157-128-100 kernel: [80208.930045] INFO: rcu_bh_state detected stalls on CPUs/tasks: { 1 7} (detected by 6, t=60098 jiffies)
Sep  9 14:44:44 node-10-157-128-100 kernel: Kernel logging (proc) stopped.
