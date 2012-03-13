From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFD] cgroup: about multiple hierarchies
Date: Tue, 13 Mar 2012 10:03:45 -0400
Message-ID: <20120313140345.GC29169@redhat.com>
References: <20120221211938.GE12236@google.com>
	<20120312221050.GG23255@google.com>
	<1331590938.18960.57.camel@twins>
	<20120312222817.GI23255@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120312222817.GI23255-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
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
Cc: Michal Schmidt <mschmidt-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Lennart Poettering <lennart-mdGvqq1h2p+GdvJs77BJ7Q@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, Mar 12, 2012 at 03:28:17PM -0700, Tejun Heo wrote:
> Hey,
> 
> On Mon, Mar 12, 2012 at 11:22:18PM +0100, Peter Zijlstra wrote:
> > On Mon, 2012-03-12 at 15:10 -0700, Tejun Heo wrote:
> > > 
> > > * How to map controllers which aren't aware of full hierarchy is still
> > >   an open question but I'm still standing by one active node on any
> > >   root-to-leaf path w/ root group serving as the special rest group. 
> > 
> > What does this mean?
> 
> Let's say we have a tree like the following.
> 
>          root
>       /   |   \
>      G1  G2   G3
>              /  \
> 	   G31  G32
> 
> So, for cgroups which don't support full hierarchy, it'll be viewed as
> either,
> 
>          root
>       /   |   \
>      G1  G2   G3
> 
> or
> 
>           root
>       /   |   |  \
>      G1  G2  G31 G32
> 
> With root being treated specially, probably as just being a equal
> group as other groups, I'm not fully determined about that yet.

So what wrong with flattening the whole hierarchy and all groups being active
in the path? It is not worse then second option?

             root
       /   |  |  |  \
      G1  G2  G3 G31 G32

One problem with above is that a children can create its own child cgroups
and compete at highest level for resources.

But same is the problem with second choice you gave. May be you are
thinking of introducing another knob to configure active point in the
path? I guess that will make cgroup configuration even harder.

May be we flatten the whole hierarchy. When we launch user sessions, we
don't give then permissions to create child cgroups for IO. For services
running with admin priviliges, we still don't have a good solution for
flat controllers. If nobody has a use case, I guess we just live with
that as that's the limitation of flat controller and one needs to make
it hierarchical, if need be.

Thanks
Vivek
