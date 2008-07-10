From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: Checkpoint/restart (was Re: [PATCH 0/4] - v2 - Object creation
	with a specified id)
Date: Thu, 10 Jul 2008 12:32:46 -0500
Message-ID: <20080710173246.GA1857__35234.1649625034$1215711449$gmane$org@us.ibm.com>
References: <20080418054459.891481000@bull.net>
	<20080422193612.GA15835@martell.zuzino.mipt.ru>
	<1208890580.17117.14.camel@nimitz.home.sr71.net>
	<20080422210130.GA15937@martell.zuzino.mipt.ru>
	<1208904967.17117.51.camel@nimitz.home.sr71.net>
	<480ED9D5.1010906@parallels.com> <480FE037.2010302@cs.columbia.edu>
	<m1y74a7b4w.fsf@frodo.ebiederm.org>
	<1215709949.9398.15.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1215709949.9398.15.camel@nimitz>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Kirill Korotaev <dev-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, nick-dnCCA748QAperShJXdIFYw@public.gmane.org, Nadia.Derbey-6ktuUTfB/bM@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Dave Hansen (dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org):
> On Wed, 2008-07-09 at 18:58 -0700, Eric W. Biederman wrote:
> > In the worst case today we can restore a checkpoint by replaying all of
> > the user space actions that took us to get there.  That is a tedious
> > and slow approach.
> 
> Yes, tedious and slow, *and* minimally invasive in the kernel.  Once we
> have a tedious and slow process, we'll have some really good points when
> we try to push the next set of patches to make it less slow and tedious.
> We'll be able to describe an _actual_ set of problems to our fellow
> kernel hackers.
> 
> So, the checkpoint-as-a-corefile idea sounds good to me, but it
> definitely leaves a lot of questions about exactly how we'll need to do
> the restore.

Talking with Dave over irc, I kind of liked the idea of creating a new
fs/binfmt_cr.c that executes a checkpoint-as-a-coredump file.

One thing I do not like about the checkpoint-as-coredump is that it begs
us to dump all memory out into the file.  Our plan/hope was to save
ourselves from writing out most memory by:

	1. associating a separate swapfile with each container
	2. doing a swapfile snapshot at each checkpoint
	3. dumping the pte entries (/proc/self/)

If we do checkpoint-as-a-coredump, then we need userspace to coordinate
a kernel-generated coredump with a user-generated (?) swapfile snapshot.
But I guess we figure that out later.

-serge
