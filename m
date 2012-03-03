From: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [RFD] cgroup: about multiple hierarchies
Date: Sat, 3 Mar 2012 08:26:04 -0600
Message-ID: <20120303142604.GA13187__49298.5226134353$1330784786$gmane$org@peqn>
References: <20120221211938.GE12236@google.com>
	<m162em2efy.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <m162em2efy.fsf-+imSwln9KH6u2/kzUuoCbdi2O/JbrIOy@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, Lennart Poettering <lennart-mdGvqq1h2p+GdvJs77BJ7Q@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> 4.  Only allow a single controller per hierarchy.  So that we can
> make reasonable choice points.  If the hierarchy is to be about
> policy I am baffled by concept of putting multiple controllers in
> a single hierarchy.  Because where you clump things together for
> policy for one controller in general does not seem to be where you
> want to clump things together for another controller.

This I agree with.  The only reasonably use I've seen for the
composed hierarchies is the ns cgroup, which was the wrong tool
for what it wanted to do anyway.  With ns cgroup deprecated, every
modern setup I've seen mounts each cgroup separately.

> > So, I mean, I don't know.  What do other people think?  Is this a
> > unnecessary worry?  Are people generally happy with the way things
> > are?  Lennart, Kay, what do you guys think?
> 
> I think the current situation is crazy.
> 
> I especially think it is crazy that inside a container I can't create
> a fresh set of cgroup mounts, and establish a fresh "hierarchy" relative
> to the process that created the cgroup mounts.  It sucks that
> controllers may nest fine but hierarchies don't nest.

Again I agree here.  In the past there has been brought up the idea
of fake cgroup roots ( http://thread.gmane.org/gmane.linux.kernel/1197643 )
I haven't looked in detail, but I know some people hated this particular
idea.  But it tried to solve this problem.

Perhaps we can attack this in two stages.

1. get rid of the ability to compose cgroups.  See how much this
simplifies the code.

2. add the ability to somehow namespace the cgroup mounts to allow a
container to freshly mount cgroups.

-serge
