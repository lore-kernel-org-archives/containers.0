From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: userns: targeted capabilities v5
Date: Fri, 18 Feb 2011 04:28:15 +0000
Message-ID: <20110218042815.GA9584__814.540932378982$1298003344$gmane$org@mail.hallyn.com>
References: <20110217150224.GA26334@mail.hallyn.com>
	<20110217162146.1b8e45e0.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110217162146.1b8e45e0.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, kernel list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, LSM <linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Kees Cook <kees.cook-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Andrew Morton (akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org):
> On Thu, 17 Feb 2011 15:02:24 +0000
> "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> wrote:
> 
> > Here is a repost of my previous user namespace patch, ported onto
> > last night's git head.
> > 
> > It fixes several things I was doing wrong in the last (v4)
> > posting, in particular:
> > 
> > 	1. don't set uts_ns->user_ns to current's when !CLONE_NEWUTS
> > 	2. add a ipc_ns->user_ns which owns ipc_ns, and use that to
> > 	   decide CAP_IPC_OWNER
> > 	3. fix logic flaw caused by bad parantheses
> > 	4. allow do_prlimit to current
> > 	5. don't always give root full privs to init_user_ns
> > 
> > The expected course of development for user namespaces is laid out
> > at https://wiki.ubuntu.com/UserNamespace.
> 
> Seems like a nice feature to be developing.
> 
> I worry about the maturity of it all at this stage.  How far along is
> it *really*?
> 
> Is anyone else working with you on developing and reviewing this work?

Thanks, Andrew.  I'm not sure what definition of 'maturity' you were
looking for here.  If you meant completeness of the feature, it's
definately not there.  Of the goals for user namespaces sandboxing
will be the quickest to mature.  Completing that will largely be an
exercise of running the breadth of the kernel looking for simple
uid/gid comparisons and making them namespace aware.

The design has been meshed around (publicly) on and off for many
years by eric and I.  This particular patchset has gotten some great
reviews by Eric Biederman and Bastian Blank (to who, unfortunately,
to this day I cannot send a direct email - they're always bounced).

As Eric said, this feature will have to go in incrementally.
Furthermore, each piece touches scary code so it's likely to go
pretty slowly.  My hope is less than a year for sandboxing, and
two years for containers.  It might go way faster, but experience
tells me that's unlikely  :)

thanks,
-serge
