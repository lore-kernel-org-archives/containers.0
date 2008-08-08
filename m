From: Hirokazu Takahashi <taka-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Subject: Re: RFC: I/O bandwidth controller
Date: Fri, 08 Aug 2008 23:31:50 +0900 (JST)
Message-ID: <20080808.233150.02266833.taka__18460.6443079703$1218206052$gmane$org@valinux.co.jp>
References: <1217870433.20260.101.camel@nimitz>
	<1217985189.3154.57.camel@sebastian.kern.oss.ntt.co.jp>
	<20080808.152119.43521725.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080808.152119.43521725.taka-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org
Cc: xen-devel-GuqFBffKawuULHF6PoxzQEEOCMrvLtNR@public.gmane.org, uchida-LYU95VJlayp8UrSeD/g0lQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

Hi, Fernando,

> >   - Implement a block layer resource controller. dm-ioband is a working
> > solution and feature rich but its dependency on the dm infrastructure is
> > likely to find opposition (the dm layer does not handle barriers
> > properly and the maximum size of I/O requests can be limited in some
> > cases). In such a case, we could either try to build a standalone
> > resource controller based on dm-ioband (which would probably hook into
> > generic_make_request) or try to come up with something new.
> 
> I doubt about the maximum size of I/O requests problem. You can't avoid
> this problem as far as you use device mapper modules with such a bad
> manner, even if the controller is implemented as a stand-alone controller.
> There is no limitation if you only use dm-ioband without any other device
> mapper modules.

Ryo told me this isn't true anymore. The dm infrastructure introduced
a new feature to support multiple page-sized I/O requests, that was
just merged to the current linux tree. So you and me don't need to
worry about this stuff anymore.

Ryo said he was going to make dm-ioband support this new feature and
post the patches soon.

> And I think the device mapper team just started designing barriers support.
> I guess it won't take long. Right, Alasdair?
> We should know it is logically impossible to support barriers on some
> types of device mapper modules such as LVM. You can't avoid the barrier
> problem when you use this kind of multiple devices even if you implement
> the controller in the block layer.
> 
> But I think a stand-alone implementation will have a merit that it
> makes it easier to setup the configuration rather than dm-ioband.
> From this point of view, it would be good that you move the algorithm
> of dm-ioband into the block layer.
> On the other hand, we should know it will make it impossible to use
> the dm infrastructure from the controller, though it isn't so rich.
> 
> >   - If the I/O tracking patches make it into the kernel we could move on
> > and try to get the Cgroup extensions to CFQ and AS mentioned before (see
> > (1), (2), and (3) above for details) merged.
> >   - Delegate the task of controlling the rate at which a task can
> > generate dirty pages to the memory controller.
> > 
> > This RFC is somewhat vague but my feeling is that we build some
> > consensus on the goals and basic design aspects before delving into
> > implementation details.
> > 
> > I would appreciate your comments and feedback.
> > 
> > - Fernando

Thanks,
Hirokazu Takahashi.
