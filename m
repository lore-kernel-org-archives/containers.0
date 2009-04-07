From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC v14-rc2][PATCH 15/29] Restart multiple processes
Date: Tue, 07 Apr 2009 01:31:18 -0400
Message-ID: <49DAE526.6010900@cs.columbia.edu>
References: <1238477349-11029-1-git-send-email-orenl@cs.columbia.edu>
	<1238477349-11029-16-git-send-email-orenl@cs.columbia.edu>
	<20090407033315.GJ12316@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090407033315.GJ12316-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org



Sukadev Bhattiprolu wrote:
> Couple of nits and couple of not-so minor comments 
> 
> Oren Laadan [orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org] wrote:
> | From 7162fef93ee3d9fd30a457dd7b0c7ad0200d5bcb Mon Sep 17 00:00:00 2001
> | From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
> | Date: Mon, 30 Mar 2009 15:06:13 -0400
> | Subject: [PATCH 15/29] Restart multiple processes
> | 
> | Restarting of multiple processes expects all restarting tasks to call
> | sys_restart(). Once inside the system call, each task will restart
> | itself at the same order that they were saved. The internals of the
> | syscall will take care of in-kernel synchronization bewteen tasks.
> | 

[...]

> |  
> |  struct cr_ctx {
> |  	int crid;		/* unique checkpoint id */
> | @@ -31,8 +34,7 @@ struct cr_ctx {
> |  	void *hbuf;		/* temporary buffer for headers */
> |  	int hpos;		/* position in headers buffer */
> |  
> | -	struct task_struct **tasks_arr;	/* array of all tasks in container */
> | -	int tasks_nr;			/* size of tasks array */
> | +	atomic_t refcount;
> |  
> |  	struct cr_objhash *objhash;	/* hash for shared objects */
> |  
> | @@ -40,6 +42,19 @@ struct cr_ctx {
> |  	struct list_head pgarr_pool;	/* pool of empty page arrays chain */
> |  
> |  	struct path fs_mnt;	/* container root (FIXME) */
> | +
> | +	/* [multi-process checkpoint] */
> | +	struct task_struct **tasks_arr; /* array of all tasks [checkpoint] */
> | +	int tasks_nr;                   /* size of tasks array */
> | +
> | +	/* [multi-process restart] */
> | +	struct cr_hdr_pids *pids_arr;	/* array of all pids [restart] */
> | +	int pids_nr;			/* size of pids array */
> 
> Nit: Since we already have a pid_nr() that refers to something different,
> can we call this 'nr_pids' (and nr_tasks above)  like mm_context->nr_threads ?
> Of course, there is no convention, so its easy to argue the other way.

Ok.

> 
> Secondly, isn't pids_nr same as tasks_nr ? If so do we need both ?

As the comment says: one is used exclusively for checkpoint and the
other exclusively for restart.
So we don't strictly need both. I thought that for readability of it's
useful to have @pids_nr (ok, @nr_pids ...) when dealing with a @pids_arr,
and a @tasks_nr (ok .. @nr_tasks ...) when dealing with @tasks_arr.

> 
> Or is this intended to address the issue of multiple pid_nr values that a
> task in a nested container can have ? If so, pids_nr is > tasks_nr and that
> brings up two comments :-)

Ugh. This topic is TBD.

> 
> First, mktree.c and cr_next_task() are using 'ctx->pids_nr' to determine how
> many tasks to start. If we are talking about nested containers, pids_nr
> will be greater than tasks_nr so, mktree and cr_next_task() should be
> use 'ctx->tasks_nr' to determine how many tasks to create. Also if
> checkpointing a nested container we should view the multiple nested pid
> values a process as an attribute of the task and maybe save them in
> cr_write_task() rather than in cr_write_tree().

Lol .. who's talking about nested containers ?   ;)

(seriously: I'm not considering that now; my gut feeling is that it may
be useful to do pid_ns in userspace, like task creation - and in that
case it makes sense to keep it in cr_write_tree(). then again, I have
not looked at it in depth).

> 
> My second comment is more an orthogonal question. Suppose init_pid_ns = level
>  0 and we have a container that is nested at level 3.  If we checkpoint just
> this container, we would want to be able to restore this container at any level
> 0 right ?

True. Do you see any limitation in the current code that prevents this ?

> 
> | +	int pids_pos;			/* position pids array */
> | +	pid_t pids_active;		/* pid of (next) active task */
> 
> Do we need both pids_pos and pids_active in the ctx ? Can pids_active
> just be a local variable in cr_next_task() and cr_wait_task() ?
> IOW, isn't this always true
> 
> 	pids_arr[pids_pos] == pids_active

Ok.

Oren.

> 
> | +	atomic_t tasks_count;		/* sync of tasks: used to coordinate */
> 
> Name is a bit confusing with 'tasks_nr', but the comment helps and I can't
> think of a better name.
> 
> | +	struct completion complete;	/* container root and other tasks on */
> | +	wait_queue_head_t waitq;	/* start, end, and restart ordering */
> |  };
> 
> Sukadev
> 
