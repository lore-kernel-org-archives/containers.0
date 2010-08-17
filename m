From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [GIT PULL] notification tree - try 37!
Date: Mon, 16 Aug 2010 21:03:53 -0700
Message-ID: <20100817040353.GD3648__1207.19717019728$1282017885$gmane$org@count0.beaverton.ibm.com>
References: <1281110319.17812.21.camel@dhcp231-200.rdu.redhat.com>
	<20100807000624.GA14819@infradead.org>
	<1281208514.2609.25.camel@dhcp231-200.rdu.redhat.com>
	<201008162232.36873.agruen@suse.de>
	<1282016387.21419.113.camel@acb20005.ipt.aol.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1282016387.21419.113.camel-u/cB4NFi02V49Jlha2NJH1aTQe2KTcn/@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Eric Paris <eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Biederman Eric Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Michael Kerrisk <michael.kerrisk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Andreas Gruenbacher <agruen-l3A5Bk7waGM@public.gmane.org>, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, Aug 16, 2010 at 11:39:47PM -0400, Eric Paris wrote:
> On Mon, 2010-08-16 at 22:32 +0200, Andreas Gruenbacher wrote:
> > On Saturday 07 August 2010 21:15:14 Eric Paris wrote:
> > > On Fri, 2010-08-06 at 20:06 -0400, Christoph Hellwig wrote:
> > > > I'm also totally missing on any re-post of these patches or discussion
> > > > of the changes during the last development window.
> > > 
> > > I just searched lkml an fsdevel where I usually send everything don't
> > > see then.  I totally failed.
> > 
> > Oh yes.
> > 
> > This introduces two new syscalls which will be impossible to fix up after the 
> > fact, and those system calls are poorly documented: commits 2a3edf86 and 
> > 52c923dd document the initial versions (in the commit message!), but 
> > subsequent commits then extend that interface.  The interface for replying to 
> > events is not documented at all beyond the example code [1].  There is no 
> > documentation in Documentation/filesystems/, either.
> > 
> > 	[1] http://people.redhat.com/~eparis/fanotify/
> 
> I'll work on documentation.  Although it should be pointed out that the
> interface was sent to list many times with lots of discussion and
> feedback.  The only patches that didn't make the list were the last
> couple which changed internal notification semantics (and fscked with
> fput() but that patch, which caused problems, was specifically pointed
> out in this thread and reverted).
> 
> > Q: What happens when a process watching for FAN_OPEN_PERM or FAN_ACCESS_PERM 
> > events exits or dies while events are in flight?  I can't see anything in the 
> > code that would wake sleeping processes up when the fsnotify_group of the 
> > listener is torn down.
> 
> We can get stuck.  There was code which cleaned that up, but it got
> accidentally removed long ago when, upon review on list, I was told to
> remove all timeout code.  It's easy enough to fix up.  I'll post a patch
> this week.
> 
> > Q: What prevents the system from going out of memory when a listener decides 
> > to stop reading events or simply can't keep up?  There doesn't seem to be a 
> > limit on the queue depth.  Listeners currently need CAP_SYS_ADMIN, but somehow 
> > limiting the queue depth and throttling when things start to go bad still 
> > sounds like a reasonable thing to do, right?)
> 
> It's an interesting question and obviously one that I've thought about.
> You remember when we talked previously I said the hardest part left was
> allowing non-root users to use the interface.  It gets especially
> difficult when thinking about perm-events.  I was specifically told not
> to timeout or drop those.  But when dealing with non-root users using
> perm events?   As for pure notification we can do something like inotify
> does quite easily.
> 
> I'm not certain exactly what the best semantics are for non trusted
> users, so I didn't push any patches that way.  Suggestions welcome   :)

Hi Eric,

Sorry I haven't had a chance to look at the perm events. I think
user namespace and containers folks might be interested in them for
non-root users though.

[Adding userns/containers folks to Cc]

I'm guessing non-trusted users can be restricted to only get perm events
on stuff they already own. Plus make perm events by non-trusted users
unreliable yet failsafe -- return EACESS/EPERM when we have to timeout or
drop the events if I understand the issues correctly. Those rules plus user
namespaces would still be quite useful I think. Do they seem reasonable to
implement? Am I forgetting anything important?

Cheers,
	-Matt Helsley
