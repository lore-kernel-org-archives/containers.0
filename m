From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 2/3] Add post-file deferqueue (v2)
Date: Wed, 09 Sep 2009 18:32:51 -0400
Message-ID: <4AA82D13.6040008@librato.com>
References: <1252508756-4278-1-git-send-email-danms@us.ibm.com>
	<1252508756-4278-3-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1252508756-4278-3-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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



Dan Smith wrote:
> This is the deferq bit of Matt's patch, which is needed by the subsequent
> socket patch.
> 
> Changes in v2:
>  - Allocate and destroy the deferqueue at context alloc/free time
> 
> Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> Cc: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Reviewed-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

(but see comment below).

> ---
>  checkpoint/files.c               |   17 +++++++++++++++++
>  checkpoint/sys.c                 |    7 +++++++
>  include/linux/checkpoint_types.h |    1 +
>  3 files changed, 25 insertions(+), 0 deletions(-)
> 
> diff --git a/checkpoint/files.c b/checkpoint/files.c
> index 204055b..3d99823 100644
> --- a/checkpoint/files.c
> +++ b/checkpoint/files.c
> @@ -21,6 +21,7 @@
>  #include <linux/syscalls.h>
>  #include <linux/checkpoint.h>
>  #include <linux/checkpoint_hdr.h>
> +#include <linux/deferqueue.h>
>  #include <net/sock.h>
>  
>  
> @@ -294,6 +295,14 @@ static int do_checkpoint_file_table(struct ckpt_ctx *ctx,
>  		if (ret < 0)
>  			break;
>  	}
> +	if (!ret) {
> +		ret = deferqueue_run(ctx->files_deferq);
> +		if (ret > 0) {
> +			pr_warning("c/r: files deferqueue had %d entries\n",
> +				   ret);
> +			ret = 0;

I'm unsure why the warning; perhaps you mean "ckpt_debug()" ?

> +		}
> +	}
>   out:
>  	kfree(fdtable);
>  	return ret;
> @@ -697,6 +706,14 @@ static struct files_struct *do_restore_file_table(struct ckpt_ctx *ctx)
>  		if (ret < 0)
>  			break;
>  	}
> +	if (!ret) {
> +		ret = deferqueue_run(ctx->files_deferq);
> +		if (ret > 0) {
> +			pr_warning("c/r: files deferqueue had %d entries\n",
> +				   ret);
> +			ret = 0;

Ditto.

Oren.
