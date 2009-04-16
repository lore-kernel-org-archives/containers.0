From: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH] IO-Controller: Fix kernel panic after moving a task
Date: Thu, 16 Apr 2009 13:25:35 +0800
Message-ID: <49E6C14F.3090009__38982.0810560652$1239859734$gmane$org@cn.fujitsu.com>
References: <1236823015-4183-1-git-send-email-vgoyal@redhat.com>
	<1236823015-4183-6-git-send-email-vgoyal@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1236823015-4183-6-git-send-email-vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, oz-kernel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, arozansk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, fernando-w0OK63jvRlAuJ+9fw/WgBHgSJqDPrsil@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

Vivek Goyal wrote:
> +#ifdef CONFIG_IOSCHED_CFQ_HIER
> +static void changed_cgroup(struct io_context *ioc, struct cfq_io_context *cic)
> +{
> +	struct cfq_queue *async_cfqq = cic_to_cfqq(cic, 0);
> +	struct cfq_queue *sync_cfqq = cic_to_cfqq(cic, 1);
> +	struct cfq_data *cfqd = cic->key;
> +	struct io_group *iog, *__iog;
> +	unsigned long flags;
> +	struct request_queue *q;
> +
> +	if (unlikely(!cfqd))
> +		return;
> +
> +	q = cfqd->q;
> +
> +	spin_lock_irqsave(q->queue_lock, flags);
> +
> +	iog = io_lookup_io_group_current(q);
> +

  Hi Vivek,

  I triggered another kernel panic when testing. When moving a task to another 
  cgroup, the corresponding iog may not be setup properly all the time. "iog"
  might be NULL here. io_ioq_move() receives a NULL iog, kernel crash.

  Consider the following piece of code:

 941 int elv_set_request(struct request_queue *q, struct request *rq, gfp_t gfp_mask)
 942 {
 943         struct elevator_queue *e = q->elevator;
 944 
 945         elv_fq_set_request_io_group(q, rq);
 
 -->task moving to a new group is happenning here.

 946 
 947         /*
 948          * Optimization for noop, deadline and AS which maintain only single
 949          * ioq per io group
 950          */
 951         if (elv_iosched_single_ioq(e))
 952                 return elv_fq_set_request_ioq(q, rq, gfp_mask);
 953 
 954         if (e->ops->elevator_set_req_fn)
 955                 return e->ops->elevator_set_req_fn(q, rq, gfp_mask);

cfq_set_request() will finally call io_ioq_move(), but the iog is NULL, beacause the iogs in the 
hierarchy are not built yet. So kernel crashes.

 956 
 957         rq->elevator_private = NULL;
 958         return 0;
 959 }

BUG: unable to handle kernel NULL pointer dereference at 000000bc
IP: [<c04ebf8f>] io_ioq_move+0xf2/0x109
*pde = 6cc00067
Oops: 0000 [#1] SMP
last sysfs file: /sys/block/hdb/queue/slice_idle
Modules linked in: ipv6 cpufreq_ondemand acpi_cpufreq dm_mirror dm_multipath sbs sbshc battery ac lp snd_hda_codec_realtek snd_hda_intel snd_hda_codec snd_seq_dummy snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device snd_pcm_oss snd_mixer_oss snd_pcm serio_raw snd_timer rtc_cmos parport_pc snd r8169 button rtc_core parport soundcore mii i2c_i801 rtc_lib snd_page_alloc pcspkr i2c_core dm_region_hash dm_log dm_mod ext3 jbd mbcache uhci_hcd ohci_hcd ehci_hcd

Pid: 5431, comm: dd Not tainted (2.6.29-rc7-vivek #19) Veriton M460
EIP: 0060:[<c04ebf8f>] EFLAGS: 00010046 CPU: 0
EIP is at io_ioq_move+0xf2/0x109
EAX: f6203a88 EBX: f6792c94 ECX: f6203a84 EDX: 00000006
ESI: 00000000 EDI: 00000000 EBP: f6203a60 ESP: f6304c28
 DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
Process dd (pid: 5431, ti=f6304000 task=f669dae0 task.ti=f6304000)
Stack:
 f62478c0 0100dd40 f6247908 f62d995c 00000000 00000000 f675b54c c04e9182
 f638e9b0 00000282 f62d99a4 f6325a2c c04e9113 f5a707c0 c04e7ae0 f675b000
 f62d95fc f6325a2c c04e8501 00000010 f631e4e8 f675b000 00080000 ffffff10
Call Trace:
 [<c04e9182>] changed_cgroup+0x6f/0x8d
 [<c04e9113>] changed_cgroup+0x0/0x8d
 [<c04e7ae0>] __call_for_each_cic+0x1b/0x25
 [<c04e8501>] cfq_set_request+0x158/0x2c7
 [<c06316e6>] _spin_unlock_irqrestore+0x5/0x6
 [<c04eb106>] elv_fq_set_request_io_group+0x2b/0x3e
 [<c04e83a9>] cfq_set_request+0x0/0x2c7
 [<c04dddcb>] elv_set_request+0x3e/0x4e
 [<c04df3da>] get_request+0x1ed/0x29b
 [<c04df9bb>] get_request_wait+0xdf/0xf2
 [<c04dfd89>] __make_request+0x2c6/0x372
 [<c049bd76>] do_mpage_readpage+0x4fe/0x5e3
 [<c04deba5>] generic_make_request+0x2d0/0x355
 [<c04dff47>] submit_bio+0x92/0x97
 [<c045bfcb>] add_to_page_cache_locked+0x8a/0xb7
 [<c049bfa4>] mpage_end_io_read+0x0/0x50
 [<c049b1b6>] mpage_bio_submit+0x19/0x1d
 [<c049bf9a>] mpage_readpages+0x9b/0xa5
 [<f7dd18c7>] ext3_readpages+0x0/0x15 [ext3]
 [<c0462192>] __do_page_cache_readahead+0xea/0x154
 [<f7dd2286>] ext3_get_block+0x0/0xbe [ext3]
 [<c045d34d>] generic_file_aio_read+0x276/0x569
 [<c047cdd9>] do_sync_read+0xbf/0xfe
 [<c043a3f2>] getnstimeofday+0x51/0xdb
 [<c0434d3c>] autoremove_wake_function+0x0/0x2d
 [<c041bdc3>] sched_slice+0x61/0x6a
 [<c0423114>] task_tick_fair+0x3d/0x60
 [<c04c1d79>] security_file_permission+0xc/0xd
 [<c047cd1a>] do_sync_read+0x0/0xfe
 [<c047d35a>] vfs_read+0x6c/0x8b
 [<c047d67e>] sys_read+0x3c/0x63
 [<c0402fc1>] sysenter_do_call+0x12/0x21
 [<c0630000>] schedule+0x551/0x830
Code: 08 31 c9 89 da e8 77 fc ff ff 8b 86 bc 00 00 00 85 ff 89 43 38 8d 46 60 89 43 40 74 1d 83 c4 0c 89 d8 5b 5e 5f 5d e9 aa f9 ff ff <8b> 86 bc 00 00 00 89 43 38 8d 46 60 89 43 40 83 c4 0c 5b 5e 5f
EIP: [<c04ebf8f>] io_ioq_move+0xf2/0x109 SS:ESP 0068:f6304c28

Changelog:

Make sure iogs in the hierarchy are built properly after moving a task to a new cgroup.

Signed-off-by: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 block/cfq-iosched.c |    4 +++-
 block/elevator-fq.c |    1 +
 block/elevator-fq.h |    1 +
 3 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/block/cfq-iosched.c b/block/cfq-iosched.c
index 0ecf7c7..6d7bb8a 100644
--- a/block/cfq-iosched.c
+++ b/block/cfq-iosched.c
@@ -12,6 +12,8 @@
 #include <linux/rbtree.h>
 #include <linux/ioprio.h>
 #include <linux/blktrace_api.h>
+#include "elevator-fq.h"
+
 /*
  * tunables
  */
@@ -1086,7 +1088,7 @@ static void changed_cgroup(struct io_context *ioc, struct cfq_io_context *cic)
 
 	spin_lock_irqsave(q->queue_lock, flags);
 
-	iog = io_lookup_io_group_current(q);
+	iog = io_get_io_group(q);
 
 	if (async_cfqq != NULL) {
 		__iog = cfqq_to_io_group(async_cfqq);
diff --git a/block/elevator-fq.c b/block/elevator-fq.c
index df53418..f81cf6a 100644
--- a/block/elevator-fq.c
+++ b/block/elevator-fq.c
@@ -1191,6 +1191,7 @@ struct io_group *io_get_io_group(struct request_queue *q)
 
 	return iog;
 }
+EXPORT_SYMBOL(io_get_io_group);
 
 void io_free_root_group(struct elevator_queue *e)
 {
diff --git a/block/elevator-fq.h b/block/elevator-fq.h
index fc4110d..f17e425 100644
--- a/block/elevator-fq.h
+++ b/block/elevator-fq.h
@@ -459,6 +459,7 @@ static inline struct io_group *ioq_to_io_group(struct io_queue *ioq)
 }
 
 #ifdef CONFIG_GROUP_IOSCHED
+extern struct io_group *io_get_io_group(struct request_queue *q);
 extern int io_group_allow_merge(struct request *rq, struct bio *bio);
 extern void io_ioq_move(struct elevator_queue *e, struct io_queue *ioq,
 					struct io_group *iog);
-- 
1.5.4.rc3
