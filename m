From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [RFC 4/5] user namespaces: allow killing tasks in your own or
	child userns
Date: Sat, 01 Jan 2011 15:10:19 -0800
Message-ID: <m1zkrkuso4.fsf__38880.8347205215$1293923485$gmane$org@fess.ebiederm.org>
References: <20101217152246.GA8221@mail.hallyn.com>
	<20101217152458.GA11162@mail.hallyn.com>
	<20101217152547.GB11162@mail.hallyn.com>
	<20101217152625.GC11162@mail.hallyn.com>
	<20101217152659.GD11162@mail.hallyn.com>
	<m14oacryar.fsf@fess.ebiederm.org>
	<20101217200903.GA15528@mail.hallyn.com>
	<m1d3p0qhl5.fsf@fess.ebiederm.org>
	<20110101044522.GA26476@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110101044522.GA26476-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org> (Serge E. Hallyn's
	message of "Sat, 1 Jan 2011 04:45:22 +0000")
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, kernel list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, LSM <linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Kees Cook <kees.cook-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

"Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> writes:

> Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
>> "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> writes:
>> 
>> > Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
>> >> > --- a/kernel/signal.c
>> >> > +++ b/kernel/signal.c
>> >> > @@ -659,11 +686,7 @@ static int check_kill_permission(int sig, struct siginfo *info,
>> >> >  	cred = current_cred();
>> >> >  	tcred = __task_cred(t);
>> >> Nit pick  you don't need to compute cred and tcred here now.
>> >
>> > Just to make sure I understand right: you mean wait until after the
>> > same_thread_group() check to save calculation in that case, right?
>> 
>> I mean cred and tcred are only use in kill_ok_by_cred.
>> So we can eliminate those two variables from check_kill_permission.
>
> Thanks for the review.  Here is an updated version.

This one looks good.

Reviewed-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

>
> Subject: [PATCH 4/5] allow killing tasks in your own or child userns
>
> Changelog:
> 	Dec 8: Fixed bug in my check_kill_permission pointed out by
> 	       Eric Biederman.
> 	Dec 13: Apply Eric's suggestion to pass target task into kill_ok_by_cred()
> 	        for clarity
> 	Dec 31: address comment by Eric Biederman:
> 		don't need cred/tcred in check_kill_permission.
>
> Signed-off-by: Serge E. Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> ---
>  kernel/signal.c |   36 ++++++++++++++++++++++++++++--------
>  1 files changed, 28 insertions(+), 8 deletions(-)
>
> diff --git a/kernel/signal.c b/kernel/signal.c
> index 4e3cff1..d890c99 100644
> --- a/kernel/signal.c
> +++ b/kernel/signal.c
> @@ -636,13 +636,39 @@ static inline bool si_fromuser(const struct siginfo *info)
>  }
>  
>  /*
> + * called with RCU read lock from check_kill_permission()
> + */
> +static inline int kill_ok_by_cred(struct task_struct *t)
> +{
> +	struct cred *cred = current_cred();
> +	struct cred *tcred = __task_cred(t);
> +
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
> +/*
>   * Bad permissions for sending the signal
>   * - the caller must hold the RCU read lock
>   */
>  static int check_kill_permission(int sig, struct siginfo *info,
>  				 struct task_struct *t)
>  {
> -	const struct cred *cred, *tcred;
>  	struct pid *sid;
>  	int error;
>  
> @@ -656,14 +682,8 @@ static int check_kill_permission(int sig, struct siginfo *info,
>  	if (error)
>  		return error;
>  
> -	cred = current_cred();
> -	tcred = __task_cred(t);
>  	if (!same_thread_group(current, t) &&
> -	    (cred->euid ^ tcred->suid) &&
> -	    (cred->euid ^ tcred->uid) &&
> -	    (cred->uid  ^ tcred->suid) &&
> -	    (cred->uid  ^ tcred->uid) &&
> -	    !capable(CAP_KILL)) {
> +	    !kill_ok_by_cred(t)) {
>  		switch (sig) {
>  		case SIGCONT:
>  			sid = task_session(t);
