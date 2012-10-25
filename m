From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 1/1] freezer: exec should clear PF_NOFREEZE along with
	PF_KTHREAD
Date: Thu, 25 Oct 2012 10:20:16 -0700
Message-ID: <20121025172016.GF11442__10733.4603592337$1351185638$gmane$org@htj.dyndns.org>
References: <1350426526-14254-1-git-send-email-tj@kernel.org>
	<1350426526-14254-5-git-send-email-tj@kernel.org>
	<20121022183453.GA24687@redhat.com>
	<20121022211822.GF5951@atj.dyndns.org>
	<20121023155533.GC16201@redhat.com>
	<20121024190651.GC12182@atj.dyndns.org>
	<20121025171236.GA6776@redhat.com>
	<20121025171256.GB6776@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20121025171256.GB6776-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rjw-KKrjLPT3xs0@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Oct 25, 2012 at 07:12:56PM +0200, Oleg Nesterov wrote:
> flush_old_exec() clears PF_KTHREAD but forgets about PF_NOFREEZE.
> 
> Signed-off-by: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

Probably needs Cc: stable.

  Acked-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>

How should this be routed?  -mm?  Andrew, can you please pick this up?

Thanks.

> ---
>  fs/exec.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/exec.c b/fs/exec.c
> index 8b9011b..0039055 100644
> --- a/fs/exec.c
> +++ b/fs/exec.c
> @@ -1083,7 +1083,8 @@ int flush_old_exec(struct linux_binprm * bprm)
>  	bprm->mm = NULL;		/* We're using it now */
>  
>  	set_fs(USER_DS);
> -	current->flags &= ~(PF_RANDOMIZE | PF_FORKNOEXEC | PF_KTHREAD);
> +	current->flags &=
> +		~(PF_RANDOMIZE | PF_FORKNOEXEC | PF_KTHREAD | PF_NOFREEZE);
>  	flush_thread();
>  	current->personality &= ~bprm->per_clear;
>  
> -- 
> 1.5.5.1
> 
> 

-- 
tejun
