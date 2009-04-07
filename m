From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC v14-rc2][PATCH 13/29] External checkpoint of a task other
	than ourself
Date: Mon, 6 Apr 2009 20:30:37 -0700
Message-ID: <20090407033037.GH12316@us.ibm.com>
References: <1238477349-11029-1-git-send-email-orenl@cs.columbia.edu>
	<1238477349-11029-14-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1238477349-11029-14-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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

Minor comment.

Oren Laadan [orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org] wrote:
| From 0fd2795c29fec51eec75f76ea21394367b6801db Mon Sep 17 00:00:00 2001
| From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
| Date: Tue, 21 Oct 2008 16:26:10 -0400
| Subject: [PATCH 13/29] External checkpoint of a task other than ourself
| 
| Now we can do "external" checkpoint, i.e. act on another task.
| 
| sys_checkpoint() now looks up the target pid (in our namespace) and
| checkpoints that corresponding task. That task should be the root of
| a container.
| 
| sys_restart() remains the same, as the restart is always done in the
| context of the restarting task.
| 
| Changelog[v14]:
|   - Refuse non-self checkpoint if target task isn't frozen
| 
| Changelog[v12]:
|   - Replace obsolete cr_debug() with pr_debug()
| 
| Changelog[v11]:
|   - Copy contents of 'init->fs->root' instead of pointing to them
| 
| Changelog[v10]:
|   - Grab vfs root of container init, rather than current process
| 
| Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
| Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
| ---
|  checkpoint/checkpoint.c    |   73 ++++++++++++++++++++++++++++++++++++++++++-
|  checkpoint/restart.c       |    4 +-
|  checkpoint/sys.c           |    6 +++
|  include/linux/checkpoint.h |    2 +
|  4 files changed, 81 insertions(+), 4 deletions(-)
| 
| diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
| index d4e0007..25229d3 100644
| --- a/checkpoint/checkpoint.c
| +++ b/checkpoint/checkpoint.c
| @@ -10,6 +10,8 @@
|  
|  #include <linux/version.h>
|  #include <linux/sched.h>
| +#include <linux/freezer.h>
| +#include <linux/ptrace.h>
|  #include <linux/time.h>
|  #include <linux/fs.h>
|  #include <linux/file.h>
| @@ -242,6 +244,11 @@ static int cr_write_task(struct cr_ctx *ctx, struct task_struct *t)
|  {
|  	int ret;
|  
| +	if (t->state == TASK_DEAD) {
| +		pr_warning("c/r: task may not be in state TASK_DEAD\n");
| +		return -EAGAIN;
| +	}
| +
|  	ret = cr_write_task_struct(ctx, t);
|  	cr_debug("task_struct: ret %d\n", ret);
|  	if (ret < 0)
| @@ -264,22 +271,84 @@ static int cr_write_task(struct cr_ctx *ctx, struct task_struct *t)
|  	return ret;
|  }
|  
| +static int cr_get_container(struct cr_ctx *ctx, pid_t pid)
| +{
| +	struct task_struct *task = NULL;
| +	struct nsproxy *nsproxy = NULL;
| +	int err = -ESRCH;
| +
| +	ctx->root_pid = pid;
| +
| +	read_lock(&tasklist_lock);
| +	task = find_task_by_vpid(pid);
| +	if (task)
| +		get_task_struct(task);
| +	read_unlock(&tasklist_lock);
| +
| +	if (!task)
| +		goto out;
| +
| +#if 0	/* enable to use containers */
| +	if (!is_container_init(task)) {
| +		err = -EINVAL;
| +		goto out;
| +	}
| +#endif
| +
| +	if (!ptrace_may_access(task, PTRACE_MODE_READ)) {
| +		err = -EPERM;
| +		goto out;
| +	}
| +
| +	/* verify that the task is frozen (unless self) */
| +	if (task != current && !frozen(task))
| +		return -EBUSY;
| +
| +	rcu_read_lock();
| +	if (task_nsproxy(task)) {
| +		nsproxy = task_nsproxy(task);

Nit: why call task_nproxy() twice ?

| +		get_nsproxy(nsproxy);
| +	}
| +	rcu_read_unlock();
| +
| +	if (!nsproxy)
| +		goto out;

Sukadev
