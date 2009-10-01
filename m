From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH-user-cr] restart: handle dead/dummy tasks like ghosts
Date: Wed, 30 Sep 2009 22:26:50 -0500
Message-ID: <20091001032650.GA9491@us.ibm.com>
References: <1254360988-29553-1-git-send-email-orenl@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1254360988-29553-1-git-send-email-orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org):
> In "subtree" restart (restarting not inside a container), 'restart'
> uses prctl(PR_DEATH_SIGNAL,...) to ensure proper cleanup should the
> restart fail prematurely. The death_signal is sent, recursively, to
> all the descendants of root to force-kill them.
> 
> However, dead (dummy) tasks, marked with TASK_DEAD, used to exit
> during the creation of the task tree. Since the task is not within
> sys_restart it does not have the PF_RESTARTING, and therefore will
> send the death_signal its children as it exits.
> 
> To fix it, we observe that dead tasks are much like ghost tasks:
> they are expected to terminate from within sys_restart, and before
> the other tasks may resume execution. So we now treat dead (dummy)
> tasks similarly to ghost tasks.
> 
> Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

Hmm?  But at line 1540 you are still doing do_exit if it's
TASK_DEAD  :)

> ---
>  restart.c |   27 ++++++++-------------------
>  1 files changed, 8 insertions(+), 19 deletions(-)
> 
> diff --git a/restart.c b/restart.c
> index 07ffdc3..b810ca9 100644
> --- a/restart.c
> +++ b/restart.c
> @@ -1485,10 +1485,12 @@ static int ckpt_propagate_session(struct ckpt_ctx *ctx, struct task *task)
>   * needed. In the second pass the task forks the remainder of the
>   * children. In both passes, a child that is marked TASK_THREAD is
>   * created as a thread and a child that is marked TASK_SIBLING is
> - * created with parent inheritance. In the third pass, terminated
> - * tasks and temporary placeholders are cleaned up. Finally, the task
> - * either terminates if it is marked TASK_DEAD or calls sys_restart()
> - * which does not return.
> + * created with parent inheritance. Finally, the task will invoke
> + * sys_restart() which does not return (if successful).
> + *
> + * Tasks marked TASK_DEAD or TASK_GHOST are both destined to terminate
> + * anyway; both use flag RESTART_GHOST for sys_restart(), which will
> + * result in a call to do_exit().
>   */
>  static int ckpt_make_tree(struct ckpt_ctx *ctx, struct task *task)
>  {
> @@ -1534,17 +1536,6 @@ static int ckpt_make_tree(struct ckpt_ctx *ctx, struct task *task)
>  		}
>  	}
>  	
> -	/* 3rd pass: bring out your deads ... */
> -	for (child = task->children; child; child = child->next_sib) {
> -		if (child->flags & TASK_DEAD) {
> -			ret = waitpid(child->rpid, NULL, 0);
> -			if (ret < 0) {
> -				perror("waitpid");
> -				return -1;
> -			}
> -		}
> -	}
> -
>  	/* are we supposed to exit now ? */
>  	if (task->flags & TASK_DEAD) {
>  		ckpt_dbg("pid %d: task dead ... exiting\n", task->pid);
> @@ -1587,7 +1578,7 @@ static int ckpt_make_tree(struct ckpt_ctx *ctx, struct task *task)
>  	 * then exit (more precisely, killed). The RESTART_GHOST flag
>  	 * tells the kernel that they are not to be restored.
>  	 */
> -	if (task->flags & TASK_GHOST)
> +	if (task->flags & (TASK_GHOST | TASK_DEAD))
>  		flags |= RESTART_GHOST;
> 
>  	/* on success this doesn't return */
> @@ -1907,9 +1898,7 @@ static int ckpt_adjust_pids(struct ckpt_ctx *ctx)
> 
>  	/* read in 'pid_swap' data and adjust ctx->pids_arr */
>  	for (n = 0; n < ctx->tasks_nr; n++) {
> -		/* don't expect data from dead tasks */
> -		if (ctx->tasks_arr[n].flags & TASK_DEAD)
> -			continue;
> +		/* get pid info from next task */
>  		ret = read(ctx->pipe_in, &swap, sizeof(swap));
>  		if (ret < 0)
>  			ckpt_abort(ctx, "read pipe");
> -- 
> 1.6.0.4
> 
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
