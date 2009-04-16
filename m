From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC v14-rc3][PATCH 13/36] External checkpoint of a task other
	than ourself
Date: Wed, 15 Apr 2009 21:45:41 -0700
Message-ID: <20090416044541.GA14128@us.ibm.com>
References: <1239107264-21775-1-git-send-email-orenl@cs.columbia.edu>
	<1239107264-21775-14-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1239107264-21775-14-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
| +	nsproxy = task_nsproxy(task);
| +	get_nsproxy(nsproxy);

You were probably addressing my earlier comment :-), but if nsproxy
is NULL, get_nsproxy() will crash the system.

Would be nice if get_nsproxy() is modified to check for NULL and return
the nsproxy, (like say get_ipc_ns()), so we can:

	rcu_read_lock();
	nsproxy = get_nsproxy(task_nsproxy(task));
	rcu_read_unlock();

	if (!nsproxy)
		goto out;


| +	rcu_read_unlock();
| +
| +	if (!nsproxy)
| +		goto out;
| +
| +	ctx->root_task = task;
| +	ctx->root_nsproxy = nsproxy;
| +
| +	return 0;

Sukadev
