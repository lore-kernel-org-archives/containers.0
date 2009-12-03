From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH v19-rc2] shmem_restore needs to use ckpt_obj_try_fetch
Date: Wed, 02 Dec 2009 19:16:50 -0500
Message-ID: <4B170372.7050903@cs.columbia.edu>
References: <20091202221349.GA15335@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091202221349.GA15335-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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


Oh, we missed it when introducing ckpt_obj_try_fetch()...
Adding now.

thanks,

Oren.

Serge E. Hallyn wrote:
> Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  mm/shmem.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/shmem.c b/mm/shmem.c
> index ee64a63..caa1c6a 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -2419,7 +2419,7 @@ int shmem_restore(struct ckpt_ctx *ctx,
>  	struct file *file;
>  	int ret = 0;
>  
> -	file = ckpt_obj_fetch(ctx, h->ino_objref, CKPT_OBJ_FILE);
> +	file = ckpt_obj_try_fetch(ctx, h->ino_objref, CKPT_OBJ_FILE);
>  	if (PTR_ERR(file) == -EINVAL)
>  		file = NULL;
>  	if (IS_ERR(file))
