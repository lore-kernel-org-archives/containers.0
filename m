From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: IO scheduler based IO Controller V2
Date: Tue, 5 May 2009 22:33:32 -0400
Message-ID: <20090506023332.GA1212__32139.0077275739$1241577376$gmane$org@redhat.com>
References: <1241553525-28095-1-git-send-email-vgoyal@redhat.com>
	<20090505132441.1705bfad.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090505132441.1705bfad.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, May 05, 2009 at 01:24:41PM -0700, Andrew Morton wrote:
> On Tue,  5 May 2009 15:58:27 -0400
> Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> 
> > 
> > Hi All,
> > 
> > Here is the V2 of the IO controller patches generated on top of 2.6.30-rc4.
> > ...
> > Currently primarily two other IO controller proposals are out there.
> > 
> > dm-ioband
> > ---------
> > This patch set is from Ryo Tsuruta from valinux.
> > ...
> > IO-throttling
> > -------------
> > This patch set is from Andrea Righi provides max bandwidth controller.
> 
> I'm thinking we need to lock you guys in a room and come back in 15 minutes.
> 
> Seriously, how are we to resolve this?  We could lock me in a room and
> cmoe back in 15 days, but there's no reason to believe that I'd emerge
> with the best answer.
> 
> I tend to think that a cgroup-based controller is the way to go. 
> Anything else will need to be wired up to cgroups _anyway_, and that
> might end up messy.

Hi Andrew,

Sorry, did not get what do you mean by cgroup based controller? If you
mean that we use cgroups for grouping tasks for controlling IO, then both
IO scheduler based controller as well as io throttling proposal do that.
dm-ioband also supports that up to some extent but it requires extra step of
transferring cgroup grouping information to dm-ioband device using dm-tools.

But if you meant that io-throttle patches, then I think it solves only
part of the problem and that is max bw control. It does not offer minimum
BW/minimum disk share gurantees as offered by proportional BW control.

IOW, it supports upper limit control and does not support a work conserving
IO controller which lets a group use the whole BW if competing groups are
not present. IMHO, proportional BW control is an important feature which
we will need and IIUC, io-throttle patches can't be easily extended to support
proportional BW control, OTOH, one should be able to extend IO scheduler
based proportional weight controller to also support max bw control. 

Andrea, last time you were planning to have a look at my patches and see
if max bw controller can be implemented there. I got a feeling that it
should not be too difficult to implement it there. We already have the
hierarchical tree of io queues and groups in elevator layer and we run
BFQ (WF2Q+) algorithm to select next queue to dispatch the IO from. It is
just a matter of also keeping track of IO rate per queue/group and we should
be easily be able to delay the dispatch of IO from a queue if its group has
crossed the specified max bw.

This should lead to less code and reduced complextiy (compared with the
case where we do max bw control with io-throttling patches and proportional
BW control using IO scheduler based control patches).
 
So do you think that it would make sense to do max BW control along with
proportional weight IO controller at IO scheduler? If yes, then we can
work together and continue to develop this patchset to also support max
bw control and meet your requirements and drop the io-throttling patches.

The only thing which concerns me is the fact that IO scheduler does not
have the view of higher level logical device. So if somebody has setup a
software RAID and wants to put max BW limit on software raid device, this
solution will not work. One shall have to live with max bw limits on 
individual disks (where io scheduler is actually running). Do your patches
allow to put limit on software RAID devices also? 

Ryo, dm-ioband breaks the notion of classes and priority of CFQ because
of FIFO dispatch of buffered bios. Apart from that it tries to provide
fairness in terms of actual IO done and that would mean a seeky workload
will can use disk for much longer to get equivalent IO done and slow down
other applications. Implementing IO controller at IO scheduler level gives
us tigher control. Will it not meet your requirements? If you got specific
concerns with IO scheduler based contol patches, please highlight these and
we will see how these can be addressed.

Thanks
Vivek
