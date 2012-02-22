From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFD] cgroup: about multiple hierarchies
Date: Wed, 22 Feb 2012 11:57:14 -0500
Message-ID: <20120222165714.GC4128__38267.5340785228$1329929853$gmane$org@redhat.com>
References: <20120221211938.GE12236@google.com>
	<20120222163858.GB4128@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120222163858.GB4128-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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

On Wed, Feb 22, 2012 at 11:38:58AM -0500, Vivek Goyal wrote:

[..]
> > 
> >    Most importantly, we would need to clean up how nesting is handled
> >    across different subsystems.  Handling internal and leaf nodes as
> >    equals simply can't work.  Membership should be recursive, and for
> >    subsystems which can't support proper nesting, the right thing to
> >    do would be somehow ensuring that only single node in the path from
> >    root to leaf is active for the controller.  We may even have to
> >    introduce an alternative of operation to support this (yuck).
> > 
> >    This path would require the most amount of work and we would be
> >    excluding a feature - support for multiple orthogonal
> >    categorizations - which has been available till now, probably
> >    through deprecation process spanning years; however, this at least
> >    gives us hope that we may reach sanity in the end, how distant that
> >    end may be.  Oh, hope. :)
> 
> Yes this is something needs to be cleaned up. Everybody seems to have
> dealt with hiearchy in its own way.
> 
> For blkio controller, initially we provided fully nested hiearchies like
> cpu controller but then implementation became too complex (CFQ is already
> complicated and implementing fully nested hiearchies made it much more
> complicated without any significant gain). So, I converted it into
> flat model where internally we treat the whole hierarchy flat. (It
> might have been a bad decision though).

IIRC, another reason to implement flat hierachy was that some people
believed that's more natural way of doing things. For example, when
you talk about cgroup, people ask, ok, give me a cgroup with 25% IO
bandwidth. Now this does not come naturally with completely nested
hierarchies where task and groups are treated at the same level. As
group's peer tasks share the bandwidth, and task come and go a group's
% share varies dynamically.

Again, it does not mean I am advocating flat hiearchy. I am just wondering
in case of fully nested hierarchies (task at same level as groups), how
does one explain it to a layman user who understands things in terms of
% of resources.

Just saying that your group has weight X does not mean much in absolute
terms. And % bandwidth achieved by group will vary dynamically. (Hey,
you told me that one can divide the system resources somewhat
deterministically. But bandwidth varying dynamically does not sound the
same).

Thanks
Vivek
