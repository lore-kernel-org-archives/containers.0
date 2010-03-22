From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH linux-cr] nested pid namespaces (v2)
Date: Mon, 22 Mar 2010 09:38:00 -0500
Message-ID: <20100322143800.GD3744@us.ibm.com>
References: <20100319213955.GA17912@us.ibm.com>
 <20100322105502.GB5569@localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100322105502.GB5569@localdomain>
Sender: linux-kernel-owner@vger.kernel.org
To: Louis Rilling <Louis.Rilling@kerlabs.com>
Cc: Oren Laadan <orenl@cs.columbia.edu>, Linux Containers <containers@lists.osdl.org>, lkml <linux-kernel@vger.kernel.org>
List-Id: containers.vger.kernel.org

Quoting Louis Rilling (Louis.Rilling@kerlabs.com):
> On Fri, Mar 19, 2010 at 04:39:55PM -0500, Serge E. Hallyn wrote:
> > Support checkpoint and restart of tasks in nested pid namespaces.  At
> > Oren's request here is an alternative to my previous implementation.  In
> > this one, we keep the original single pids_array to minimize memory
> > allocations.  The pids array entries are augmented with a pidns depth
> > (relative to the container init's pidns, and an "rpid" which is the pid
> > in the checkpointer's pidns (or 0 if no valid pid exists).  The rpid
> > will be used by userspace to gather more information (like
> > /proc/$$/mountinfo) after the kernel sys_checkpoint.  If any tasks are
> > in nested pid namespace, another single array holds all of the vpids.
> > At restart those are used by userspace to determine how to call
> > eclone().  Kernel ignores them.
> > 
> > All cr_tests including the new pid_ns testcase pass.
> > 
> 
> IMHO this approach looks ok too. I just feel that checkpoint_vpids() could
> be re-worked a bit in order to not impose an artificial limit of
> CKPT_HDR_PIDS_CHUNK to the depth of pid namespaces, even if it is 256 (see
> suggested changes below).

Ah, took me a second to see what you were saying.  Good point.

> It would probably be safer too to use task_active_pid_ns() instead of
> task->nsproxy->pid_ns, just in case some PID namespace unsharing like proposed
> by Eric makes it to mainline.

The task is frozen though so it shouldn't be able to unshare while being
checkpointed, right?  But it's probably better code anyway.

> Thanks,
> 
> Louis
> 
> > Signed-off-by: Serge E. Hallyn <serue@us.ibm.com>
> > ---
> >  checkpoint/checkpoint.c          |  113 ++++++++++++++++++++++++++++++++++----
> >  checkpoint/process.c             |   18 +++++-
> >  checkpoint/restart.c             |   45 ++++++++++++++-
> >  checkpoint/sys.c                 |    2 +
> >  include/linux/checkpoint.h       |    2 +-
> >  include/linux/checkpoint_hdr.h   |   16 +++++
> >  include/linux/checkpoint_types.h |    3 +
> >  kernel/nsproxy.c                 |    9 ++-
> >  8 files changed, 186 insertions(+), 22 deletions(-)
> > 
> > diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
> > index f27af41..fe3546a 100644
> > --- a/checkpoint/checkpoint.c
> > +++ b/checkpoint/checkpoint.c
> > @@ -27,6 +27,7 @@
> >  #include <linux/deferqueue.h>
> >  #include <linux/checkpoint.h>
> >  #include <linux/checkpoint_hdr.h>
> > +#include <linux/pid_namespace.h>
> >  
> >  /* unique checkpoint identifier (FIXME: should be per-container ?) */
> >  static atomic_t ctx_count = ATOMIC_INIT(0);
> > @@ -242,6 +243,7 @@ static int may_checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
> >  	struct task_struct *root = ctx->root_task;
> >  	struct nsproxy *nsproxy;
> >  	int ret = 0;
> > +	struct pid_namespace *pidns;
> >  
> >  	ckpt_debug("check %d\n", task_pid_nr_ns(t, ctx->root_nsproxy->pid_ns));
> >  
> > @@ -293,10 +295,15 @@ static int may_checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
> >  		_ckpt_err(ctx, -EPERM, "%(T)Nested net_ns unsupported\n");
> >  		ret = -EPERM;
> >  	}
> > -	/* no support for >1 private pidns */
> > -	if (nsproxy->pid_ns != ctx->root_nsproxy->pid_ns) {
> > -		_ckpt_err(ctx, -EPERM, "%(T)Nested pid_ns unsupported\n");
> > -		ret = -EPERM;
> > +	/* pidns must be descendent of root_nsproxy */
> > +	pidns = nsproxy->pid_ns;
> > +	while (pidns != ctx->root_nsproxy->pid_ns) {
> > +		if (pidns == &init_pid_ns) {
> > +			ret = -EPERM;
> > +			_ckpt_err(ctx, ret, "%(T)stranger pid_ns\n");
> > +			break;
> > +		}
> > +		pidns = pidns->parent;
> >  	}
> >  	rcu_read_unlock();
> >  
> > @@ -305,15 +312,19 @@ static int may_checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
> >  
> >  #define CKPT_HDR_PIDS_CHUNK	256
> >  
> > +/*
> > + * Write the pids in ctx->root_nsproxy->pidns.  This info is
> > + * needed at restart to unambiguously dereference tasks.
> > + */
> >  static int checkpoint_pids(struct ckpt_ctx *ctx)
> >  {
> >  	struct ckpt_pids *h;
> > -	struct pid_namespace *ns;
> > +	struct pid_namespace *root_pidns;
> >  	struct task_struct *task;
> >  	struct task_struct **tasks_arr;
> >  	int nr_tasks, n, pos = 0, ret = 0;
> >  
> > -	ns = ctx->root_nsproxy->pid_ns;
> > +	root_pidns = ctx->root_nsproxy->pid_ns;
> >  	tasks_arr = ctx->tasks_arr;
> >  	nr_tasks = ctx->nr_tasks;
> >  	BUG_ON(nr_tasks <= 0);
> > @@ -331,15 +342,21 @@ static int checkpoint_pids(struct ckpt_ctx *ctx)
> >  	do {
> >  		rcu_read_lock();
> >  		for (n = 0; n < min(nr_tasks, CKPT_HDR_PIDS_CHUNK); n++) {
> > +			struct pid_namespace *task_pidns;
> >  			task = tasks_arr[pos];
> >  
> > -			h[n].vpid = task_pid_nr_ns(task, ns);
> > -			h[n].vtgid = task_tgid_nr_ns(task, ns);
> > -			h[n].vpgid = task_pgrp_nr_ns(task, ns);
> > -			h[n].vsid = task_session_nr_ns(task, ns);
> > -			h[n].vppid = task_tgid_nr_ns(task->real_parent, ns);
> > +			h[n].vpid = task_pid_nr_ns(task, root_pidns);
> > +			h[n].vtgid = task_tgid_nr_ns(task, root_pidns);
> > +			h[n].vpgid = task_pgrp_nr_ns(task, root_pidns);
> > +			h[n].vsid = task_session_nr_ns(task, root_pidns);
> > +			h[n].vppid = task_tgid_nr_ns(task->real_parent,
> > +					root_pidns);
> > +			task_pidns = task_nsproxy(task)->pid_ns;
> > +			h[n].rpid = task_pid_vnr(task);
> > +			h[n].depth = task_pidns->level - root_pidns->level;
> >  			ckpt_debug("task[%d]: vpid %d vtgid %d parent %d\n",
> >  				   pos, h[n].vpid, h[n].vtgid, h[n].vppid);
> > +			ctx->nr_vpids += h[n].depth;
> >  			pos++;
> >  		}
> >  		rcu_read_unlock();
> > @@ -356,6 +373,61 @@ static int checkpoint_pids(struct ckpt_ctx *ctx)
> >  	return ret;
> >  }
> >  
> > +static int checkpoint_vpids(struct ckpt_ctx *ctx)
> > +{
> > +	struct ckpt_vpid *h;
> > +	struct pid_namespace *root_pidns, *task_pidns;
> > +	struct task_struct *task;
> > +	int ret, nr_tasks = ctx->nr_tasks;
> > +	int tidx = 0, /* index into task array */
> > +		hidx = 0; /* pids written into current ckpt_vpids chunk */
> > +
> > +	root_pidns = ctx->root_nsproxy->pid_ns;
> > +	nr_tasks = ctx->nr_tasks;
> > +
> > +	ret = ckpt_write_obj_type(ctx, NULL,
> > +				  sizeof(*h) * ctx->nr_vpids,
> > +				  CKPT_HDR_BUFFER);
> > +	if (ret < 0)
> > +		return ret;
> > +
> > +	h = ckpt_hdr_get(ctx, sizeof(*h) * CKPT_HDR_PIDS_CHUNK);
> > +	if (!h)
> > +		return -ENOMEM;
> > +
> > +	do {
> > +		rcu_read_lock();
> > +		while (tidx < nr_tasks) {
> > +			int vidx; /* vpid index */
> > +			int nsdelta;
> > +
> > +			task = ctx->tasks_arr[tidx];
> > +			task_pidns = task_nsproxy(task)->pid_ns;
> > +			nsdelta = task_pidns->level - root_pidns->level;
> > +			if (hidx + nsdelta >= CKPT_HDR_PIDS_CHUNK)
> 
> I think that (hidx + nsdelta > CKPT_HDR_PIDS_CHUNK) checks more accurately the limit.
> 
> > +				break;
> > +
> > +			for (vidx = 0; vidx < nsdelta; vidx++) {
> > +				h[vidx].pid = task_pid_nr_ns(task, task_pidns);
> 
> Here:
> 				h[hidx + vidx]
> 
> > +				task_pidns = task_pidns->parent;
> > +			}
> > +
> > +			hidx += nsdelta;
> > +			tidx++;
> > +		}
> > +		rcu_read_unlock();
> > +
> > +		ret = ckpt_kwrite(ctx, h, hidx * sizeof(*h));
> > +		if (ret < 0)
> > +			break;
> > +
> > +		hidx = 0;
> > +	} while (tidx < nr_tasks);
> > +
> > +	_ckpt_hdr_put(ctx, h, sizeof(*h) * CKPT_HDR_PIDS_CHUNK);
> > +	return ret;
> > +}
> 
> Maybe re-work it this way:
> 
> static int checkpoint_vpids(struct ckpt_ctx *ctx)
> {
> 	struct ckpt_vpid *h;
> 	struct pid_namespace *root_pidns, *task_pidns, *active_pidns;
> 	struct task_struct *task;
> 	int ret, nr_tasks = ctx->nr_tasks;
> 	int tidx = 0, /* index into task array */
> 		hidx = 0; /* pids written into current ckpt_vpids chunk */
> 		vidx = 0; /* vpid index for current task */
> 
> 	root_pidns = ctx->root_nsproxy->pid_ns;
> 	nr_tasks = ctx->nr_tasks;
> 
> 	ret = ckpt_write_obj_type(ctx, NULL,
> 				  sizeof(*h) * ctx->nr_vpids,
> 				  CKPT_HDR_BUFFER);
> 	if (ret < 0)
> 		return ret;
> 
> 	h = ckpt_hdr_get(ctx, sizeof(*h) * CKPT_HDR_PIDS_CHUNK);
> 	if (!h)
> 		return -ENOMEM;
> 
> 	do {
> 		rcu_read_lock();
> 		while (tidx < nr_tasks && hidx < CKPT_HDR_PIDS_CHUNK) {
> 			int nsdelta;
> 
> 			task = ctx->tasks_arr[tidx];
> 			active_pidns = task_active_pid_ns(task);
> 			nsdelta = active_pidns->level - root_pidns->level;
> 			if (hidx + nsdelta - vidx > CKPT_HDR_PIDS_CHUNK)
> 				/*
> 				 * We will release rcu before recording the
> 				 * remaining vpids, but neither task nor its
> 				 * pid can disappear.
> 				 */
> 				nsdelta = CKPT_HDR_PIDS_CHUNK - hidx + vidx;

This looks good, thanks.

> 			if (vidx == 0)
> 				task_pidns = active_pidns;
> 			for (; vidx < nsdelta; vidx++) {
> 				h[hidx].pid = task_pid_nr_ns(task, task_pidns);
> 				hidx++;
> 				task_pidns = task_pidns->parent;
> 			}
> 
> 			if (task_pidns == root_pidns) {
> 				tidx++;
> 				vidx = 0;
> 			}
> 		}
> 		rcu_read_unlock();
> 
> 		ret = ckpt_kwrite(ctx, h, hidx * sizeof(*h));
> 		if (ret < 0)
> 			break;
> 
> 		hidx = 0;
> 	} while (tidx < nr_tasks);
> 
> 	_ckpt_hdr_put(ctx, h, sizeof(*h) * CKPT_HDR_PIDS_CHUNK);
> 	return ret;
> }
> 
> [...]
> 
> -- 
> Dr Louis Rilling			Kerlabs
> Skype: louis.rilling			Batiment Germanium
> Phone: (+33|0) 6 80 89 08 23		80 avenue des Buttes de Coesmes
> http://www.kerlabs.com/			35700 Rennes
