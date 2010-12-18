From: Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC 1/5] user namespaces: Add a user_namespace as
	creator/owner of uts_namespace
Date: Sat, 18 Dec 2010 09:56:51 -0800
Message-ID: <20101218175651.GA7453__11542.2408482575$1292695005$gmane$org@kroah.com>
References: <20101217152246.GA8221@mail.hallyn.com>
	<20101217152458.GA11162@mail.hallyn.com>
	<20101217173125.GA29982@kroah.com>
	<m18vzoryit.fsf@fess.ebiederm.org>
	<20101217195829.GB1410@kroah.com>
	<m1ipysm8us.fsf@fess.ebiederm.org>
	<20101217231527.GA21227@kroah.com>
	<m1vd2rlhez.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <m1vd2rlhez.fsf-+imSwln9KH6u2/kzUuoCbdi2O/JbrIOy@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Michael Kerrisk <michael.kerrisk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, kernel list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, LSM <linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Kees Cook <kees.cook-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Dec 17, 2010 at 10:32:52PM -0800, Eric W. Biederman wrote:
> Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org> writes:
> 
> > On Fri, Dec 17, 2010 at 12:40:11PM -0800, Eric W. Biederman wrote:
> >> Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org> writes:
> >> 
> >> >> There are also major benefits to have the version of something that is
> >> >> never freed never going away, because it means you can just reference it
> >> >> in code.  So while I would be happy to say this is special don't use a
> >> >> kref and roll the reference counting logic by hand, we aren't
> >> >> dynamically allocating init_uts_ns any time soon.
> >> >
> >> > Why have a reference count at all if it's not needed or used here?
> >> 
> >> We have to reference count every other uts namespace.
> >
> > Ok, that makes sense, then also please dynamically create this one, do
> > not create a static kref.
> 
> Nope.  It's a bad idea.  It messes up the kernel bootstrap if you do
> that, and it makes this one structure different from every other
> structure init_task uses.

{sigh}

Ok, but I really don't like this use.

Also, don't go messing with that ATOMIC_INIT() to be a higher value, as
this patch series did, as that really implies that it is being used
incorrectly, right?

thanks,

greg k-h
