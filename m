From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [RFC PATCH 4/4] allow killing tasks in your own or child userns
Date: Fri, 10 Dec 2010 03:16:34 -0800
Message-ID: <m14oal3mjx.fsf__28316.1650914282$1291979866$gmane$org@fess.ebiederm.org>
References: <20101209172027.GA10085@mail.hallyn.com>
	<20101209172843.GA10155@mail.hallyn.com>
	<20101209173050.GA10206@mail.hallyn.com>
	<20101209173245.GB10206@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20101209173245.GB10206-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org> (Serge E. Hallyn's
	message of "Thu, 9 Dec 2010 17:32:45 +0000")
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
Cc: LSM <linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Kees Cook <kees.cook-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, kernel list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

"Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> writes:

> Changelog:
> 	Dec 8: Fixed bug in my check_kill_permission pointed out by
> 	       Eric Biederman.
>
> To test:
> 	1. Test killing tasks as usual.  No change.
> 	2. Clone a new user namespace without a new pidns.
> 	   a. You CAN kill -CONT tasks in your thread group but outside
> 	      your user ns.
> 	   b. You can NOT otherwise kill tasks outside your user_ns.
> 	   c. Inside your new userns, signal semantics are as normal
> 	      with respect to userids, CAP_KILL, and thread groups.
>
> Signed-off-by: Serge E. Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> ---
>  kernel/signal.c |   27 ++++++++++++++++++++++-----
>  1 files changed, 22 insertions(+), 5 deletions(-)
>
> diff --git a/kernel/signal.c b/kernel/signal.c
> index 4e3cff1..677025c 100644
> --- a/kernel/signal.c
> +++ b/kernel/signal.c
> @@ -635,6 +635,27 @@ static inline bool si_fromuser(const struct siginfo *info)
>  		(!is_si_special(info) && SI_FROMUSER(info));
>  }
>  
> +static inline int kill_ok_by_cred(struct cred *cred, struct cred *tcred)
> +{
Nit: You should just pass in the target task here.
Making it abundantly clear where current and tcred come from.
ns_capable implicitly uses current which is a little surprising
when everything else is being passed in, but makes perfect sense
in this context.

> +	if (cred->user->user_ns != tcred->user->user_ns) {
> +		/* userids are not equivalent - either you have the
> +		   capability to the target user ns or you don't */
> +		if (ns_capable(tcred->user->user_ns, CAP_KILL))
> +			return 1;
> +		return 0;
> +	}
> +
> +	/* same user namespace - usual credentials checks apply */
> +	if ((cred->euid ^ tcred->suid) &&
> +	    (cred->euid ^ tcred->uid) &&
> +	    (cred->uid  ^ tcred->suid) &&
> +	    (cred->uid  ^ tcred->uid) &&
> +	    !ns_capable(tcred->user->user_ns, CAP_KILL))
> +		return 0;
> +
> +	return 1;
> +}
> +
>  /*
>   * Bad permissions for sending the signal
>   * - the caller must hold the RCU read lock
> @@ -659,11 +680,7 @@ static int check_kill_permission(int sig, struct siginfo *info,
>  	cred = current_cred();
>  	tcred = __task_cred(t);
>  	if (!same_thread_group(current, t) &&
> -	    (cred->euid ^ tcred->suid) &&
> -	    (cred->euid ^ tcred->uid) &&
> -	    (cred->uid  ^ tcred->suid) &&
> -	    (cred->uid  ^ tcred->uid) &&
> -	    !capable(CAP_KILL)) {
> +	    !kill_ok_by_cred(cred, tcred)) {
>  		switch (sig) {
>  		case SIGCONT:
>  			sid = task_session(t);
