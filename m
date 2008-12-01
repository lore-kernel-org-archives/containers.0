From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC v10][PATCH 02/13] Checkpoint/restart: initial documentation
Date: Mon, 01 Dec 2008 10:15:32 -0800
Message-ID: <1228155332.2971.60.camel__43609.9377031953$1228155604$gmane$org@nimitz>
References: <1227747884-14150-1-git-send-email-orenl@cs.columbia.edu>
	<1227747884-14150-3-git-send-email-orenl@cs.columbia.edu>
	<20081128104554.GP28946@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20081128104554.GP28946-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Linus Torvalds <torvalds-3NddpPZAyC0@public.gmane.org>, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, 2008-11-28 at 10:45 +0000, Al Viro wrote:
> On Wed, Nov 26, 2008 at 08:04:33PM -0500, Oren Laadan wrote:
> > +Currently, namespaces are not saved or restored. They will be treated
> > +as a class of a shared object. In particular, it is assumed that the
> > +task's file system namespace is the "root" for the entire container.
> > +It is also assumed that the same file system view is available for the
> > +restart task(s). Otherwise, a file system snapshot is required.
> 
> That is to say, bindings are not handled at all.

Sadly, no.  I'm trying to convince Oren that this is important, but I've
been unable to do so thus far.  I'd appreciate any particularly
pathological cases you can think of.

There are two cases here that worry me.  One is the case where we're
checkpointing a container that has been off in its own mount namespace
doing bind mounts to its little heart's content.  We want to checkpoint
and restore the sucker on the same machine.  In this case, we almost
certainly want the kernel to be doing the restoration of the binds.

The other case is when we're checkpointing, and moving to a completely
different machine.  The new machine may have a completely different disk
layout and *need* the admin doing the sys_restore() to set up those
binds differently because of space constraints or whatever.

For now, we're completely assuming the second case, where the admin
(userspace) is responsible for it, and punting.  Do you think this is
something we should take care of now, early in the process?

> > +* What additional work needs to be done to it?
> 
> > +We know this design can work.  We have two commercial products and a
> > +horde of academic projects doing it today using this basic design.
> 
> May I use that for a t-shirt, please?  With that quote in foreground, and
> pus-yellow-greenish "MACH" serving as background.  With the names of products
> and projects dripping from it...

*Functionally* we know this design can work.  Practically, in Linux, I
have no freaking idea.  The hard part isn't getting it working, of
course.  The hard part is getting something that doesn't step on top of
everyone else's toes in the kernel and, at the same time, is actually
*maintainable*.

-- Dave
