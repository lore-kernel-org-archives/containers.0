From: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Subject: Re: IO scheduler based IO controller V10
Date: Mon, 05 Oct 2009 23:55:35 +0900 (JST)
Message-ID: <20091005.235535.193690928.ryov__46323.6635587693$1254754629$gmane$org@valinux.co.jp>
References: <4AC6623F.70600@ds.jp.nec.com>
	<20091005.193808.104033719.ryov@valinux.co.jp>
	<20091005123148.GB22143@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091005123148.GB22143-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, jmarchan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

Hi Vivek,

Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> On Mon, Oct 05, 2009 at 07:38:08PM +0900, Ryo Tsuruta wrote:
> > Hi,
> > 
> > Munehiro Ikeda <m-ikeda-MDRzhb/z0dd8UrSeD/g0lQ@public.gmane.org> wrote:
> > > Vivek Goyal wrote, on 10/01/2009 10:57 PM:
> > > > Before finishing this mail, will throw a whacky idea in the ring. I was
> > > > going through the request based dm-multipath paper. Will it make sense
> > > > to implement request based dm-ioband? So basically we implement all the
> > > > group scheduling in CFQ and let dm-ioband implement a request function
> > > > to take the request and break it back into bios. This way we can keep
> > > > all the group control at one place and also meet most of the requirements.
> > > >
> > > > So request based dm-ioband will have a request in hand once that request
> > > > has passed group control and prio control. Because dm-ioband is a device
> > > > mapper target, one can put it on higher level devices (practically taking
> > > > CFQ at higher level device), and provide fairness there. One can also
> > > > put it on those SSDs which don't use IO scheduler (this is kind of forcing
> > > > them to use the IO scheduler.)
> > > >
> > > > I am sure that will be many issues but one big issue I could think of that
> > > > CFQ thinks that there is one device beneath it and dipsatches requests
> > > > from one queue (in case of idling) and that would kill parallelism at
> > > > higher layer and throughput will suffer on many of the dm/md configurations.
> > > >
> > > > Thanks
> > > > Vivek
> > > 
> > > As long as using CFQ, your idea is reasonable for me.  But how about for
> > > other IO schedulers?  In my understanding, one of the keys to guarantee
> > > group isolation in your patch is to have per-group IO scheduler internal
> > > queue even with as, deadline, and noop scheduler.  I think this is
> > > great idea, and to implement generic code for all IO schedulers was
> > > concluded when we had so many IO scheduler specific proposals.
> > > If we will still need per-group IO scheduler internal queues with
> > > request-based dm-ioband, we have to modify elevator layer.  It seems
> > > out of scope of dm.
> > > I might miss something...
> > 
> > IIUC, the request based device-mapper could not break back a request
> > into bio, so it could not work with block devices which don't use the
> > IO scheduler.
> > 
> 
> I think current request based multipath drvier does not do it but can't it
> be implemented that requests are broken back into bio?

I guess it would be hard to implement it, and we need to hold requests
and throttle them at there and it would break the ordering by CFQ.

> Anyway, I don't feel too strongly about this approach as it might
> introduce more serialization at higher layer.

Yes, I know it.

> > How about adding a callback function to the higher level controller?
> > CFQ calls it when the active queue runs out of time, then the higer
> > level controller use it as a trigger or a hint to move IO group, so
> > I think a time-based controller could be implemented at higher level.
> > 
> 
> Adding a call back should not be a big issue. But that means you are
> planning to run only one group at higher layer at one time and I think
> that's the problem because than we are introducing serialization at higher
> layer. So any higher level device mapper target which has multiple
> physical disks under it, we might be underutilizing these even more and
> take a big hit on overall throughput.
> 
> The whole design of doing proportional weight at lower layer is optimial 
> usage of system.

But I think that the higher level approch makes easy to configure
against striped software raid devices. If one would like to
combine some physical disks into one logical device like a dm-linear,
I think one should map the IO controller on each physical device and
combine them into one logical device.

> > My requirements for IO controller are:
> > - Implement s a higher level controller, which is located at block
> >   layer and bio is grabbed in generic_make_request().
> 
> How are you planning to handle the issue of buffered writes Andrew raised?

I think that it would be better to use the higher-level controller
along with the memory controller and have limits memory usage for each
cgroup. And as Kamezawa-san said, having limits of dirty pages would
be better, too.

> > - Can work with any type of IO scheduler.
> > - Can work with any type of block devices.
> > - Support multiple policies, proportional wegiht, max rate, time
> >   based, ans so on.
> > 
> > The IO controller mini-summit will be held in next week, and I'm
> > looking forard to meet you all and discuss about IO controller.
> > https://sourceforge.net/apps/trac/ioband/wiki/iosummit
> 
> Is there a new version of dm-ioband now where you have solved the issue of
> sync/async dispatch with-in group? Before meeting at mini-summit, I am
> trying to run some tests and come up with numbers so that we have more
> clear picture of pros/cons.

Yes, I've released new versions of dm-ioband and blkio-cgroup. The new
dm-ioband handles sync/async IO requests separately and
the write-starve-read issue you pointed out is fixed. I would
appreciate it if you would try them.
http://sourceforge.net/projects/ioband/files/ 

Thanks,
Ryo Tsuruta
