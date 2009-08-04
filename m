From: Munehiro Ikeda <m-ikeda-MDRzhb/z0dd8UrSeD/g0lQ@public.gmane.org>
Subject: Re: [PATCH] io-controller: implement per group request allocation
	limitation
Date: Mon, 03 Aug 2009 22:04:09 -0400
Message-ID: <4A779719.1070900__36924.9480114833$1249351587$gmane$org@ds.jp.nec.com>
References: <1246564917-19603-1-git-send-email-vgoyal@redhat.com>
	<4A569FC5.7090801@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4A569FC5.7090801-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Gui Jianfeng wrote, on 07/09/2009 09:56 PM:
> Hi Vivek,
>
> This patch exports a cgroup based per group request limits interface.
> and removes the global one. Now we can use this interface to perform
> different request allocation limitation for different groups.
>
> Signed-off-by: Gui Jianfeng<guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
(snip)

Hi Jianfeng,

If this helps, again.

A patch posted from Gui Jianfeng on 2009/07/09 adds per-cgroup
nr_requests control by io.nr_group_requests.  The patch missed to update
iog->nr_congestion_{on|off} and this patch adds the missing-link.

Signed-off-by: Munehiro "Muuhh" Ikeda <m-ikeda-MDRzhb/z0dd8UrSeD/g0lQ@public.gmane.org>
---
  block/elevator-fq.c |   11 +++++++++++
  1 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/block/elevator-fq.c b/block/elevator-fq.c
index 673e490..316bd8d 100644
--- a/block/elevator-fq.c
+++ b/block/elevator-fq.c
@@ -1607,6 +1607,10 @@ static int io_cgroup_nr_requests_write(struct cgroup *cgroup,
  					u64 val)
  {
  	struct io_cgroup *iocg;
+	struct io_group *iog;
+	struct elv_fq_data *efqd;
+	struct request_queue *q;
+	struct hlist_node *n;
  
  	if (val < BLKDEV_MIN_RQ)
  		val = BLKDEV_MIN_RQ;
@@ -1618,6 +1622,13 @@ static int io_cgroup_nr_requests_write(struct cgroup *cgroup,
  
  	spin_lock_irq(&iocg->lock);
  	iocg->nr_group_requests = (unsigned long)val;
+	hlist_for_each_entry(iog, n, &iocg->group_data, group_node) {
+		rcu_read_lock();
+		efqd = rcu_dereference(iog->key);
+		q = efqd->queue;
+		rcu_read_unlock();
+		elv_io_group_congestion_threshold(q, iog);
+	}
  	spin_unlock_irq(&iocg->lock);
  
  	cgroup_unlock();
-- 
1.6.2.5


-- 
IKEDA, Munehiro
   NEC Corporation of America
     m-ikeda-MDRzhb/z0dd8UrSeD/g0lQ@public.gmane.org
