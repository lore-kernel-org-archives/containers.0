From: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Subject: Re: [PATCH 2/2] dm-ioband: I/O bandwidth controller v0.0.4: Document
Date: Mon, 28 Apr 2008 17:06:27 +0900 (JST)
Message-ID: <20080428.170627.59682428.ryov__29749.8150649064$1209370203$gmane$org@valinux.co.jp>
References: <20080424.201857.183035295.ryov@valinux.co.jp>
	<20080424.202219.59667073.ryov@valinux.co.jp>
	<20080426114535.e19283be.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080426114535.e19283be.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
Cc: xen-devel-GuqFBffKawuULHF6PoxzQEEOCMrvLtNR@public.gmane.org, sergk-4fxBgsLEJ9cH6wp9xFTt+g@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org
List-Id: containers.vger.kernel.org

Hi,

> Most writes are performed by pdflush, kswapd, etc.  This will lead to large
> inaccuracy.
>
> It isn't trivial to fix.  We'd need deep, long tracking of ownership
> probably all the way up to the pagecache page.  The same infrastructure
> would be needed to make Sergey's "BSD acct: disk I/O accounting" vaguely
> accurate.  Other proposals need it, but I forget what they are.

I also realize that some kernel threads such as pdflush perform actual
writes instead of tasks which originally issued write requests.
So, taka is developing a blocking I/O tacking down mechanism which is
based on cgroup memory controller and posted it to LKML:
http://lwn.net/Articles/273802/

However, the current implementation works well with Xen virtual
machines, because virtual machine's I/Os are issued from its own kernel
thread and can be tracked down. Please see a benchmark result of Xen
virtual machine:
http://people.valinux.co.jp/~ryov/dm-ioband/benchmark/xen-blktap.html

As for KVM, dm-ioband was also able to track down block I/Os as I
expected. When dm-ioband is used in virtual machine environment,
I think even the current implementation will work fairly.

But unfortunately I found KVM still had a performance problem that
it couldn't handle I/Os efficiently yet, which should be improved.
I already posted this problem to kvm-devel list:
http://sourceforge.net/mailarchive/forum.php?thread_name=20080229.210531.226799765.ryov%40valinux.co.jp&forum_name=kvm-devel
 
> Much more minor points: when merge-time comes, the patches should have the
> LINUX_VERSION_CODE stuff removed.  And probably all of the many `inline's
> should be removed.

Thank you for your advice. I'll have these fixes included in the next
release.

Ryo Tsuruta
