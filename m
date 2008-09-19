From: Hirokazu Takahashi <taka-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Subject: Re: dm-ioband + bio-cgroup benchmarks
Date: Fri, 19 Sep 2008 15:12:21 +0900 (JST)
Message-ID: <20080919.151221.49666828.taka__7436.15018805048$1221804900$gmane$org@valinux.co.jp>
References: <20080918.210418.226794540.ryov@valinux.co.jp>
	<20080918131554.GB20640@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080918131554.GB20640-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
Cc: xen-devel-GuqFBffKawuULHF6PoxzQEEOCMrvLtNR@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

Hi,

> > Hi All,
> > 
> > I have got excellent results of dm-ioband, that controls the disk I/O
> > bandwidth even when it accepts delayed write requests.
> > 
> > In this time, I ran some benchmarks with a high-end storage. The
> > reason was to avoid a performance bottleneck due to mechanical factors
> > such as seek time.
> > 
> > You can see the details of the benchmarks at:
> > http://people.valinux.co.jp/~ryov/dm-ioband/hps/
> > 
> 
> Hi Ryo,
> 
> I had a query about dm-ioband patches. IIUC, dm-ioband patches will break
> the notion of process priority in CFQ because now dm-ioband device will
> hold the bio and issue these to lower layers later based on which bio's
> become ready. Hence actual bio submitting context might be different and
> because cfq derives the io_context from current task, it will be broken.

This is completely another problem we have to solve.
The CFQ scheduler has really bad assumption that the current process
must be the owner. This problem occurs when you use some of device
mapper devices or use linux aio.

> To mitigate that problem, we probably need to implement Fernando's
> suggestion of putting io_context pointer in bio. 
> 
> Have you already done something to solve this issue?

Actually, I already have a patch to solve this problem, which make
each bio have a pointer to the io_context of the owner process.
Would you take a look at the thread whose subject is "I/O context
inheritance" in:
http://www.uwsg.iu.edu/hypermail/linux/kernel/0804.2/index.html#2850

Fernando also knows this.

Thank you,
Hirokazu Takahashi.
