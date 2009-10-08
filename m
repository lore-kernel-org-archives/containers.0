From: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Subject: Re: IO scheduler based IO controller V10
Date: Thu, 08 Oct 2009 11:18:41 +0900 (JST)
Message-ID: <20091008.111841.226773827.ryov__24706.4829491594$1254968740$gmane$org@valinux.co.jp>
References: <20091006112201.GA27866@redhat.com>
	<20091007.233805.183040347.ryov@valinux.co.jp>
	<20091007150929.GB3674@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091007150929.GB3674-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
> Ok. Our numbers can vary a bit depending on fio settings like block size
> and underlying storage also. But that's not the important thing. Currently
> with this test I just wanted to point out that model of ioprio with-in group
> is currently broken with dm-ioband and good that you can reproduce that.
> 
> One minor nit, for max latency you need to look at "clat " row and "max=" field
> in fio output. Most of the time "max latency" will matter most. You seem to
> be currently grepping for "maxt" which is just seems to be telling how
> long did test run and in this case 30 seconds.
> 
> Assigning reads to right context in CFQ and not to dm-ioband thread might
> help a bit, but I am bit skeptical and following is the reason.
> 
> CFQ relies on time providing longer time slice length for higher priority
> process and if one does not use time slice, it looses its share. So the moment
> you buffer even single bio of a process in dm-layer, if CFQ was servicing that
> process at same time, that process will loose its share. CFQ will at max
> anticipate for 8 ms and if buffering is longer than 8ms, CFQ will expire the
> queue and move on to next queue. Later if you submit same bio and with
> dm-ioband helper thread and even if CFQ attributes it to right process, it is
> not going to help much as process already lost it slice and now a new slice
> will start.

O.K. I would like to figure something out this issue.

> > > > Be that as it way, I think that if every bio can point the iocontext
> > > > of the process, then it makes it possible to handle IO priority in the
> > > > higher level controller. A patchse has already posted by Takhashi-san.
> > > > What do you think about this idea?
> > > > 
> > > >   Date Tue, 22 Apr 2008 22:51:31 +0900 (JST)
> > > >   Subject [RFC][PATCH 1/10] I/O context inheritance
> > > >   From Hirokazu Takahashi <>
> > > >   http://lkml.org/lkml/2008/4/22/195
> > > 
> > > So far you have been denying that there are issues with ioprio with-in
> > > group in higher level controller. Here you seems to be saying that there are
> > > issues with ioprio and we need to take this patch in to solve the issue? I am
> > > confused?
> > 
> > The true intention of this patch is to preserve the io-context of a
> > process which originate it, but I think that we could also make use of
> > this patch for one of the way to solve this issue.
> > 
> 
> Ok. Did you run the same test with this patch applied and how do numbers look
> like? Can you please forward port it to 2.6.31 and I will also like to
> play with it?

I'm sorry, I have no time to do that this week. I would like to do the
forward porting and test with it by the mini-summit when poissible.

> I am running more tests/numbers with 2.6.31 for all the IO controllers and
> planning to post it to lkml before we meet for IO mini summit. Numbers can
> help us understand the issue better.
> 
> In first phase I am planning to post numbers for IO scheudler controller
> and dm-ioband. Then will get to max bw controller of Andrea Righi.

That sounds good. Thank you for your work.

> > I created those patches against 2.6.32-rc1 and made sure the patches
> > can be cleanly applied to that version.
> 
> I am applying dm-ioband patch first and then bio cgroup patches. Is this
> right order? Will try again.

Yes, the order is right. Here are the sha1sums.
9f4e50878d77922c84a29be9913a8b5c3f66e6ec linux-2.6.32-rc1.tar.bz2
15d7cc9d801805327204296a2454d6c5346dd2ae dm-ioband-1.14.0.patch
5e0626c14a40c319fb79f2f78378d2de5cc97b02 blkio-cgroup-v13.tar.bz2

Thanks,
Ryo Tsuruta
