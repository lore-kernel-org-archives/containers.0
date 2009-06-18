From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 1/1] checkpoint_sem trivialities
Date: Thu, 18 Jun 2009 12:41:45 -0400
Message-ID: <4A3A6E49.6040806@cs.columbia.edu>
References: <20090616220410.GA7115@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090616220410.GA7115-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org


Applied.

Serge E. Hallyn wrote:
> fix a typo in a comment
> 
> rather than #include msg.h just so util.h doesn't break on struct msg_msg,
> just fwd-declare it.  Probably should be fixed in util.h itself?
> 
> Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  ipc/checkpoint_sem.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/ipc/checkpoint_sem.c b/ipc/checkpoint_sem.c
> index e6934dc..19e9402 100644
> --- a/ipc/checkpoint_sem.c
> +++ b/ipc/checkpoint_sem.c
> @@ -19,7 +19,7 @@
>  #include <linux/nsproxy.h>
>  #include <linux/ipc_namespace.h>
>  
> -#include <linux/msg.h>	/* needed for util.h that uses 'struct msg_msg' */
> +struct msg_msg;
>  #include "util.h"
>  
>  #include <linux/checkpoint.h>
> @@ -192,7 +192,7 @@ int restore_ipc_sem(struct ckpt_ctx *ctx)
>  	ckpt_debug("sem: do_semget key %d flag %#x id %d\n",
>  		 h->perms.key, semflag, h->perms.id);
>  	ret = do_semget(h->perms.key, h->sem_nsems, semflag, h->perms.id);
> -	ckpt_debug("sem: do_msgget ret %d\n", ret);
> +	ckpt_debug("sem: do_semget ret %d\n", ret);
>  	if (ret < 0)
>  		goto out;
>  
