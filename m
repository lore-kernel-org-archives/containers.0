From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC] writeback and cgroup
Date: Thu, 5 Apr 2012 13:09:56 -0400
Message-ID: <20120405170956.GE23999__10674.1530508318$1333645840$gmane$org@redhat.com>
References: <20120403183655.GA23106@dhcp-172-17-108-109.mtv.corp.google.com>
	<20120404175124.GA8931@localhost>
	<20120404193355.GD29686@dhcp-172-17-108-109.mtv.corp.google.com>
	<20120404201816.GL12676@redhat.com>
	<20120405163113.GD12854@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120405163113.GD12854-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
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
Cc: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, andrea-oIIqvOZpAevzfdHfmsDf5w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sjayaraman-IBi9RG/b67k@public.gmane.org, lsf-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Fengguang Wu <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Apr 05, 2012 at 09:31:13AM -0700, Tejun Heo wrote:
> Hey, Vivek.
> 
> On Wed, Apr 04, 2012 at 04:18:16PM -0400, Vivek Goyal wrote:
> > Hey how about reconsidering my other proposal for which I had posted
> > the patches. And that is keep throttling still at device level. Reads
> > and direct IO get throttled asynchronously but buffered writes get
> > throttled synchronously.
> > 
> > Advantages of this scheme.
> > 
> > - There are no separate knobs.
> > 
> > - All the IO (read, direct IO and buffered write) is controlled using
> >   same set of knobs and goes in queue of same cgroup.
> > 
> > - Writeback logic has no knowledge of throttling. It just invokes a 
> >   hook into throttling logic of device queue.
> > 
> > I guess this is a hybrid of active writeback throttling and back pressure
> > mechanism.
> > 
> > But it still does not solve the NFS issue as well as for direct IO,
> > filesystems still can get serialized, so metadata issue still needs to 
> > be resolved. So one can argue that why not go for full "back pressure"
> > method, despite it being more complex.
> > 
> > Here is the link, just to refresh the memory. Something to keep in mind
> > while assessing alternatives.
> > 
> > https://lkml.org/lkml/2011/6/28/243
> 
> Hmmm... so, this only works for blk-throttle and not with the weight.
> How do you manage interaction between buffered writes and direct
> writes for the same cgroup?
> 

Yes, it is only for blk-throttle. We just account for buffered write
in balance_dirty_pages() instead of when they are actually submitted to
device by flusher thread.

IIRC, I just had two queues. In one queue I had bios and in another queue
I had  tasks with information how much memory they are dirtying. So I 
did round robin in terms of dispatch between two queues depending on
throttling rate. I will allow dispatch bio from direct IO queue, then 
look at the other queue and see how much IO other task wanted to do and
when sufficient time had passed based on throttling rate, I will remove
that task from my wait queue and wake it up. 

That way it becomes equivalent to that two IO paths (direct IO + buffered
write),  doing IO to single pipe which has throttling limit. Both the
IOs are sujected to same common limit (and no split). Just that we round
robin between two types of IO and try to divide available bandwidth
equally (This ofcourse could be made tunable).

Thanks
Vivek
