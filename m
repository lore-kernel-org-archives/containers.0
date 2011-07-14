From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC PATCH 01/14] add Documentation/namespaces/user_namespace.txt
Date: Thu, 14 Jul 2011 02:37:30 +0000
Message-ID: <20110714023730.GA21662__8336.96106351471$1310611302$gmane$org@hallyn.com>
References: <1310513452-13397-2-git-send-email-serge@hallyn.com>
	<1310513452-13397-1-git-send-email-serge@hallyn.com>
	<31047.1310561116@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <31047.1310561116-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting David Howells (dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org):
> Serge Hallyn <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> wrote:

Thanks for the detailed comments, David.

> > +... The user namespace allows tasks to
> > +have different views of the uids and gids associated with tasks and
> > +other resources.
> 
> How does this relate to UIDs/GIDs stored on disk?

The current plan (see 'flexible uid mapping' at
https://wiki.ubuntu.com/UserNamespace) is:

The uid/gid stored on disk will be that in the init_user_ns.  Most
likely uid/gid in other namespaces will be stored in xattrs.  But
Eric was advocating (a few years ago) leaving the details up to
filesystems while providing a lib/ stock implementation.  See the
thread around here
http://www.mail-archive.com/devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org/msg09331.html

...

> > ... Opening such files will result in obtaining the 'user other'
> > permissions.
> 
> How about "Permission to open such files will be granted according to the
> 'user other' permissions."?
> 
> Do you mean 'user other' or just 'other'?

'user other'

> > ... UID comparisons will return false, and privilege will be denied.
> 
> UID and GID both?

Right, GID also part of the user namespace.

> You should probably be consistent about using all 'UID/GID' or all 'uid/gid'.
> I prefer the former as it's an acronym, but that's up to you.

ok.

> > When a task belonging to userid 500 in the initial user namespace
> 
> Is 500 special?  Or is this just a worked example?

example.

...

> > Working notes
> > =============
> > capable checks for actions related to syslog must be against the
> > init_user_ns until syslog is containerized.
> 
> Do you mean the 'capable' function?  If so, I recommend you suffix it with
> '()'.  Or did you mean 'Capability checks'?

I meant capability checks.

> > Same is true for reboot and power, control groups, devices, and time.
> > 
> > Perf actions (kernel/event/core.c for instance) will always be
> > constrained to init_user_ns.
> > 
> > Q:
> > Is accounting considered properly containerized wrt pidns?  (it
> > appears to be).  If so, then we can change the capable check in
> 
> 'capability check' or 'capable() call'?  Anyone reading this ought to know what
> capable() does.

Here I meant capable().  I definately see I need to be clearer.

> > kernel/acct.c to 'ns_capable(current_pid_ns()->user_ns, CAP_PACCT)'
> > 
...

> > For drivers/tty/tty_io.c and drivers/tty/vt/vt.c, we'll want to (for
> > some of them) target at the user_ns owning the tty.  That will have
> > to wait until we get userns owning files straightened out.
> 
> Target what at the user_ns?

Target the capability check at the user_ns.

> > We need to figure out how to label devices.  Should we just toss a user_ns
> > right into struct device?
> 
> Would that isolate a device and make it exclusively accessible by that user_ns?

I think so, which is probably too restrictive until a devices namespace
can help us work around it when needed.

Thanks again,

-serge
