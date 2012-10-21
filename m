From: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/7] cgroup: cgroup_subsys->fork() should be called
	after the task is added to css_set
Date: Sun, 21 Oct 2012 21:11:41 +0200
Message-ID: <20121021191141.GA26218@redhat.com>
References: <1350426526-14254-1-git-send-email-tj@kernel.org>
	<1350426526-14254-2-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1350426526-14254-2-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rjw-KKrjLPT3xs0@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On 10/16, Tejun Heo wrote:
>
> cgroup_subsys->fork() is invoked way before the new task is added to
> the css_set.

Plus, it called before this task (and even its task_struct) was fully
initialized.

All I can say is: personally I like this patch, it also simplifies
copy_process().

But I am in no position to ack it. I seem to forget everything (not
too much ;) I ever knew about this code.



A couple of off-topic questions. With or without this patch I do not
understand cgroup_fork,

	/*
	 * We don't need to task_lock() current because current->cgroups
	 * can't be changed concurrently here. The parent obviously hasn't
	 * exited and called cgroup_exit(), and we are synchronized against
	 * cgroup migration through threadgroup_change_begin().
	 */
	child->cgroups = current->cgroups;
	get_css_set(child->cgroups);

How so? threadgroup_change_begin() is only called if CLONE_THREAD.
So in theory this copy + atomic_add looks racy...




And it seems that fork() can race with cgroup iterator. post_fork
will notice use_task_css_set_links, but until then the child belongs
to the parent's css and it is not "visible" to iterator (and right
after cgroup_fork() it is not visible to do_each_thread() if
use_task_css_set_links is not set).

For example. Suppose that the child migrates to another cgroup after
copy_process() makes it visible to the user-space. Then update_if_frozen
sets CGROUP_FROZEN (again, cgroup_iter_next do not see this child).

Now, post_fork calls freezer_fork() and hits BUG_ON(CGROUP_FROZEN).

But again, I do not blame this patch.


I am starting to think again about a big-rw-lock around copy_process.
Recently I tried to add one around dup_mmap for uprobes, but perhaps
cgroups can use it too...

Oleg.
