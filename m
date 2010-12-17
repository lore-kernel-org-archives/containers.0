From: Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC 1/5] user namespaces: Add a user_namespace as
	creator/owner of uts_namespace
Date: Fri, 17 Dec 2010 11:57:15 -0800
Message-ID: <20101217195715.GA1410__25998.6021476381$1292616896$gmane$org@kroah.com>
References: <20101217152246.GA8221@mail.hallyn.com>
	<20101217152458.GA11162@mail.hallyn.com>
	<20101217173125.GA29982@kroah.com> <20101217194645.GA3131@peq>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20101217194645.GA3131@peq>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Michael Kerrisk <michael.kerrisk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, kernel list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, LSM <linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Kees Cook <kees.cook-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Dec 17, 2010 at 01:46:45PM -0600, Serge Hallyn wrote:
> Quoting Greg KH (greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org):
> > > +extern struct user_namespace init_user_ns;
> > >  struct uts_namespace init_uts_ns = {
> > >  	.kref = {
> > >  		.refcount	= ATOMIC_INIT(2),
> > 
> > Wait, WTF?
> > 
> > You have a static kref and you try to automatically instanciate it here?
> 
> You're complaining about the pre-existing init_uts_ns right?

Yup.

> > As it's static, why are you even having a kref at all, what good does it
> > do you, you can't delete the thing,
> 
> Can't delete this one, but can delete all the uts namespaces, obviously.
> As with init_tgcred in kernel/cred.c.
> 
> It's initialized with a refcount which will keep it from ever getting
> freed.

That's my point.  You are getting "lucky" by creating a static kref.
Which is a totally pointless thing to do, right?

> > it's always around, so just remove
> > it entirely please.
> > 
> > Or, dynamically create it properly.  In other words, this is majorly
> > broken.
> 
> If we create it dynamically, then I don't think we can use it the way we
> do in kernel/utsname_sysctl.c for instance.

Why not?  It's just a pointer to the structure instead of the structure
itself, right?

thanks,

greg k-h
