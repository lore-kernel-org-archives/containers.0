From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: [RFC][PATCH 1/4] checkpoint-restart: general infrastructure
Date: Sat, 9 Aug 2008 00:23:51 +0200
Message-ID: <200808090023.51891.arnd__29025.8122179241$1218234382$gmane$org@arndb.de>
References: <20080807224033.FFB3A2C1@kernel> <1218221451.19082.36.camel@nimitz>
	<489CB3CA.6050304@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <489CB3CA.6050304-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Theodore Tso <tytso-3s7WtUTddSA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Friday 08 August 2008, Oren Laadan wrote:

> > Yeah, this is very true.  My guess is that we'll need something like
> > what we do with modversions. 
> 
> Exactly. The header should eventually contain sufficient information
> to describe the kernel version, configuration, compiler, cpu (arch and
> capabilities), and checkpoint code version.
> 
> How would you suggest to identify the origin tree with an identifier
> (or a text field) in the header ?

Including struct utsname in the header covers most of this. I supposed
you can't do it entirely safe, and you always need to be prepared for
malicious input data, so there probably isn't much point in getting
too fancy beyond what you need to do to prevent user errors.

> If it is preferred, we can change this to write a kernel message and
> return a special error telling that a logical error has occurred.

My recommendation in general is to make kernel code crash loudly if
there is a bug in the kernel itself. Returning error codes makes most
sense if they get sent back to the user, which then can make sense of
it, as documented in the man page of the syscall.

> > Yes, eventually.  I think one good point is that we should probably
> > remove this now so that we *have* to think about security implications
> > as we add each individual patch.  For instance, what kind of checking do
> > we do when we restore an mlock()'d VMA?
> > 
> > I'll pull this check out so it causes pain. (the good kind)
> 
> Hmmm... even if not strictly now, we *will* need admin privileges for
> the CR operations, for the following reasons:
> 
> checkpoint: we save the entire state of a set of processes to a file - so
> we must have privileges to do so, at least within (or with respect to) the
> said container. Even if we are the user who owns the container, we'll need
> root access within that container.
> 
> restart: we restore the entire set of a set of processes, which may require
> some privileged operations (again, at least within or with respect to the
> said container). Otherwise any user could inject any restart data into the
> kernel and create any set of processes with arbitrary permissions.
> 
> In a sense, we need something similar to granting ptrace access.

Exactly. There was a project that implemented checkpoint/restart through
ptrace (don't remember what it was called), so with certain limitations
it should also be possible to implement the syscalls so that any user that
can ptrace the tasks can also checkpoint them.

	Arnd <><
