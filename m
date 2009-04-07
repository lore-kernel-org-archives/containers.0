From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC v14-rc2][PATCH 14/29] Checkpoint multiple processes
Date: Mon, 6 Apr 2009 20:31:11 -0700
Message-ID: <20090407033111.GI12316@us.ibm.com>
References: <1238477349-11029-1-git-send-email-orenl@cs.columbia.edu>
	<1238477349-11029-15-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1238477349-11029-15-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Oren Laadan [orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org] wrote:
| From ee2f3b5c8548136229cc2f41c5271b0a81ab8a4d Mon Sep 17 00:00:00 2001
| From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
| Date: Mon, 30 Mar 2009 15:06:13 -0400
| Subject: [PATCH 14/29] Checkpoint multiple processes
| 
| Checkpointing of multiple processes works by recording the tasks tree
| structure below a given task (usually this task is the container init).
| 
| For a given task, do a DFS scan of the tasks tree and collect them
| into an array (keeping a reference to each task). Using DFS simplifies
| the recreation of tasks either in user space or kernel space. For each
| task collected, test if it can be checkpointed, and save its pid, tgid,
| and ppid.
| 
| The actual work is divided into two passes: a first scan counts the
| tasks, then memory is allocated and a second scan fills the array.
| 
| The logic is suitable for creation of processes during restart either
| in userspace or by the kernel.
| 
| Currently we ignore threads and zombies, as well as session ids.
| 
| Changelog[v14]:
|   - Refuse non-self checkpoint if target task isn't frozen
|   - Revert change to pr_debug(), back to cr_debug()
|   - Use only unsigned fields in checkpoint headers
|   - Check retval of cr_tree_count_tasks() in cr_build_tree()
|   - Discard 'h.parent' field
|   - Check whether calls to cr_hbuf_get() fail
| 
| Changelog[v13]:
|   - Release tasklist_lock in error path in cr_tree_count_tasks()
|   - Use separate index for 'tasks_arr' and 'hh' in cr_write_pids()
| 
| Changelog[v12]:
|   - Replace obsolete cr_debug() with pr_debug()
| 
| Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
| Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
| ---
|  checkpoint/checkpoint.c        |  228 ++++++++++++++++++++++++++++++++++++++--
|  checkpoint/sys.c               |   16 +++
|  include/linux/checkpoint.h     |    3 +
|  include/linux/checkpoint_hdr.h |   13 ++-
|  4 files changed, 248 insertions(+), 12 deletions(-)
| 
| diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
| index 25229d3..7f5eee6 100644
| --- a/checkpoint/checkpoint.c
| +++ b/checkpoint/checkpoint.c
| @@ -244,11 +244,6 @@ static int cr_write_task(struct cr_ctx *ctx, struct task_struct *t)
|  {
|  	int ret;
|  
| -	if (t->state == TASK_DEAD) {
| -		pr_warning("c/r: task may not be in state TASK_DEAD\n");
| -		return -EAGAIN;
| -	}
| -
|  	ret = cr_write_task_struct(ctx, t);
|  	cr_debug("task_struct: ret %d\n", ret);
|  	if (ret < 0)
| @@ -271,6 +266,211 @@ static int cr_write_task(struct cr_ctx *ctx, struct task_struct *t)
|  	return ret;
|  }
|  
| +/* dump all tasks in ctx->tasks_arr[] */
| +static int cr_write_all_tasks(struct cr_ctx *ctx)
| +{
| +	int n, ret = 0;
| +
| +	for (n = 0; n < ctx->tasks_nr; n++) {
| +		cr_debug("dumping task #%d\n", n);
| +		ret = cr_write_task(ctx, ctx->tasks_arr[n]);
| +		if (ret < 0)
| +			break;
| +	}
| +
| +	return ret;
| +}
| +
| +static int cr_may_checkpoint_task(struct task_struct *t, struct cr_ctx *ctx)
| +{
| +	cr_debug("check %d\n", task_pid_nr_ns(t, ctx->root_nsproxy->pid_ns));
| +
| +	if (t->state == TASK_DEAD) {
| +		pr_warning("c/r: task %d is TASK_DEAD\n", task_pid_vnr(t));
| +		return -EAGAIN;
| +	}
| +
| +	if (!ptrace_may_access(t, PTRACE_MODE_READ))
| +		return -EPERM;
| +
| +	/* verify that the task is frozen (unless self) */
| +	if (t != current && !frozen(t))
| +		return -EBUSY;
| +
| +	/* FIXME: change this for nested containers */
| +	if (task_nsproxy(t) != ctx->root_nsproxy)
| +		return -EPERM;
| +
| +	return 0;
| +}
| +
| +#define CR_HDR_PIDS_CHUNK	256
| +
| +static int cr_write_pids(struct cr_ctx *ctx)
| +{
| +	struct cr_hdr_pids *hh;
| +	struct pid_namespace *ns;
| +	struct task_struct *task;
| +	struct task_struct **tasks_arr;
| +	int tasks_nr, n, pos = 0, ret = 0;
| +
| +	ns = ctx->root_nsproxy->pid_ns;
| +	tasks_arr = ctx->tasks_arr;
| +	tasks_nr = ctx->tasks_nr;
| +	BUG_ON(tasks_nr <= 0);
| +
| +	hh = cr_hbuf_get(ctx, sizeof(*hh) * CR_HDR_PIDS_CHUNK);
| +	if (!hh)
| +		return -ENOMEM;
| +
| +	do {
| +		rcu_read_lock();
| +		for (n = 0; n < min(tasks_nr, CR_HDR_PIDS_CHUNK); n++) {
| +			task = tasks_arr[pos];
| +
| +			/* is this task cool ? */
| +			ret = cr_may_checkpoint_task(task, ctx);
| +			if (ret < 0) {
| +				rcu_read_unlock();
| +				goto out;
| +			}
| +			hh[n].vpid = task_pid_nr_ns(task, ns);
| +			hh[n].vtgid = task_tgid_nr_ns(task, ns);
| +			hh[n].vppid = task_tgid_nr_ns(task->real_parent, ns);
| +			cr_debug("task[%d]: vpid %d vtgid %d parent %d\n", pos,
| +				 hh[n].vpid, hh[n].vtgid, hh[n].vppid);
| +			pos++;
| +		}
| +		rcu_read_unlock();
| +
| +		n = min(tasks_nr, CR_HDR_PIDS_CHUNK);
| +		ret = cr_kwrite(ctx, hh, n * sizeof(*hh));
| +		if (ret < 0)
| +			break;
| +
| +		tasks_nr -= n;
| +	} while (tasks_nr > 0);
| + out:
| +	cr_hbuf_put(ctx, sizeof(*hh));
| +	return ret;
| +}
| +
| +/* count number of tasks in tree (and optionally fill pid's in array) */
| +static int cr_tree_count_tasks(struct cr_ctx *ctx)
| +{
| +	struct task_struct *root = ctx->root_task;
| +	struct task_struct *task = root;
| +	struct task_struct *parent = NULL;
| +	struct task_struct **tasks_arr = ctx->tasks_arr;
| +	int tasks_nr = ctx->tasks_nr;
| +	int nr = 0;
| +
| +	read_lock(&tasklist_lock);
| +
| +	/* count tasks via DFS scan of the tree */
| +	while (1) {
| +		if (tasks_arr) {
| +			/* unlikely... but if so then try again later */
| +			if (nr == tasks_nr) {
| +				nr = -EAGAIN;	/* cleanup in cr_ctx_free() */
| +				break;
| +			}
| +			tasks_arr[nr] = task;
| +			get_task_struct(task);

Can we do an early cr_may_checkpoint_task() here ?

Sukadev
