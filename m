From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [patch 0/4] [RFC] Another proportional weight IO controller
Date: Thu, 20 Nov 2008 16:31:55 -0500
Message-ID: <20081120213155.GI29306__19507.5169824579$1227216888$gmane$org@redhat.com>
References: <20081113214642.GG7542@redhat.com>
	<af41c7c40811131457w472e4a86tb5344cc1d3d366fb@mail.gmail.com>
	<20081114160525.GE24624@redhat.com>
	<e98e18940811141444u5947b806v27fac453ed1e8a5@mail.gmail.com>
	<20081117142309.GA15564@redhat.com>
	<4922224A.5030502@cn.fujitsu.com>
	<e98e18940811172101na345b6bh5c73f9e657aac5a7@mail.gmail.com>
	<20081118120508.GD15268@gandalf.sssup.it>
	<20081118140751.GA4283@redhat.com>
	<20081118144139.GE15268@gandalf.sssup.it>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20081118144139.GE15268-f9ZlEuEWxVeACYmtYXMKmw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Fabio Checconi <fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Divyesh Shah <dpshah-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Nov 18, 2008 at 03:41:39PM +0100, Fabio Checconi wrote:
> > From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> > Date: Tue, Nov 18, 2008 09:07:51AM -0500
> >
> > On Tue, Nov 18, 2008 at 01:05:08PM +0100, Fabio Checconi wrote:
> ...
> > > I have to think a little bit on how it would be possible to support
> > > an option for time-only budgets, coexisting with the current behavior,
> > > but I think it can be done.
> > > 
> > 
> > IIUC, bfq and cfq are different in following manner.
> > 
> > a. BFQ employs WF2Q+ for fairness and CFQ employes weighted round robin.
> > b. BFQ uses the budget (sector count) as notion of service and CFQ uses
> >    time slices.
> > c. BFQ supports hierarchical fair queuing and CFQ does not.  
> > 
> > We are looking forward for implementation of point C. Fabio seems to
> > thinking of supporting time slice as a service (B). It seems like
> > convergence of CFQ and BFQ except the point A (WF2Q+ vs weighted round
> > robin). 
> > 
> > It looks like WF2Q+ provides tighter service bound and bfq guys mention
> > that they have been able to ensure throughput while ensuring tighter 
> > bounds. If that's the case, does that mean BFQ is a replacement for CFQ
> > down the line?
> >   
> 
> BFQ started from CFQ, extending it in the way you correctly describe,
> so it is indeed very similar.  There are also some minor changes to
> locking, cic handling, hw_tag detection and to the CIC_SEEKY heuristic.
> 
> The two schedulers share similar goals, and in my opinion BFQ can be
> considered, in the long term, a CFQ replacement; *but* before talking
> about replacing CFQ we have to consider that:
> 
>   - it *needs* review and testing; we've done our best, but for sure
>     it's not enough; review and testing are never enough;
>   - the service domain fairness, which was one of our objectives, requires
>     some extra complexity; the mechanisms we used and the design choices
>     we've made may not fit all the needs, or may not be as generic as the
>     simpler CFQ's ones;
>   - CFQ has years of history behind and has been tuned for a wider
>     variety of environments than the ones we've been able to test.
> 
> If time-based fairness is considered more robust and the loss of
> service-domain fairness is not a problem, then the two schedulers can
> be made even more similar.

Hi Fabio,

I though will give bfq a try.  I get following when I put my current shell
into a newly created cgroup and then try to do "ls".

Thanks
Vivek


