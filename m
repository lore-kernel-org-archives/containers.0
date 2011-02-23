From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/9] security: Make capabilities relative to the user
	namespace.
Date: Wed, 23 Feb 2011 13:43:52 +0000
Message-ID: <20110223134352.GA926__11377.9496671215$1298468752$gmane$org@mail.hallyn.com>
References: <29256.1298461209@redhat.com>
	<20110217150306.GB26395@mail.hallyn.com>
	<20110217150224.GA26334@mail.hallyn.com>
	<29617.1298462517@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <29617.1298462517-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, kernel list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, LSM <linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Kees Cook <kees.cook-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting David Howells (dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org):
> David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> 
> > >  	int (*capable) (struct task_struct *tsk, const struct cred *cred,
> > > -			int cap, int audit);
> > > +			struct user_namespace *ns, int cap, int audit);
> > 
> > Hmmm...  A chunk of the contents of the cred struct are user-namespaced.
> > Could you add the user_namespace pointer to the cred struct and thus avoid
> > passing it as an argument to other things.
> 
> Ah, no...  Ignore that, I think I see that you do need it.

Thanks for reviewing, David.

> > +int cap_capable(struct task_struct *tsk, const struct cred *cred,
> > +		struct user_namespace *targ_ns, int cap, int audit)
> >  {
> > -	return cap_raised(cred->cap_effective, cap) ? 0 : -EPERM;
> > +	for (;;) {
> > +		/* The creator of the user namespace has all caps. */
> > +		if (targ_ns != &init_user_ns && targ_ns->creator == cred->user)
> > +			return 0;
> 
> Why is that last comment so?  Why should the creating namespace sport all
> possible capabilities?  Do you have to have all capabilities available to you
> to be permitted create a new user namespace?

It's not the creating namespace, but the creating user, which has all caps.

So for instance, if uid 500 in init_user_ns creates a namespace, then:
  a. uid 500 in init_user_ns has all caps to the child user_ns, so it can
     kill the tasks in the userns, clean up, etc.
  b. uid X in any other child user_ns has no caps to the child user_ns.
  c. root in init_user_ns has whatever capabilities are in his pE to the
     child user_ns.  Again, this is so that the admin in any user_ns can
     clean up any messes made by users in his user_ns.

One of the goals of the user namespaces it to make it safe to allow
unprivileged users to create child user namespaces in which they have
targeted privilege.  Anything which happens in that child user namespace
should be:

  a. constrained to resources which the user can control anyway
  b. able to be cleaned up by the user
  c. (especially) able to be cleaned up by the privileged user in the
     parent user_ns.

> Also, would it be worth having a separate cap_ns_capable()?  Wouldn't most
> calls to cap_capable() only be checking the caps granted in the current user
> namespace?

Hm.  There is nsown_capable() which is targeted to current_userns(), but
that still needs to enable the caps for the privileged ancestors as
described above.

thanks,
-serge
