From: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Subject: Re: [RFD] cgroup: about multiple hierarchies
Date: Mon, 12 Mar 2012 23:32:48 +0100
Message-ID: <1331591568.18960.61.camel@twins>
References: <20120221211938.GE12236@google.com>
	<20120312221050.GG23255@google.com> <1331590938.18960.57.camel@twins>
	<20120312222817.GI23255@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
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
Cc: Michal Schmidt <mschmidt-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Lennart Poettering <lennart-mdGvqq1h2p+GdvJs77BJ7Q@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, 2012-03-12 at 15:28 -0700, Tejun Heo wrote:
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

I'm assuming that G31/G32's tasks end up in G3 in the first case, but
where do the tasks in G3 go to in the second case?

Also, why allow non-hierarchical controllers to begin with? I would very
much argue for mandating that all controllers work the same wrt
hierarchy and if that means ditching hierarchy support we should do that
and modify cgroupfs to not allow creation of directories deeper than 1.

But allowing controllers that implement hierarchy proper and controllers
that do not and then force them in the same mount point, that just
doesn't make any friggin sense what so ever.
