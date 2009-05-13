From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH ckpt-v15] allocate checkpoint headers with kzalloc
Date: Wed, 13 May 2009 12:02:57 -0500
Message-ID: <20090513170257.GA18675@us.ibm.com>
References: <m3zldhxai8.fsf@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <m3zldhxai8.fsf-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Nathan Lynch (ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org):
> In a checkpoint image I noticed a lot of 0x6b (POISON_FREE) bytes
> corresponding to checkpoint_restart_block -- this indicates that we
> would write uninitialized kernel memory to the image in cases where
> slab allocator debugging is not enabled[1].
> 
> Use kzalloc in ckpt_hdr_get.

Yikes, yes, that's on par with a recent ecryptfs bug that did the
same thing.

Have you audited for other such potential privileged data leaks?
(besides "all sysvipc" which we know about :)

thanks,
-serge

> [1] slub's debug mode apparently initializes allocated buffers to
> POISON_FREE instead of POISON_INUSE, which confused me for a bit.
> Maybe I don't understand the intended meanings of the poison values.
> 
> Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
> ---
>  checkpoint/sys.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/checkpoint/sys.c b/checkpoint/sys.c
> index 255ebc1..34a226c 100644
> --- a/checkpoint/sys.c
> +++ b/checkpoint/sys.c
> @@ -117,7 +117,7 @@ int ckpt_kread(struct ckpt_ctx *ctx, void *addr, int count)
>   */
>  void *ckpt_hdr_get(struct ckpt_ctx *ctx, int len)
>  {
> -	return kmalloc(len, GFP_KERNEL);
> +	return kzalloc(len, GFP_KERNEL);
>  }
> 
>  /**
> -- 
> 1.6.0.6
> 
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
