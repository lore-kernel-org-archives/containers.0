From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 4/4] cgroup freezer: Add CHECKPOINTING state to
	safeguard container checkpoint
Date: Wed, 3 Jun 2009 11:18:40 -0500
Message-ID: <20090603161840.GD7848@us.ibm.com>
References: <cover.1244019829.git.matthltc@us.ibm.com>
	<89c3726813accffb7c51cd30ff93b79a4391f382.1244019829.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <89c3726813accffb7c51cd30ff93b79a4391f382.1244019829.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Matt Helsley (matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> The CHECKPOINTING state prevents userspace from unfreezing tasks until
> sys_checkpoint() is finished. When doing container checkpoint userspace
> will do:
> 
> 	echo FROZEN > /cgroups/my_container/freezer.state
> 	...
> 	rc = sys_checkpoint( <pid of container root> );
> 
> To ensure a consistent checkpoint image userspace should not be allowed
> to thaw the cgroup (echo THAWED > /cgroups/my_container/freezer.state)
> during checkpoint.
> 
> "CHECKPOINTING" can only be set on a "FROZEN" cgroup using the checkpoint
> system call. Once in the "CHECKPOINTING" state, the cgroup may not leave until
> the checkpoint system call is finished and ready to return. Then the
> freezer state returns to "FROZEN". Writing any new state to freezer.state while
> checkpointing will return EBUSY. These semantics ensure that userspace cannot
> unfreeze the cgroup midway through the checkpoint system call.
> 
> The cgroup_freezer_begin_checkpoint() and cgroup_freezer_end_checkpoint()
> make relatively few assumptions about the task that is passed in. However the
> way they are called in do_checkpoint() assumes that the root of the container
> is in the same freezer cgroup as all the other tasks that will be
> checkpointed.
> 
> Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> Cc: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> Cc: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> Cc: Cedric Le Goater <legoater-GANU6spQydw@public.gmane.org>
> Cc: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
> 
> Notes:
> 	Meant to work with Oren's checkpoint/restart v16-dev git tree.
>         Still needs testing.
>         As a side-effect this prevents the multiple tasks from entering the
>                 CHECKPOINTING state simultaneously. All but one will get -EBUSY.
> ---
>  Documentation/cgroups/freezer-subsystem.txt |   10 ++
>  checkpoint/checkpoint.c                     |    8 ++-
>  include/linux/freezer.h                     |    8 ++
>  kernel/cgroup_freezer.c                     |  128 +++++++++++++++++++-------
>  4 files changed, 117 insertions(+), 37 deletions(-)
> 
> diff --git a/Documentation/cgroups/freezer-subsystem.txt b/Documentation/cgroups/freezer-subsystem.txt
> index 41f37fe..92b68e6 100644
> --- a/Documentation/cgroups/freezer-subsystem.txt
> +++ b/Documentation/cgroups/freezer-subsystem.txt
> @@ -100,3 +100,13 @@ things happens:
>  		and returns EINVAL)
>  	3) The tasks that blocked the cgroup from entering the "FROZEN"
>  		state disappear from the cgroup's set of tasks.
> +
> +When the cgroup freezer is used to guard container checkpoint operations the
> +freezer.state may be "CHECKPOINTING". "CHECKPOINTING" can only be set on a
> +"FROZEN" cgroup using the checkpoint system call. Once in the "CHECKPOINTING"
> +state, the cgroup may not leave until the checkpoint system call returns the
> +freezer state to "FROZEN". Writing any new state to freezer.state while
> +checkpointing will return EBUSY. These semantics ensure that userspace cannot
> +unfreeze the cgroup midway through the checkpoint system call. Note that,
> +unlike "FROZEN" and "FREEZING", there is no corresponding "CHECKPOINTED"
> +state.
> diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
> index afc7300..d586a9b 100644
> --- a/checkpoint/checkpoint.c
> +++ b/checkpoint/checkpoint.c
> @@ -569,7 +569,10 @@ int do_checkpoint(struct ckpt_ctx *ctx, pid_t pid)
> 
>  	ret = init_checkpoint_ctx(ctx, pid);
>  	if (ret < 0)
> -		goto out;
> +		return ret;
> +	ret = cgroup_freezer_begin_checkpoint(ctx->root_task);
> +	if (ret < 0)
> +		return ret;
>  	ret = build_tree(ctx);
>  	if (ret < 0)
>  		goto out;
> @@ -597,6 +600,7 @@ int do_checkpoint(struct ckpt_ctx *ctx, pid_t pid)
>  	/* on success, return (unique) checkpoint identifier */
>  	ctx->crid = atomic_inc_return(&ctx_count);
>  	ret = ctx->crid;
> - out:
> +out:
> +	cgroup_freezer_end_checkpoint(ctx->root_task);
>  	return ret;
>  }

We have no guarantees that all tasks under ctx->root_task are in
the same freezer cgroup.  This presents a problem if we want to
make this guarantee which you're trying to make.

First, you need to update the may_checkpoint() check to check that
the tasks are CHECKPOINTING, not FROZEN.

But in addition, note that (a) there may be two parallel checkpoints of
separate tasksets (C and D), and (b) userspace may have mucked up
and put some tasks from set C into set D's cgroup.  That means that it's
possible that all of the may_checkpoint() tasks pass, but if D's
checkpoint finishes before C's, then some tasks will be unfrozen
before their checkpoint is complete.

So I guess now you need to enforce at may_checkpoint() that all tasks
being checkpointed are in ctx->root_task's freezer cgroup?

thanks,
-serge
