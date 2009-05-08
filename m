From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] io-controller: Add io group reference handling for request
Date: Fri, 8 May 2009 14:56:44 -0400
Message-ID: <20090508185644.GH7293__20443.8622728505$1241809302$gmane$org@redhat.com>
References: <1241553525-28095-1-git-send-email-vgoyal@redhat.com>
	<4A03FF3C.4020506@cn.fujitsu.com>
	<20090508135724.GE7293@redhat.com>
	<e98e18940905081041r386e52a5q5a2b1f13f1e8c634@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <e98e18940905081041r386e52a5q5a2b1f13f1e8c634-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nauman Rafique <nauman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, May 08, 2009 at 10:41:01AM -0700, Nauman Rafique wrote:
> On Fri, May 8, 2009 at 6:57 AM, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> > On Fri, May 08, 2009 at 05:45:32PM +0800, Gui Jianfeng wrote:
> >> Hi Vivek,
> >>
> >> This patch adds io group reference handling when allocating
> >> and removing a request.
> >>
> >
> > Hi Gui,
> >
> > Thanks for the patch. We were thinking that requests can take a reference
> > on io queues and io queues can take a reference on io groups. That should
> > make sure that io groups don't go away as long as active requests are
> > present.
> >
> > But there seems to be a small window while allocating the new request
> > where request gets allocated from a group first and then later it is
> > mapped to that group and queue is created. IOW, in get_request_wait(),
> > we allocate a request from a particular group and set rq->rl, then
> > drop the queue lock and later call elv_set_request() which again maps
> > the request to the group saves rq->iog and creates new queue. This window
> > is troublesome because request can be mapped to a particular group at the
> > time of allocation and during set_request() it can go to a different
> > group as queue lock was dropped and group might have disappeared.
> >
> > In this case probably it might make sense that request also takes a
> > reference on groups. At the same time it looks too much that request takes
> > a reference on queue as well as group object. Ideas are welcome on how
> > to handle it...
> 
> IMHO a request being allocated on the wrong cgroup should not be a big
> problem as such. All it means is that the request descriptor was
> accounted to the wrong cgroup in this particular corner case. Please
> correct me if I am wrong.

I think you are right. We just need to be little careful while freeing
the request that associated request list might have gone away (rq->rl).

Or we probably can think of getting rid of (rq->rl) also and while
freeing request determine io queue and group from rq->ioq. But somehow
I remember that I had to introduce rq->rl otherwise I was running into
issues of request being mapped to different groups at different point
of time hence different request list etc. Will check again..
> 
> We can also get rid of rq->iog pointer too. What that means is that
> request is associated with ioq (rq->ioq), and we can use
> ioq_to_io_group() function to get the io_group. So the request would
> only be indirectly associated with an io_group i.e. the request is
> associated with an io_queue and the io_group for the request is the
> io_group associated with io_queue. Do you see any problems with that
> approach?

Looks like this is also doable. Good idea. Can't think of why can't
we get rid of rq->iog and manage with rq->ioq. There are only 1-2
places where ioq is not setup yet and rq has been mapped to the group.
There we shall have to carry group information or carry bio information
and map it again to get group info.

Will try to implement it and see how does it go.

Thanks
Vivek
