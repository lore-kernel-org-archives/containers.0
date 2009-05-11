From: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Subject: Re: IO scheduler based IO Controller V2
Date: Mon, 11 May 2009 20:23:09 +0900 (JST)
Message-ID: <20090511.202309.112614168.ryov__38364.7343297072$1242041142$gmane$org@valinux.co.jp>
References: <20090506023332.GA1212@redhat.com>
	<20090507.091858.226775723.ryov@valinux.co.jp>
	<20090507012559.GC4187@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090507012559.GC4187-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

Hi Vivek,

From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: IO scheduler based IO Controller V2
Date: Wed, 6 May 2009 21:25:59 -0400

> On Thu, May 07, 2009 at 09:18:58AM +0900, Ryo Tsuruta wrote:
> > Hi Vivek,
> > 
> > > Ryo, dm-ioband breaks the notion of classes and priority of CFQ because
> > > of FIFO dispatch of buffered bios. Apart from that it tries to provide
> > > fairness in terms of actual IO done and that would mean a seeky workload
> > > will can use disk for much longer to get equivalent IO done and slow down
> > > other applications. Implementing IO controller at IO scheduler level gives
> > > us tigher control. Will it not meet your requirements? If you got specific
> > > concerns with IO scheduler based contol patches, please highlight these and
> > > we will see how these can be addressed.
> > 
> > I'd like to avoid making complicated existing IO schedulers and other
> > kernel codes and to give a choice to users whether or not to use it.
> > I know that you chose an approach that using compile time options to
> > get the same behavior as old system, but device-mapper drivers can be
> > added, removed and replaced while system is running.
> > 
> 
> Same is possible with IO scheduler based controller. If you don't want
> cgroup stuff, don't create those. By default everything will be in root
> group and you will get the old behavior. 
> 
> If you want io controller stuff, just create the cgroup, assign weight
> and move task there. So what more choices do you want which are missing
> here?

What I mean to say is that device-mapper drivers can be completely
removed from the kernel if not used.

I know that dm-ioband has some issues which can be addressed by your
IO controller, but I'm not sure your controller works well. So I would
like to see some benchmark results of your IO controller.

Thanks,
Ryo Tsuruta
