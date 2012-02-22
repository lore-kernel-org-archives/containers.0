From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [RFD] cgroup: about multiple hierarchies
Date: Wed, 22 Feb 2012 10:33:51 -0800
Message-ID: <20120222183351.GD32694__11016.2870646038$1329935645$gmane$org@google.com>
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
To: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, Lennart Poettering <lennart-mdGvqq1h2p+GdvJs77BJ7Q@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

Hey, Vivek.

On Wed, Feb 22, 2012 at 11:38:58AM -0500, Vivek Goyal wrote:
> Apart from orthogonal categorizations, one advantage of of multiple 
> hierarchies is that you don't have to use a controller if you don't
> want to. (Just don't create cgroup in controller's respective hierarchy).
> 
> This is not ideal but practically it might he helpful. In the sense
> cgroups might not come cheap and different controllers might have different
> overheads associated with it. For example, in blkio controller we can end
> up idling a lot with increasing number of cgroups. In that case a better
> way might be that use blkio controller cgroups selectively and that is
> any workload which is destroying the performance of others, move it out
> in a separate blkio group.

It should of course be possible to apply selective grouping on
different cgroups.  It's like any other layers on top of pstree -
sessions, program groups or containers.  Just group subtrees as you
see fit for each subsystem (there gotta be some fancy CS word for this
thing).  As long as those grouped trees are from the same base tree,
we can represent it in a single tree, just like we can just annotate
sessions and program groups in pstree.

So, as long as you don't want something orthogonal from pstree, it
should be fine.

> So for blkio controller we can convert it into fully nested hierarchy
> at the expense of more complex code in CFQ. I think memory cgroup
> controller provides both flat and hierarchical mode. Keeping it fully
> hierarchical also increases the cost as we need to traverse lot more
> pointers for simple things like nested stats. On a system having
> both systemd and libvirt, every virtual machine is already 3-4 level
> deep in cgroup hierarchy.

I don't think every controller should implement full nesting and
sharing the same hierarchy doesn't require it.  ie. if a controller
only wants to support flat hierarchy, just allow a single subgroup to
be active on any path between root and leaf.  We can add a flag or
helpers to support such mode of operation and controllers themselves
can treat all cgroups equally.

Thanks.

-- 
tejun
