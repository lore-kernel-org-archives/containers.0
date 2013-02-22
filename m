From: Kamezawa Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: PROBLEM: Crash cgdeleting empty memory cgroups with
	memory.kmem.limit_in_bytes set
Date: Fri, 22 Feb 2013 12:15:02 +0900
Message-ID: <5126E2B6.9090002@jp.fujitsu.com>
References: <1361375371.7786.5.camel@michalke-online.eu>
	<20130220230019.GJ3570@htj.dyndns.org>
	<5125DC11.7060106@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <5125DC11.7060106-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Steffen Michalke <StMichalke-S0/GAf8tV78@public.gmane.org>
List-Id: containers.vger.kernel.org

(2013/02/21 17:34), Glauber Costa wrote:
> On 02/21/2013 03:00 AM, Tejun Heo wrote:
>> (cc'ing cgroup / memcg people and quoting whole body)
>>
>> Looks like something is going wrong with memcg cache destruction.
>> Glauber, any ideas?  Also, can we please not use names as generic as
>> kmem_cache_destroy_work_func for something specific to memcg?  How
>> about something like memcg_destroy_cache_workfn?
>>
>
> I will take a look. Thanks for the report for the reportee: I tested
> cgroup deletion quite extensively (quite important feature for me) so it
> is nice to have an uncaught case.
>
> About naming, I can change, no problem.
>

seems reproduced on linux-3.8 On KVM guest , Fedora18's config + kmemcg.
-Kame
==
[  250.533831] general protection fault: 0000 [#1] SMP
[  250.538096] Modules linked in: ebtable_nat xt_CHECKSUM nf_conntrack_netbios_ns nf_conntrack_broadcast ipt_MASQUERADE ip6table_mangle ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 iptable_nat nf_nat_ipv4 nf_nat iptable_mangle nf_conntrack_ipv4 nf_defrag_ipv4 xt_conntrack nf_conntrack tun bridge stp llc ebtable_filter ebtables be2iscsi iscsi_boot_sysfs ip6table_filter ip6_tables bnx2i cnic uio cxgb4i cxgb4 cxgb3i cxgb3 mdio libcxgbi ib_iser rdma_cm ib_addr iw_cm ib_cm ib_sa ib_mad ib_core iscsi_tcp libiscsi_tcp libiscsi scsi_transport_iscsi snd_hda_intel snd_hda_codec snd_hwdep snd_seq snd_seq_device snd_pcm snd_page_alloc 8139too snd_timer microcode snd 8139cp mii floppy pcspkr virtio_balloon soundcore i2c_piix4 btrfs libcrc32c zlib_deflate cirrus drm_kms_helper ttm drm virtio_blk i2c_cor
 e
[  250.538096] CPU 1
[  250.538096] Pid: 38, comm: kworker/1:1 Not tainted 3.8.0 #3 Bochs Bochs
[  250.538096] RIP: 0010:[<ffffffff81181f8a>]  [<ffffffff81181f8a>] kmem_cache_free+0x13a/0x1d0
[  250.538096] RSP: 0018:ffff880214345cc8  EFLAGS: 00010286
[  250.538096] RAX: ffffffff81d84020 RBX: ffff880217000f00 RCX: 0000000000000068
[  250.538096] RDX: cccccccccccccccc RSI: ffff880217000f00 RDI: ffff880217000f00
[  250.538096] RBP: ffff880214345ce8 R08: 00000000000013c0 R09: 000000000000006c
[  250.538096] R10: 0007ebc0ffffffe0 R11: 0007ebc0ffffffe0 R12: ffff880217001100
[  250.538096] R13: ffff880214042c00 R14: 0000000000000200 R15: ffff880217000ef0
[  250.538096] FS:  0000000000000000(0000) GS:ffff88021fc80000(0000) knlGS:0000000000000000
[  250.538096] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  250.538096] CR2: 0000003e98ae6ef0 CR3: 0000000213650000 CR4: 00000000000006e0
[  250.538096] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  250.538096] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  250.538096] Process kworker/1:1 (pid: 38, threadinfo ffff880214344000, task ffff880214350000)
[  250.538096] Stack:
[  250.538096]  ffffe8ffffc013c0 0000000000000000 0000000000000000 ffff880214042c00
[  250.538096]  ffff880214345d18 ffffffff81182084 ffff880214042c00 ffff880217000ef0
[  250.538096]  ffff880217000ef0 ffff880214042c00 ffff880214345d88 ffffffff81184d7e
[  250.538096] Call Trace:
[  250.538096]  [<ffffffff81182084>] free_kmem_cache_nodes+0x64/0xb0
[  250.538096]  [<ffffffff81184d7e>] __kmem_cache_shutdown+0x24e/0x320
[  250.538096]  [<ffffffff811842b0>] ? kmem_cache_shrink+0x210/0x230
[  250.538096]  [<ffffffff81153f3f>] kmem_cache_destroy+0x3f/0xe0
[  250.538096]  [<ffffffff8118f080>] kmem_cache_destroy_work_func+0x30/0x60
[  250.538096]  [<ffffffff8107a3c7>] process_one_work+0x147/0x490
[  250.538096]  [<ffffffff8118f050>] ? mem_cgroup_slabinfo_read+0xb0/0xb0
[  250.538096]  [<ffffffff8107cc5e>] worker_thread+0x15e/0x450
[  250.538096]  [<ffffffff8107cb00>] ? busy_worker_rebind_fn+0x110/0x110
[  250.538096]  [<ffffffff81081d20>] kthread+0xc0/0xd0
[  250.538096]  [<ffffffff81010000>] ? ftrace_define_fields_xen_mc_entry+0xa0/0xf0
[  250.538096]  [<ffffffff81081c60>] ? kthread_create_on_node+0x120/0x120
[  250.538096]  [<ffffffff8165ab6c>] ret_from_fork+0x7c/0xb0
[  250.538096]  [<ffffffff81081c60>] ? kthread_create_on_node+0x120/0x120
[  250.538096] Code: c1 e0 06 48 01 d0 48 8b 10 80 e6 80 0f 85 98 00 00 00 48 8b 40 30 49 39 c4 0f 84 f9 fe ff ff 48 8b 90 b8 00 00 00 48 85 d2 74 06 <4c> 3b 62 20 74 50 48 8b 50 60 49 8b 4c 24 60 31 c0 48 c7 c6 68
[  250.538096] RIP  [<ffffffff81181f8a>] kmem_cache_free+0x13a/0x1d0
[  250.538096]  RSP <ffff880214345cc8>
[  250.746175] ---[ end trace 91abe13b8481aaaf ]---
[  250.748879] BUG: unable to handle kernel paging request at ffffffffffffffd8
[  250.749818] IP: [<ffffffff81082100>] kthread_data+0x10/0x20
[  250.749818] PGD 1c0e067 PUD 1c0f067 PMD 0
[  250.749818] Oops: 0000 [#2] SMP
[  250.749818] Modules linked in: ebtable_nat xt_CHECKSUM nf_conntrack_netbios_ns nf_conntrack_broadcast ipt_MASQUERADE ip6table_mangle ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 iptable_nat nf_nat_ipv4 nf_nat iptable_mangle nf_conntrack_ipv4 nf_defrag_ipv4 xt_conntrack nf_conntrack tun bridge stp llc ebtable_filter ebtables be2iscsi iscsi_boot_sysfs ip6table_filter ip6_tables bnx2i cnic uio cxgb4i cxgb4 cxgb3i cxgb3 mdio libcxgbi ib_iser rdma_cm ib_addr iw_cm ib_cm ib_sa ib_mad ib_core iscsi_tcp libiscsi_tcp libiscsi scsi_transport_iscsi snd_hda_intel snd_hda_codec snd_hwdep snd_seq snd_seq_device snd_pcm snd_page_alloc 8139too snd_timer microcode snd 8139cp mii floppy pcspkr virtio_balloon soundcore i2c_piix4 btrfs libcrc32c zlib_deflate cirrus drm_kms_helper ttm drm virtio_blk i2c_cor
 e
[  250.749818] CPU 1
[  250.749818] Pid: 38, comm: kworker/1:1 Tainted: G      D      3.8.0 #3 Bochs Bochs
[  250.749818] RIP: 0010:[<ffffffff81082100>]  [<ffffffff81082100>] kthread_data+0x10/0x20
[  250.749818] RSP: 0018:ffff880214345a38  EFLAGS: 00010096
[  250.749818] RAX: 0000000000000000 RBX: 0000000000000001 RCX: 000000000000000f
[  250.749818] RDX: 0000000000000000 RSI: 0000000000000001 RDI: ffff880214350000
[  250.749818] RBP: ffff880214345a38 R08: ffff880214350070 R09: 0000000000000000
[  250.749818] R10: 0000000000000000 R11: 0000000000000000 R12: ffff88021fc93d80
[  250.749818] R13: 0000000000000001 R14: ffff88021434fff0 R15: ffff880214350000
[  250.749818] FS:  0000000000000000(0000) GS:ffff88021fc80000(0000) knlGS:0000000000000000
[  250.749818] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  250.749818] CR2: ffffffffffffffd8 CR3: 0000000213650000 CR4: 00000000000006e0
[  250.749818] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  250.749818] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  250.749818] Process kworker/1:1 (pid: 38, threadinfo ffff880214344000, task ffff880214350000)
[  250.749818] Stack:
[  250.749818]  ffff880214345a58 ffffffff8107d505 ffff880214345a58 ffff8802143503e0
[  250.749818]  ffff880214345ac8 ffffffff81650f92 ffff880214350000 ffff880214345fd8
[  250.749818]  ffff880214345fd8 ffff880214345fd8 ffff880214350000 ffff880214350000
[  250.749818] Call Trace:
[  250.749818]  [<ffffffff8107d505>] wq_worker_sleeping+0x15/0xc0
[  250.749818]  [<ffffffff81650f92>] __schedule+0x5c2/0x7a0
[  250.749818]  [<ffffffff81651499>] schedule+0x29/0x70
[  250.749818]  [<ffffffff810642f2>] do_exit+0x692/0x9e0
[  250.749818]  [<ffffffff8165381d>] oops_end+0x9d/0xe0
[  250.749818]  [<ffffffff81017848>] die+0x58/0x90
[  250.749818]  [<ffffffff8165329a>] do_general_protection+0xda/0x160
[  250.749818]  [<ffffffff81652c28>] general_protection+0x28/0x30
[  250.749818]  [<ffffffff81181f8a>] ? kmem_cache_free+0x13a/0x1d0
[  250.749818]  [<ffffffff81181f50>] ? kmem_cache_free+0x100/0x1d0
[  250.749818]  [<ffffffff81182084>] free_kmem_cache_nodes+0x64/0xb0
[  250.749818]  [<ffffffff81184d7e>] __kmem_cache_shutdown+0x24e/0x320
[  250.749818]  [<ffffffff811842b0>] ? kmem_cache_shrink+0x210/0x230
[  250.749818]  [<ffffffff81153f3f>] kmem_cache_destroy+0x3f/0xe0
[  250.749818]  [<ffffffff8118f080>] kmem_cache_destroy_work_func+0x30/0x60
[  250.749818]  [<ffffffff8107a3c7>] process_one_work+0x147/0x490
[  250.749818]  [<ffffffff8118f050>] ? mem_cgroup_slabinfo_read+0xb0/0xb0
[  250.749818]  [<ffffffff8107cc5e>] worker_thread+0x15e/0x450
[  250.749818]  [<ffffffff8107cb00>] ? busy_worker_rebind_fn+0x110/0x110
[  250.749818]  [<ffffffff81081d20>] kthread+0xc0/0xd0
[  250.749818]  [<ffffffff81010000>] ? ftrace_define_fields_xen_mc_entry+0xa0/0xf0
[  250.749818]  [<ffffffff81081c60>] ? kthread_create_on_node+0x120/0x120
[  250.749818]  [<ffffffff8165ab6c>] ret_from_fork+0x7c/0xb0
[  250.749818]  [<ffffffff81081c60>] ? kthread_create_on_node+0x120/0x120
[  250.749818] Code: 00 48 89 e5 5d 48 8b 40 c8 48 c1 e8 02 83 e0 01 c3 66 2e 0f 1f 84 00 00 00 00 00 0f 1f 44 00 00 48 8b 87 88 03 00 00 55 48 89 e5 <48> 8b 40 d8 5d c3 66 2e 0f 1f 84 00 00 00 00 00 0f 1f 44 00 00
[  250.749818] RIP  [<ffffffff81082100>] kthread_data+0x10/0x20
[  250.749818]  RSP <ffff880214345a38>
[  250.749818] CR2: ffffffffffffffd8
[  250.749818] ---[ end trace 91abe13b8481aab0 ]---
[  250.749818] Fixing recursive fault but reboot is needed!
