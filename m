From: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 05/18] io-controller: Common hierarchical fair queuing
	code in elevaotor layer
Date: Fri, 8 May 2009 23:09:37 +0200
Message-ID: <20090508210936.GA5763__44428.5209909596$1241817052$gmane$org@linux>
References: <1241553525-28095-1-git-send-email-vgoyal@redhat.com>
	<1241553525-28095-6-git-send-email-vgoyal@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1241553525-28095-6-git-send-email-vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, May 05, 2009 at 03:58:32PM -0400, Vivek Goyal wrote:
> +#define STORE_FUNCTION(__VAR, __MIN, __MAX)				\
> +static int io_cgroup_##__VAR##_write(struct cgroup *cgroup,		\
> +					struct cftype *cftype,		\
> +					u64 val)			\
> +{									\
> +	struct io_cgroup *iocg;					\
> +	struct io_group *iog;						\
> +	struct hlist_node *n;						\
> +									\
> +	if (val < (__MIN) || val > (__MAX))				\
> +		return -EINVAL;						\
> +									\
> +	if (!cgroup_lock_live_group(cgroup))				\
> +		return -ENODEV;						\
> +									\
> +	iocg = cgroup_to_io_cgroup(cgroup);				\
> +									\
> +	spin_lock_irq(&iocg->lock);					\
> +	iocg->__VAR = (unsigned long)val;				\
> +	hlist_for_each_entry(iog, n, &iocg->group_data, group_node) {	\
> +		iog->entity.new_##__VAR = (unsigned long)val;		\
> +		smp_wmb();						\
> +		iog->entity.ioprio_changed = 1;				\
> +	}								\
> +	spin_unlock_irq(&iocg->lock);					\
> +									\
> +	cgroup_unlock();						\
> +									\
> +	return 0;							\
> +}
> +
> +STORE_FUNCTION(weight, 0, WEIGHT_MAX);

A small fix: io.weight should be strictly greater than 0 if we don't
want to automatically trigger the BUG_ON(entity->weight == 0) in
bfq_calc_finish().

Signed-off-by: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 block/elevator-fq.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/block/elevator-fq.c b/block/elevator-fq.c
index 9500619..de25f44 100644
--- a/block/elevator-fq.c
+++ b/block/elevator-fq.c
@@ -1136,7 +1136,7 @@ static int io_cgroup_##__VAR##_write(struct cgroup *cgroup,		\
 	return 0;							\
 }
 
-STORE_FUNCTION(weight, 0, WEIGHT_MAX);
+STORE_FUNCTION(weight, 1, WEIGHT_MAX);
 STORE_FUNCTION(ioprio_class, IOPRIO_CLASS_RT, IOPRIO_CLASS_IDLE);
 #undef STORE_FUNCTION
