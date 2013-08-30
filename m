From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [REVIEW][PATCH 1/5] namespaces: Simplify copy_namespaces so it
	is clear what is going on.
Date: Fri, 30 Aug 2013 16:10:03 +0000
Message-ID: <20130830161003.GA18857@mail.hallyn.com>
References: <87ob8gys0d.fsf@xmission.com>
 <87ioyoyryr.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87ioyoyryr.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> 
> Remove the test for the impossible case where tsk->nsproxy == NULL.  Fork
> will never be called with tsk->nsproxy == NULL.
> 
> Only call get_nsproxy when we don't need to generate a new_nsproxy,
> and mark the case where we don't generate a new nsproxy as likely.
> 
> Remove the code to drop an unnecessarily acquired nsproxy value.
> 
> Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>

> ---
>  kernel/nsproxy.c |   35 +++++++++++------------------------
>  1 files changed, 11 insertions(+), 24 deletions(-)
> 
> diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
> index d9afd2563..a1ed011 100644
> --- a/kernel/nsproxy.c
> +++ b/kernel/nsproxy.c
> @@ -125,22 +125,16 @@ int copy_namespaces(unsigned long flags, struct task_struct *tsk)
>  	struct nsproxy *old_ns = tsk->nsproxy;
>  	struct user_namespace *user_ns = task_cred_xxx(tsk, user_ns);
>  	struct nsproxy *new_ns;
> -	int err = 0;
>  
> -	if (!old_ns)
> +	if (likely(!(flags & (CLONE_NEWNS | CLONE_NEWUTS | CLONE_NEWIPC |
> +			      CLONE_NEWPID | CLONE_NEWNET)))) {
> +		get_nsproxy(old_ns);
>  		return 0;
> -
> -	get_nsproxy(old_ns);
> -
> -	if (!(flags & (CLONE_NEWNS | CLONE_NEWUTS | CLONE_NEWIPC |
> -				CLONE_NEWPID | CLONE_NEWNET)))
> -		return 0;
> -
> -	if (!ns_capable(user_ns, CAP_SYS_ADMIN)) {
> -		err = -EPERM;
> -		goto out;
>  	}
>  
> +	if (!ns_capable(user_ns, CAP_SYS_ADMIN))
> +		return -EPERM;
> +
>  	/*
>  	 * CLONE_NEWIPC must detach from the undolist: after switching
>  	 * to a new ipc namespace, the semaphore arrays from the old
> @@ -149,22 +143,15 @@ int copy_namespaces(unsigned long flags, struct task_struct *tsk)
>  	 * it along with CLONE_NEWIPC.
>  	 */
>  	if ((flags & (CLONE_NEWIPC | CLONE_SYSVSEM)) ==
> -		(CLONE_NEWIPC | CLONE_SYSVSEM)) {
> -		err = -EINVAL;
> -		goto out;
> -	}
> +		(CLONE_NEWIPC | CLONE_SYSVSEM)) 
> +		return -EINVAL;
>  
>  	new_ns = create_new_namespaces(flags, tsk, user_ns, tsk->fs);
> -	if (IS_ERR(new_ns)) {
> -		err = PTR_ERR(new_ns);
> -		goto out;
> -	}
> +	if (IS_ERR(new_ns))
> +		return  PTR_ERR(new_ns);
>  
>  	tsk->nsproxy = new_ns;
> -
> -out:
> -	put_nsproxy(old_ns);
> -	return err;
> +	return 0;
>  }
>  
>  void free_nsproxy(struct nsproxy *ns)
> -- 
> 1.7.5.4
