From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH linux-cr] cr: fs/inode.c: make sure ckpt_obj_register()
	actually runs
Date: Tue, 13 Apr 2010 14:32:17 -0700
Message-ID: <20100413213217.GF25363@count0.beaverton.ibm.com>
References: <20100413203535.GA9187@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100413203535.GA9187-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

On Tue, Apr 13, 2010 at 03:35:35PM -0500, Serge E. Hallyn wrote:
> [ This is against Matt's code-shuffled patchset ]
> 
> So put it in its own, explicitly-called init function.

I did not spot the early return from inode_init(). So an alternate
fix is to move the #ifdef CONFIG_CHECKPOINT block up before
this early return:

        /* Hash may have been set up in inode_init_early */
        if (!hashdist)
                return;

hashdist is set to HASHDIST_DEFAULT which is probably different on
s390 from x86-32/64. At least that would explain why this wasn't
spotted in my earlier testing.

> 
> Without this, on my s390x sles11 system CKPT_OBJ_INODE does not,
> in fact, get registered.  With, it does, and cr_tests/bashckpt
> passes.
> 
> Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  fs/inode.c |   13 +++++++++----
>  1 files changed, 9 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/inode.c b/fs/inode.c
> index 1fcaf64..5121790 100644
> --- a/fs/inode.c
> +++ b/fs/inode.c
> @@ -1582,6 +1582,15 @@ static const struct ckpt_obj_ops ckpt_obj_inode_ops = {
>  	.ref_drop = obj_inode_drop,
>  	.ref_grab = obj_inode_grab,
>  };
> +
> +static int inode_ckpt_init(void)
> +{
> +	int ret = ckpt_obj_register(&ckpt_obj_inode_ops);
> +	printk(KERN_NOTICE "%s: ckpt_obj_register for inode returned %d\n",
> +		__func__, ret);
> +	return ret;
> +}
> +__initcall(inode_ckpt_init);
>  #endif
> 
>  void __init inode_init(void)
> @@ -1613,10 +1622,6 @@ void __init inode_init(void)
> 
>  	for (loop = 0; loop < (1 << i_hash_shift); loop++)
>  		INIT_HLIST_HEAD(&inode_hashtable[loop]);
> -
> -#ifdef CONFIG_CHECKPOINT
> -	ckpt_obj_register(&ckpt_obj_inode_ops);

The latest set does:

s/ckpt_obj_register/register_checkpoint_obj/

Cheers,
	-Matt Helsley
