From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [RFC 4/5] user namespaces: allow killing tasks in your own or
	child userns
Date: Fri, 17 Dec 2010 12:17:58 -0800
Message-ID: <m1d3p0qhl5.fsf__5226.88852292976$1292617237$gmane$org@fess.ebiederm.org>
References: <20101217152246.GA8221@mail.hallyn.com>
	<20101217152458.GA11162@mail.hallyn.com>
	<20101217152547.GB11162@mail.hallyn.com>
	<20101217152625.GC11162@mail.hallyn.com>
	<20101217152659.GD11162@mail.hallyn.com>
	<m14oacryar.fsf@fess.ebiederm.org>
	<20101217200903.GA15528@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20101217200903.GA15528-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org> (Serge E. Hallyn's
	message of "Fri, 17 Dec 2010 20:09:03 +0000")
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Michael Kerrisk <michael.kerrisk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, kernel list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, LSM <linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Kees Cook <kees.cook-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

"Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> writes:

> Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
>> > --- a/kernel/signal.c
>> > +++ b/kernel/signal.c
>> > @@ -659,11 +686,7 @@ static int check_kill_permission(int sig, struct siginfo *info,
>> >  	cred = current_cred();
>> >  	tcred = __task_cred(t);
>> Nit pick  you don't need to compute cred and tcred here now.
>
> Just to make sure I understand right: you mean wait until after the
> same_thread_group() check to save calculation in that case, right?

I mean cred and tcred are only use in kill_ok_by_cred.
So we can eliminate those two variables from check_kill_permission.

>> >  	if (!same_thread_group(current, t) &&
>> > -	    (cred->euid ^ tcred->suid) &&
>> > -	    (cred->euid ^ tcred->uid) &&
>> > -	    (cred->uid  ^ tcred->suid) &&
>> > -	    (cred->uid  ^ tcred->uid) &&
>> > -	    !capable(CAP_KILL)) {
>> > +	    !kill_ok_by_cred(t)) {
>> >  		switch (sig) {
>> >  		case SIGCONT:
>> >  			sid = task_session(t);


Eric
