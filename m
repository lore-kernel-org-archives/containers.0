From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/1] cr: use a new capability to authorize c/r
Date: Wed, 13 May 2009 00:59:32 +0400
Message-ID: <20090512205932.GA4346@x200.localdomain>
References: <20090512150713.GA32064@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090512150713.GA32064-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

On Tue, May 12, 2009 at 10:07:13AM -0500, Serge E. Hallyn wrote:
> do you object to this patch?  The idea is to not give away any
> privilege not otherwise needed.

> --- a/checkpoint/sys.c
> +++ b/checkpoint/sys.c
> @@ -281,7 +281,7 @@ asmlinkage long sys_checkpoint(pid_t pid, int fd, unsigned long flags)
>  	if (flags & ~CKPT_USER_FLAGS)
>  		return -EINVAL;
>  
> -	if (!ckpt_unpriv_allowed && !capable(CAP_SYS_ADMIN))
> +	if (!ckpt_unpriv_allowed && !capable(CAP_CHECKPOINT_RESTART))
>  		return -EPERM;
>  
>  	if (pid == 0)
> @@ -318,7 +318,7 @@ asmlinkage long sys_restart(int crid, int fd, unsigned long flags)
>  	if (flags)
>  		return -EINVAL;
>  
> -	if (!ckpt_unpriv_allowed && !capable(CAP_SYS_ADMIN))
> +	if (!ckpt_unpriv_allowed && !capable(CAP_CHECKPOINT_RESTART))
>  		return -EPERM;
>  
>  	/* FIXME: for now, we use 'crid' as a pid */
> diff --git a/include/linux/capability.h b/include/linux/capability.h
> index 572b5a0..a593391 100644
> --- a/include/linux/capability.h
> +++ b/include/linux/capability.h
> @@ -357,7 +357,9 @@ struct cpu_vfs_cap_data {
>  
>  #define CAP_MAC_ADMIN        33
>  
> -#define CAP_LAST_CAP         CAP_MAC_ADMIN
> +#define CAP_CHECKPOINT_RESTART      34

I don't know if this is really needed.

If you allow restart(2) for everyone, you can during struct cred
restoration check if, say, capabilities coming from image are more
strict than capabilities of restorer, that aux groups are a subset of
aux groups of restorer and so on.

You still need these checks, otherwise CAP_CHECKPOINT_RESTART is much
more powerful than it suggests.

I'm going to try and see how hard will it be.
