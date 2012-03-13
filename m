From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFD] cgroup: about multiple hierarchies
Date: Tue, 13 Mar 2012 10:10:32 -0400
Message-ID: <20120313141032.GD29169@redhat.com>
References: <20120221211938.GE12236@google.com>
	<20120312221050.GG23255@google.com>
	<1331590938.18960.57.camel@twins>
	<20120312222817.GI23255@google.com>
	<1331591568.18960.61.camel@twins>
	<20120312223944.GJ23255@google.com>
	<1331592241.18960.64.camel@twins>
	<20120312230416.GM23255@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120312230416.GM23255-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
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

On Mon, Mar 12, 2012 at 04:04:16PM -0700, Tejun Heo wrote:
> On Mon, Mar 12, 2012 at 11:44:01PM +0100, Peter Zijlstra wrote:
> > On Mon, 2012-03-12 at 15:39 -0700, Tejun Heo wrote:
> > > If we can get to the point where nesting is fully
> > > supported by every controller first, that would be awesome too. 
> > 
> > As long as that is the goal.. otherwise, I'd be overjoyed if I can rip
> > nesting support out of the cpu-controller.. that stuff is such a pain.
> > Then again, I don't think the container people like this proposal --
> > they were the ones pushing for full hierarchy back when.
> 
> Yeah, the great pain of full hierarchy support is one of the reasons
> why I keep thinking about supporting mapping to flat hierarchy.  Full
> hierarchy could be too painful and not useful enough for some
> controllers.  Then again, cpu and memcg already have it and according
> to Vivek blkcg also had a proposed implementation, so maybe it's okay.
> Let's see.

Implementing hierarchy is a pain and is expensive at run time. Supporting
flat structure will provide path for smooth transition.

We had some RFC patches for blkcg hierarchy and that made things even more
complicated and we might not gain much. So why to complicate the code
until and unless we have a good use case.

Thanks
Vivek
