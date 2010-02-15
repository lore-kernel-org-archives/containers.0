From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [user-cr][PATCH 1/2] restart: remount /proc for new tasks
	created with CLONE_NEWPID
Date: Mon, 15 Feb 2010 08:31:30 -0600
Message-ID: <20100215143130.GB28038@us.ibm.com>
References: <1266224833-10902-1-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1266224833-10902-1-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> Not doing this can be a pain for restarted software which relies
> on /proc...
> 
> This builds on a patch by Serge Hallyn, but also aims to address the
> future cases of hierarchical pid-ns:
> 
> 1) Before mounting the new /proc, first umount the old one, which
> isn't necessary anymore.
> 
> 2) Perform the unshare() together with the remount of /proc, so it
> will occur for every new pid-ns and not only for the first one.
> 
> Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
> ---
>  restart.c |   32 ++++++++++++++++++++++++++++++++
>  1 files changed, 32 insertions(+), 0 deletions(-)
> 
> diff --git a/restart.c b/restart.c
> index f3d33de..f42b456 100644
> --- a/restart.c
> +++ b/restart.c
> @@ -30,6 +30,7 @@
>  #include <asm/unistd.h>
>  #include <sys/syscall.h>
>  #include <sys/prctl.h>
> +#include <sys/mount.h>
> 
>  #include <linux/sched.h>
>  #include <linux/checkpoint.h>
> @@ -273,6 +274,8 @@ int global_child_collected;
>  int global_send_sigint = -1;
>  int global_sent_sigint;
> 
> +static int ckpt_remount_proc(void);
> +
>  static int ckpt_build_tree(struct ckpt_ctx *ctx);
>  static int ckpt_init_tree(struct ckpt_ctx *ctx);
>  static int ckpt_set_creator(struct ckpt_ctx *ctx, struct task *task);
> @@ -981,11 +984,36 @@ static int ckpt_probe_child(pid_t pid, char *str)
>  	return 0;
>  }
> 
> +/*
> + * Remount the /proc with a new instance: tasks that start a new
> + * pid-ns need a fresh mount of /proc to reflect their pid-ns.
> + */
> +static int ckpt_remount_proc(void)
> +{
> +	if (unshare(CLONE_NEWNS | CLONE_FS) < 0) {
> +		perror("unshare");
> +		return -1;
> +	}
> +	if (umount2("/proc", MNT_DETACH) < 0) {
> +		perror("umount -l /proc");
> +		return -1;
> +	}

I don't expect this to ever happen in practice, but *if*
somehow /proc were already unmounted, you'd fail restart
for no good reason.  I don't know that we care about a
failure to umount here.

In fact I suppose in a 'restart -r /opt/container1' /proc
might not yet be mounted after chroot?  So it's not all
that unlikely.

> +	if (mount("proc", "/proc", "proc", 0, NULL) < 0) {
> +		perror("mount -t proc");
> +		return -1;
> +	}
> +
> +	return 0;
> +}
> +
>  #ifdef CLONE_NEWPID
>  static int __ckpt_coordinator(void *arg)
>  {
>  	struct ckpt_ctx *ctx = (struct ckpt_ctx *) arg;
> 
> +	if (ckpt_remount_proc() < 0)
> +		return -1;
> +
>  	if (!ctx->args->wait)
>  		close(ctx->pipe_coord[0]);
> 
> @@ -1850,6 +1878,10 @@ int ckpt_fork_stub(void *data)
>  	struct task *task = (struct task *) data;
>  	struct ckpt_ctx *ctx = task->ctx;
> 
> +	/* tasks with new pid-ns need new /proc mount */
> +	if ((task->flags & TASK_NEWPID) && ckpt_remount_proc() < 0)
> +		return -1;
> +
>  	/*
>  	 * In restart into a new pid namespace (--pidns), coordinator
>  	 * is the container init, hence if it terminated permatutely
> -- 
> 1.6.3.3
