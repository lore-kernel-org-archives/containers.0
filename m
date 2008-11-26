From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [patch 0/4] [RFC] Another proportional weight IO controller
Date: Wed, 26 Nov 2008 11:08:05 -0500
Message-ID: <20081126160805.GE27826__27434.4969461255$1227716109$gmane$org@redhat.com>
References: <20081120134701.GB29306@redhat.com>
	<20081125.113359.623571555980951312.ryov@valinux.co.jp>
	<20081125162720.GH341@redhat.com>
	<20081126.214707.653026525707335397.ryov@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20081126.214707.653026525707335397.ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Cc: menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, Nov 26, 2008 at 09:47:07PM +0900, Ryo Tsuruta wrote:
> Hi Vivek,
> 
> From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> Subject: Re: [patch 0/4] [RFC] Another proportional weight IO controller
> Date: Tue, 25 Nov 2008 11:27:20 -0500
> 
> > On Tue, Nov 25, 2008 at 11:33:59AM +0900, Ryo Tsuruta wrote:
> > > Hi Vivek,
> > > 
> > > > > > Ryo, do you still want to stick to two level scheduling? Given the problem
> > > > > > of it breaking down underlying scheduler's assumptions, probably it makes
> > > > > > more sense to the IO control at each individual IO scheduler.
> > > > > 
> > > > > I don't want to stick to it. I'm considering implementing dm-ioband's
> > > > > algorithm into the block I/O layer experimentally.
> > > > 
> > > > Thanks Ryo. Implementing a control at block layer sounds like another
> > > > 2 level scheduling. We will still have the issue of breaking underlying
> > > > CFQ and other schedulers. How to plan to resolve that conflict.
> > > 
> > > I think there is no conflict against I/O schedulers.
> > > Could you expain to me about the conflict?
> > 
> > Because we do the buffering at higher level scheduler and mostly release
> > the buffered bios in the FIFO order, it might break the underlying IO
> > schedulers. Generally it is the decision of IO scheduler to determine in
> > what order to release buffered bios.
> > 
> > For example, If there is one task of io priority 0 in a cgroup and rest of
> > the tasks are of io prio 7. All the tasks belong to best effort class. If
> > tasks of lower priority (7) do lot of IO, then due to buffering there is
> > a chance that IO from lower prio tasks is seen by CFQ first and io from
> > higher prio task is not seen by cfq for quite some time hence that task
> > not getting it fair share with in the cgroup. Similiar situations can
> > arise with RT tasks also.
> 
> Thanks for your explanation. 
> I think that the same thing occurs without the higher level scheduler,
> because all the tasks issuing I/Os are blocked while the underlying
> device's request queue is full before those I/Os are sent to the I/O
> scheduler.
> 

True and this issue was pointed out by Divyesh. I think we shall have to
fix this by allocating the request descriptors in proportion to their
share. One possible way is to make use of elv_may_queue() to determine
if we can allocate furhter request descriptors or not. 

> > > > What do you think about the solution at IO scheduler level (like BFQ) or
> > > > may be little above that where one can try some code sharing among IO
> > > > schedulers? 
> > > 
> > > I would like to support any type of block device even if I/Os issued
> > > to the underlying device doesn't go through IO scheduler. Dm-ioband
> > > can be made use of for the devices such as loop device.
> > > 
> > 
> > What do you mean by that IO issued to underlying device does not go
> > through IO scheduler? loop device will be associated with a file and
> > IO will ultimately go to the IO scheduler which is serving those file
> > blocks?
> 
> How about if the files is on an NFS-mounted file system?
> 

Interesting. So on the surface it looks like contention for disk but it
is more the contention for network and contention for disk on NFS server.

True that leaf node IO control will not help here as IO is not going to
leaf node at all. We can make the situation better by doing resource 
control on network IO though.

> > What's the use case scenario of doing IO control at loop device?
> > Ultimately the resource contention will take place on actual underlying
> > physical device where the file blocks are. Will doing the resource control
> > there not solve the issue for you?
> 
> I don't come up with any use case, but I would like to make the
> resource controller more flexible. Actually, a certain block device
> that I'm using does not use the I/O scheduler.

Isn't it equivalent to using No-op? If yes, then it should not be an
issue?

Thanks
Vivek
