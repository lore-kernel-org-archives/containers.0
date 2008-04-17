From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [PATCH] cgroup: fix a race condition in manipulating tsk->cg_list
Date: Wed, 16 Apr 2008 21:11:44 -0700
Message-ID: <20080416211144.a38f6fc0.akpm@linux-foundation.org>
References: <4806C5EB.3040102@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4806C5EB.3040102-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, 17 Apr 2008 11:37:15 +0800 Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:

> When I ran a test program to fork mass processes and at the same time
> 'cat /cgroup/tasks', I got the following oops:
> 
> ------------[ cut here ]------------
> kernel BUG at lib/list_debug.c:72!
> invalid opcode: 0000 [#1] SMP
> Pid: 4178, comm: a.out Not tainted (2.6.25-rc9 #72)
> ...
> Call Trace:
>  [<c044a5f9>] ? cgroup_exit+0x55/0x94
>  [<c0427acf>] ? do_exit+0x217/0x5ba
>  [<c0427ed7>] ? do_group_exit+0.65/0x7c
>  [<c0427efd>] ? sys_exit_group+0xf/0x11
>  [<c0404842>] ? syscall_call+0x7/0xb
>  [<c05e0000>] ? init_cyrix+0x2fa/0x479
> ...
> EIP: [<c04df671>] list_del+0x35/0x53 SS:ESP 0068:ebc7df4
> ---[ end trace caffb7332252612b ]---
> Fixing recursive fault but reboot is needed!
> 
> After digging into the code and debugging, I finlly found out a race
> situation:
> 				do_exit()
> 				  ->cgroup_exit()
> 				    ->if (!list_empty(&tsk->cg_list))
> 				        list_del(&tsk->cg_list);
> 
> cgroup_iter_start()
>   ->cgroup_enable_task_cg_list()
>     ->list_add(&tsk->cg_list, ..);
> 
> In this case the list won't be deleted though the process has exited.

I don't fully understand the race.  Both paths hold css_set_lock.

Can you describe it in more detail please?

> We got two bug reports in the past, which seem to be the same bug as
> this one:
> 	http://lkml.org/lkml/2008/3/5/332
> 	http://lkml.org/lkml/2007/10/17/224
> 
> Actually sometimes I got oops on list_del, sometimes oops on list_add.
> And I can change my test program a bit to trigger other oops.
> 
> The patch has been tested both on x86_32 and x86_64.
> 
> Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> ---
>  kernel/cgroup.c |    7 ++++++-
>  1 files changed, 6 insertions(+), 1 deletions(-)
> 
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index 2727f92..6d8de05 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -1722,7 +1722,12 @@ void cgroup_enable_task_cg_lists(void)
>  	use_task_css_set_links = 1;
>  	do_each_thread(g, p) {
>  		task_lock(p);
> -		if (list_empty(&p->cg_list))
> +		/*
> +		 * We should check if the process is exiting, otherwise
> +		 * it will race with cgroup_exit() in that the list
> +		 * entry won't be deleted though the process has exited.
> +		 */
> +		if (!(p->flags & PF_EXITING) && list_empty(&p->cg_list))
>  			list_add(&p->cg_list, &p->cgroups->tasks);
>  		task_unlock(p);
>  	} while_each_thread(g, p);

Don't think I understand the fix either :(

afacit the task at *p could set PF_EXITING immediately after this code has
tested PF_EXITING and then the task at *p could proceed until we hit the
same race (whatever that is).

Perhaps taking p->sighand->siglock would fix that up, but that's just a
guess at this stage.
