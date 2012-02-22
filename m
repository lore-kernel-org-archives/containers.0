From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFD] cgroup: about multiple hierarchies
Date: Wed, 22 Feb 2012 11:38:58 -0500
Message-ID: <20120222163858.GB4128__6427.37886305458$1329928767$gmane$org@redhat.com>
References: <20120221211938.GE12236@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120221211938.GE12236-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
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

On Tue, Feb 21, 2012 at 01:19:38PM -0800, Tejun Heo wrote:

[..]
> 3. Head towards single hierarchy with the pie-in-the-sky goal of
>    merging things into process hierarchy in some distant future.
> 
>    The first step would be herding people to use a unified hierarchy
>    (ie. all subsystems mounted on a single cgroup tree) which is
>    controlled by single entity in userland (be it systemd or cgroupd,
>    cgroup-kit or whatever); however, even if we exclude supporting
>    orthogonal categorizations, there are good number of non-trivial
>    hurdles to clear before this can be realized.

Apart from orthogonal categorizations, one advantage of of multiple 
hierarchies is that you don't have to use a controller if you don't
want to. (Just don't create cgroup in controller's respective hierarchy).

This is not ideal but practically it might he helpful. In the sense
cgroups might not come cheap and different controllers might have different
overheads associated with it. For example, in blkio controller we can end
up idling a lot with increasing number of cgroups. In that case a better
way might be that use blkio controller cgroups selectively and that is
any workload which is destroying the performance of others, move it out
in a separate blkio group.

This is not ideal situation but that's how things currently are.

systemd by default creates in cgroups only cpu hierarchy (apart from named
systemd hiearchy to keep track of groups/processes). By default it does
not make use of other controllers and put any restrictions on
processes/services apart from cpu. Having a separate hiearchy for every
controller atleast easily allows that.

> 
>    Most importantly, we would need to clean up how nesting is handled
>    across different subsystems.  Handling internal and leaf nodes as
>    equals simply can't work.  Membership should be recursive, and for
>    subsystems which can't support proper nesting, the right thing to
>    do would be somehow ensuring that only single node in the path from
>    root to leaf is active for the controller.  We may even have to
>    introduce an alternative of operation to support this (yuck).
> 
>    This path would require the most amount of work and we would be
>    excluding a feature - support for multiple orthogonal
>    categorizations - which has been available till now, probably
>    through deprecation process spanning years; however, this at least
>    gives us hope that we may reach sanity in the end, how distant that
>    end may be.  Oh, hope. :)

Yes this is something needs to be cleaned up. Everybody seems to have
dealt with hiearchy in its own way.

For blkio controller, initially we provided fully nested hiearchies like
cpu controller but then implementation became too complex (CFQ is already
complicated and implementing fully nested hiearchies made it much more
complicated without any significant gain). So, I converted it into
flat model where internally we treat the whole hierarchy flat. (It
might have been a bad decision though).

So for blkio controller we can convert it into fully nested hierarchy
at the expense of more complex code in CFQ. I think memory cgroup
controller provides both flat and hierarchical mode. Keeping it fully
hierarchical also increases the cost as we need to traverse lot more
pointers for simple things like nested stats. On a system having
both systemd and libvirt, every virtual machine is already 3-4 level
deep in cgroup hierarchy.

Trying to make all the controllers uniform in terms of their treatment
of cgroup hiearchy sounds like a good thing to do. Once that is done,
one can probably see if it is worth to put all the controllers in a
single hierarchy.

Thanks
Vivek
