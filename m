From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] Remove READ_IMPLIES_EXEC during restart
Date: Mon, 6 Apr 2009 13:17:48 -0500
Message-ID: <20090406181748.GA24751@us.ibm.com>
References: <1239039694-22332-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1239039694-22332-1-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Dan Smith (danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> On s390, all tasks have READ_IMPLIES_EXEC set in current->personality,
> which causes the restart process to map things like the stack and heap as
> executable.  During the restart process, remove this bit and restore the
> original personality afterwards.
> 
> This seems a little ugly, but I don't know that there's a better place for
> it.

Well imo the only other thing to do would be to do the same thing but
just around the main restart_memory function.

> Cc: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
> Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

> ---
>  checkpoint/restart.c |    7 +++++++
>  1 files changed, 7 insertions(+), 0 deletions(-)
> 
> diff --git a/checkpoint/restart.c b/checkpoint/restart.c
> index adebc1c..8958ec7 100644
> --- a/checkpoint/restart.c
> +++ b/checkpoint/restart.c
> @@ -13,6 +13,7 @@
>  #include <linux/wait.h>
>  #include <linux/file.h>
>  #include <linux/magic.h>
> +#include <linux/personality.h>
>  #include <linux/checkpoint.h>
>  #include <linux/checkpoint_hdr.h>
> 
> @@ -535,12 +536,18 @@ static int do_restart_root(struct cr_ctx *ctx, pid_t pid)
>  int do_restart(struct cr_ctx *ctx, pid_t pid)
>  {
>  	int ret;
> +	unsigned int original_personality;
> +	
> +	original_personality = current->personality;
> +	current->personality &= ~READ_IMPLIES_EXEC;
> 
>  	if (ctx)
>  		ret = do_restart_root(ctx, pid);
>  	else
>  		ret = do_restart_task(pid);
> 
> +	current->personality = original_personality;
> +
>  	/* on success, adjust the return value if needed [TODO] */
>  	return ret;
>  }
> -- 
> 1.6.1
> 
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
