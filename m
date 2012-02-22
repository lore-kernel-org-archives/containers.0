From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [RFD] cgroup: about multiple hierarchies
Date: Wed, 22 Feb 2012 10:43:18 -0800
Message-ID: <20120222184318.GE32694__3523.46150107241$1329936210$gmane$org@google.com>
References: <20120221211938.GE12236@google.com>
	<20120222163858.GB4128@redhat.com>
	<20120222165714.GC4128@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120222165714.GC4128-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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

Hello,

On Wed, Feb 22, 2012 at 11:57:14AM -0500, Vivek Goyal wrote:
> IIRC, another reason to implement flat hierachy was that some people
> believed that's more natural way of doing things. For example, when
> you talk about cgroup, people ask, ok, give me a cgroup with 25% IO
> bandwidth. Now this does not come naturally with completely nested
> hierarchies where task and groups are treated at the same level. As
> group's peer tasks share the bandwidth, and task come and go a group's
> % share varies dynamically.

I don't see how that is more "natural".  While I don't think
supporting full nesting is necessary for all controllers, the
semantics is very clear - build grouped trees according to active
configurations and distritbute resources top to bottom (network qdiscs
do exactly this).  Flat case is proper degenerate case of nesting.
There's nothing more or less natural.  It's just matter of trade off
between complexity and requirements.

> Again, it does not mean I am advocating flat hiearchy. I am just wondering
> in case of fully nested hierarchies (task at same level as groups), how
> does one explain it to a layman user who understands things in terms of
> % of resources.

I don't know whether we want nesting for block cgroup or not but at
the same time that doesn't really matter.  Sharing hierarchy doesn't
require every controller supporting full hierarchy.  I'm not sure how
the interface should be tho - maybe we can fail specifying config if
there already is an effective config encompassing that node or maybe
we can just break the existing config, I don't know.

Thank you.

-- 
tejun
