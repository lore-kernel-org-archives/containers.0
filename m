From: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [RFD] cgroup: about multiple hierarchies
Date: Thu, 23 Feb 2012 12:47:01 -0600
Message-ID: <20120223184701.GA4394@vostro.hallyn.com>
References: <20120221211938.GE12236@google.com>
	<20120221212106.GF12236@google.com>
	<4F44EEE4.2000809@parallels.com>
	<20120223074526.GA15835@mail.hallyn.com>
	<20120223172915.GC22536@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120223172915.GC22536-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, Lennart Poettering <lennart-mdGvqq1h2p+GdvJs77BJ7Q@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Tejun Heo (tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org):
> Hey, Serge.
> 
> On Thu, Feb 23, 2012 at 07:45:26AM +0000, Serge E. Hallyn wrote:
> > > >>Documentation/cgroups.txt seems to be written with this consideration
> > > >>on mind.  It's giving an example of applying limits accoring to two
> > > >>orthogonal categorizations - user groups (profressors, students...)
> > > >>and applications (WWW, NFS...).  While it may sound like a valid use
> > > >>case, I'm very skeptical how useful or common mixing such orthogonal
> > > >>categorizations in a single setup would be.
> > 
> > My first inclination is to agree, but counterexamples do come to mind.
> > 
> > I could imagine a site saying "users can run (X) (say, ftpds), but the
> > memory consumed by all those ftpds must not be > 10% total RAM".  At
> > the same time, they may run several apaches but want them all locked to
> > two of the cpus.
> 
> Orthogonal hierarchies is a feature and it does allow use cases which

Of course.  Note that while I used myself in the examples, I'm not
opposed to any of what you've suggested.  Just trying to raise
discussion.

> aren't possible to support otherwise.  It's not too difficult to come
> up with a use case crafted to exploit the feature.  The main thing is
> whether the added functionality justifies the complexity and other

And (somehow) I think we need to get input from the users - the ones not
on lkml.  There is an end-user summit coming up, right?  Perhaps this
question should be floated there?

> disadvantages described earlier in the thread.  To me, the scenarios
> seem not realistic, common place or essential enough.
> 
> Also, it's not like there's only one problem to solve these issues.
> It may not be exactly the same thing but that's just part of the
> trade-off game we all play.
> 
> > It might be worth a formal description of the new limits on use cases
> > such changes (both dropping support for orthogonal cgroups, and limiting
> > cgroups hierarchies to a mirror pstrees, separately) would bring.
> 
> The word "formal" scares me. :)

The upside would be a clear explanation of what userspace can do to
work around the more limited kernel functionality.

> > To me personally the hierarchy limitation is more worrying.  There have
> > been times when I've simply created cgroups for 'compile' and 'image
> > build', with particular cpu and memory limits.  If I started a second
> > simultaneous compile, I'd want both compiles confined together.  (That's
> > not to say the simplification might not be worth it, just bringing up
> > the other side)
> 
> Yeah, that's an interesting point, but wouldn't something like the
> following work too?
> 
> 1. create_cgroup --cpu 40% --mem 20% screen
> 2. tell screen to create as many build screens you want
> 3. issue builds from those screens

That works for a single user.  Gets more complicated if you have multiple
users but still want to confine compiles differently from other workloads.

Still, we now have 'namespace attach', so even if we generally shadow
pstree with the cgroups, perhaps we could implement a cgroup transfer
much more cleanly than the current cgroup attach stuff.

Or, maybe it's just not something users would deem worthwhile.  *I*
will be fine either way.

> To me, something like the above seems far more consistent with
> everything else we have on the system than moving tasks around by
> echoing pids to some sysfs file.

-serge
