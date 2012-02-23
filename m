From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFD] cgroup: about multiple hierarchies
Date: Thu, 23 Feb 2012 16:38:47 -0500
Message-ID: <20120223213847.GK19691@redhat.com>
References: <20120221211938.GE12236@google.com>
	<20120222163858.GB4128@redhat.com>
	<20120222165714.GC4128@redhat.com>
	<1329990094.24994.64.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1329990094.24994.64.camel@twins>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Cc: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, Lennart Poettering <lennart-mdGvqq1h2p+GdvJs77BJ7Q@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Feb 23, 2012 at 10:41:34AM +0100, Peter Zijlstra wrote:
> On Wed, 2012-02-22 at 11:57 -0500, Vivek Goyal wrote:
> > 
> > Again, it does not mean I am advocating flat hiearchy. I am just wondering
> > in case of fully nested hierarchies (task at same level as groups), how
> > does one explain it to a layman user who understands things in terms of
> > % of resources. 
> 
> If your complete control is % based then I would assume its a % of a %.
> Simple enough.

But % of % will vary dynamically and not be static. So if root has got
100% of resources and we want 25% of that for a group, then hierarchy
might look as follows.

				root
				/ | \
			       T1 T2 g1

T1, T2 are tasks and g1 is the group needing 25% of root's resources. Now
number of tasks running in parallel to g1 will determine its effective %
and tasks come and go. So the only way to do this would be that move T1
and T2 in a child group under root and make sure new tasks don't show up
in root. 

Otherwise creating a group under root does not ensure that you get minimum
% of resource. It just makes sure that you can't get more than 25% of
% resources when things are tight.

> 
> If its bandwidth based then simply don't allow a child to consume more
> bandwidth than its parent, also simple.

In case of absolute limit, things are somewhat simpler. A group is not impacted
by its peer tasks/groups that much. Well, there is also an issue and that
is how do all the children of a group share the resources. So assume
following.

				  g1
				/ | \
			       T1 T2 g2

Assume g1 has 100MB/s limit and g2 has 90MB/s limit too. Now how this
100MB/s is divided among T1, T2 and g2? Round robin or do proportional
division based on weights.  I think for cpu scheduler it can do
proportional division as everything is implemented in single layer. For
blkio, trottling is stacked on top of proportional. So I guess, I can
do round robin between T1, T2 and g2 and also make sure total of T1, T2
and g2 does not cross g1's bandwidth.

So upper limit is not that big a issue. Proportional one does become
one with effective % varying dynamically.

Thanks
Vivek
