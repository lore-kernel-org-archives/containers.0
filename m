From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [RFD] cgroup: about multiple hierarchies
Date: Wed, 22 Feb 2012 10:22:07 -0800
Message-ID: <20120222182207.GC32694__16306.8029018634$1329934944$gmane$org@google.com>
References: <20120221211938.GE12236@google.com>
	<20120222154501.GA1693@somewhere.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120222154501.GA1693-oHC15RC7JGTpAmv0O++HtFaTQe2KTcn/@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Lennart Poettering <lennart-mdGvqq1h2p+GdvJs77BJ7Q@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>
List-Id: containers.vger.kernel.org

Hey, Frederic.

On Wed, Feb 22, 2012 at 04:45:04PM +0100, Frederic Weisbecker wrote:
> > A related limitation is that as different subsystems don't know which
> > hierarchies they'll end up on, they can't cooperate.  Wouldn't it make
> > more sense if task counter is a separate thing watching the resources
> > and triggers different actions as conifgured - be it failing forks or
> > freezing?
> 
> For this particular example, I think we'd better have a file in which
> a task can poll and get woken up when the task limit has been reached.
> Then that task can decide to freeze or whatever.

Yes, that may be a solution but to "guarantee" that the limit is never
breached, we need to stop it first somehow.  Probably making freezing
the default behavior with userland notifier (inotify event should
suffice) should do, which we can't do now. :(

> > 1. We're screwed anyway.  Just don't worry about it and continue down
> >    on this path.  Can't get much worse, right?
> > 
> >    This approach has the apparent advantage of not having to do
> >    anything and is probably most likely to be taken.  This isn't ideal
> >    but hey nothing is. :P
> 
> Thing is we have an ABI now and it has been there for a while now. Aren't
> we stuck with it? I'm no big fan of that multiple hierarchies thing either
> but now I fear we have to support it.

Well, yes and no.  While maintaining userland ABI is very important,
its importance isn't infinite and there are different types of
userland ABIs.  We definitely don't want to screw with syscalls.  We
should keep userland visible dynamic files which are used by common
usertools stable at almost all costs.  When it comes over to system
interface which is used mostly by base system tools, it can be a bit
flexible.  If the ABI in question is an optional thing, we probably
can be slightly more flexible.

We of course can't change things drastically.  It should be done
carefully with rather long deprecation period, but it can be done and
in fact isn't too uncommon.  Stuff under /sysfs tends to be somewhat
volatile and sysfs itself went through several ABI incompatible
iterations.

So, we can transition in baby steps.  e.g. we can first implement
proper nesting behavior without changing the default behavior and then
the base system can be updated to mount and control all subsystems by
default (with configuration opt-outs) so that the hierarchy reflects
pstree, effectively driving people away from multiple hierarchies and
we can implement new features assuming the new structure.  After a few
years, the kernel can start whining about non-start hierarchies and
then eventually remove the support.  It's a long process but
definitely doable.

> > 2. Make it more flexible (and likely more complex, unfortunately).
> >    Allow the utility type subsystems to be used in multiple
> >    hierarchies.  The easiest and probably dirtiest way to achieve that
> >    would be embedding them into cgroup core.
> > 
> >    Thinking about doing this depresses me and it's not like I have a
> >    cheerful personality to begin with. :(
> 
> Another solution is to support a class of multi-bindable subsystems as in
> this old patch from Paul:
> 
> 	https://lkml.org/lkml/2009/7/1/578

Heh, yeah, this would be closer to the proper way to achieve
multi-attach but I can't help feeling that this just buries ourselves
deeper into s*it and we're already knee-deep.  If multiple hierarchies
is an essential feature, maybe, but, if it's not, and I'm extremely
skeptical that it is, why the hell would we want to go that way?

> It sounds to me more healthy to iterate only over subsystems in fork/exit.
> We probably don't want to add a new iteration over cgroups themselves
> on these fast path.

Hmmm?  Don't follow why this is relevant.

Thanks.

-- 
tejun