[ 1246.498412] BUG: unable to handle kernel NULL pointer dereference at 000000bc
[ 1246.498674] IP: [<c034210b>] __bfq_cic_change_cgroup+0x148/0x239
[ 1246.498674] *pde = 00000000 
[ 1246.498674] Oops: 0002 [#1] SMP 
[ 1246.498674] last sysfs file: /sys/devices/pci0000:00/0000:00:01.1/host0/target0:0:1/0:0:1:0/block/sdb/queue/scheduler
[ 1246.498674] Modules linked in:
[ 1246.498674] 
[ 1246.498674] Pid: 2352, comm: dd Not tainted (2.6.28-rc4-bfq #2) 
[ 1246.498674] EIP: 0060:[<c034210b>] EFLAGS: 00200046 CPU: 0
[ 1246.498674] EIP is at __bfq_cic_change_cgroup+0x148/0x239
[ 1246.498674] EAX: df0e50ac EBX: df0e5000 ECX: 00200046 EDX: df32f300
[ 1246.498674] ESI: dece6ee0 EDI: df0e5000 EBP: df37fc14 ESP: df37fbdc
[ 1246.498674]  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
[ 1246.498674] Process dd (pid: 2352, ti=df37e000 task=dfb01e00 task.ti=df37e000)
[ 1246.498674] Stack:
[ 1246.498674]  decc9780 dfa98948 df32f300 00000000 00000000 00200046 dece6ef0 00000000
[ 1246.498674]  df0e5000 00000000 df0f8014 df32f300 dfa98948 dec0c548 df37fc54 c034351b
[ 1246.498674]  00000010 dfabe6c0 dec0c548 00080000 df32f300 00000001 00200246 dfa98988
[ 1246.498674] Call Trace:
[ 1246.498674]  [<c034351b>] ? bfq_set_request+0x1f5/0x291
[ 1246.498674]  [<c0343326>] ? bfq_set_request+0x0/0x291
[ 1246.498674]  [<c0333ffe>] ? elv_set_request+0x17/0x26
[ 1246.498674]  [<c03365ad>] ? get_request+0x15e/0x1e7
[ 1246.498674]  [<c0336af5>] ? get_request_wait+0x22/0xd8
[ 1246.498674]  [<c04943b9>] ? dm_merge_bvec+0x88/0xb5
[ 1246.498674]  [<c0336f31>] ? __make_request+0x25e/0x310
[ 1246.498674]  [<c0494c02>] ? dm_request+0x137/0x150
[ 1246.498674]  [<c0335ecf>] ? generic_make_request+0x1e9/0x21f
[ 1246.498674]  [<c033708b>] ? submit_bio+0xa8/0xb1
[ 1246.498674]  [<c0264e49>] ? get_page+0x8/0xe
[ 1246.498674]  [<c0265157>] ? __lru_cache_add+0x27/0x43
[ 1246.498674]  [<c029fea2>] ? mpage_end_io_read+0x0/0x70
[ 1246.498674]  [<c029f453>] ? mpage_bio_submit+0x1c/0x21
[ 1246.498674]  [<c029ffc3>] ? mpage_readpages+0xb1/0xbe
[ 1246.498674]  [<c02c04d6>] ? ext3_readpages+0x0/0x16
[ 1246.498674]  [<c02c04ea>] ? ext3_readpages+0x14/0x16
[ 1246.498674]  [<c02c0f4a>] ? ext3_get_block+0x0/0xd4
[ 1246.498674]  [<c02649ee>] ? __do_page_cache_readahead+0xde/0x15b
[ 1246.498674]  [<c0264cab>] ? ondemand_readahead+0xf9/0x107
[ 1246.498674]  [<c0264d1e>] ? page_cache_sync_readahead+0x16/0x1c
[ 1246.498674]  [<c02600b2>] ? generic_file_aio_read+0x1ad/0x463
[ 1246.498674]  [<c02811cb>] ? do_sync_read+0xab/0xe9
[ 1246.498674]  [<c0235fe4>] ? autoremove_wake_function+0x0/0x33
[ 1246.498674]  [<c0268f15>] ? __inc_zone_page_state+0x12/0x15
[ 1246.498674]  [<c026c1a9>] ? handle_mm_fault+0x5a0/0x5b5
[ 1246.498674]  [<c0314bcc>] ? security_file_permission+0xf/0x11
[ 1246.498674]  [<c0281949>] ? vfs_read+0x80/0xda
[ 1246.498674]  [<c0281120>] ? do_sync_read+0x0/0xe9
[ 1246.498674]  [<c0281bab>] ? sys_read+0x3b/0x5d
[ 1246.498674]  [<c0203a3d>] ? sysenter_do_call+0x12/0x21
[ 1246.498674] Code: 55 e4 8b 55 d0 89 f0 e8 72 ea ff ff 85 c0 74 04 0f 0b eb fe 8d 46 10 89 45 e0 e8 57 a5 28 00 89 45 dc 8b 55 d0 8d 83 ac 00 00 00 <89> 15 bc 00 00 00 8d 56 14 e8 18 e9 ff ff 8b 75 d0 8d 93 b4 00 
[ 1246.498674] EIP: [<c034210b>] __bfq_cic_change_cgroup+0x148/0x239 SS:ESP 0068:df37fbdc
[ 1246.498674] ---[ end trace 6bd1df99b7a9cb00 ]---
