From: Bastian Blank <bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH 05/08] Allow ptrace from non-init user namespaces
Date: Fri, 14 Jan 2011 15:46:09 +0100
Message-ID: <20110114144608.GA20945__16100.5279901021$1295016505$gmane$org@wavehammer.waldi.eu.org>
References: <20110111064342.GA27515@mail.hallyn.com>
	<20110111064439.GF27515@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110111064439.GF27515-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, kernel list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, LSM <linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Kees Cook <kees.cook-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

This mail did not show up in my inbox, even if I'm listed as receipient.
I only got a copy via the mailinglist.

On Tue, Jan 11, 2011 at 06:44:39AM +0000, Serge E. Hallyn wrote:
> diff --git a/kernel/ptrace.c b/kernel/ptrace.c
> index 99bbaa3..ec7605d 100644
> --- a/kernel/ptrace.c
> +++ b/kernel/ptrace.c
> @@ -134,21 +134,24 @@ int __ptrace_may_access(struct task_struct *task, unsigned int mode)
>  		return 0;
>  	rcu_read_lock();
>  	tcred = __task_cred(task);
> -	if ((cred->uid != tcred->euid ||
> -	     cred->uid != tcred->suid ||
> -	     cred->uid != tcred->uid  ||
> -	     cred->gid != tcred->egid ||
> -	     cred->gid != tcred->sgid ||
> -	     cred->gid != tcred->gid) &&
> -	    !capable(CAP_SYS_PTRACE)) {
> -		rcu_read_unlock();
> -		return -EPERM;
> -	}
> +	if (cred->user->user_ns == tcred->user->user_ns &&
> +	    (cred->uid == tcred->euid &&
> +	     cred->uid == tcred->suid &&
> +	     cred->uid == tcred->uid  &&
> +	     cred->gid == tcred->egid &&
> +	     cred->gid == tcred->sgid &&
> +	     cred->gid == tcred->gid))
> +		goto ok;
> +	if (ns_capable(tcred->user->user_ns, CAP_SYS_PTRACE))
> +		goto ok;
> +	rcu_read_unlock();
> +	return -EPERM;
> +ok:

This is wrong. Please move that out into functions if you are unable to
get the conditions right.

Bastian

-- 
If a man had a child who'd gone anti-social, killed perhaps, he'd still
tend to protect that child.
		-- McCoy, "The Ultimate Computer", stardate 4731.3
