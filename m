From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [PATCH 4/9] allow killing tasks in your own or child userns
Date: Wed, 23 Feb 2011 16:54:30 -0800
Message-ID: <20110223165430.863753f4.akpm__34246.8851282776$1298509096$gmane$org@linux-foundation.org>
References: <20110217150224.GA26334@mail.hallyn.com>
	<20110217150325.GD26395@mail.hallyn.com>
	<20110218155921.440f1137.akpm@linux-foundation.org>
	<20110224004818.GA11822@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110224004818.GA11822-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org>
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
Cc: xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, kernel list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, LSM <linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Kees Cook <kees.cook-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, 24 Feb 2011 00:48:18 +0000
"Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> wrote:

> Quoting Andrew Morton (akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org):
> > On Thu, 17 Feb 2011 15:03:25 +0000
> > "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> wrote:
> > 
> > >  /*
> > > + * called with RCU read lock from check_kill_permission()
> > > + */
> > > +static inline int kill_ok_by_cred(struct task_struct *t)
> > > +{
> > > +	const struct cred *cred = current_cred();
> > > +	const struct cred *tcred = __task_cred(t);
> > > +
> > > +	if (cred->user->user_ns == tcred->user->user_ns &&
> > > +	    (cred->euid == tcred->suid ||
> > > +	     cred->euid == tcred->uid ||
> > > +	     cred->uid  == tcred->suid ||
> > > +	     cred->uid  == tcred->uid))
> > > +		return 1;
> > > +
> > > +	if (ns_capable(tcred->user->user_ns, CAP_KILL))
> > > +		return 1;
> > > +
> > > +	return 0;
> > > +}
> > 
> > The compiler will inline this for us.
> 
> Is that simply true with everything (worth inlining) nowadays, or is
> there a particular implicit hint to the compiler that'll make that
> happen?

We've basically stopped inlining things nowadays.  gcc inlines
aggressively and sometimes we have to use noinline to stop it.  Also,
modern gcc's like to ignore the inline directive anwyay, so we have to
resort to __always_inline when we disagree.
