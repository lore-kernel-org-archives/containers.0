From: Hirokazu Takahashi <taka-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Subject: Re: RFC: I/O bandwidth controller
Date: Fri, 08 Aug 2008 20:39:44 +0900 (JST)
Message-ID: <20080808.203944.29203232.taka__4428.27705196596$1218195764$gmane$org@valinux.co.jp>
References: <1217985189.3154.57.camel@sebastian.kern.oss.ntt.co.jp>
	<4899D464.1070506@linux.vnet.ibm.com>
	<1218078075.3803.149.camel@sebastian.kern.oss.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1218078075.3803.149.camel-xpvPi5bcW5X5OjGIXfuPlhrrLbDL3r4M6qtp775pBPw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org
Cc: xen-devel-GuqFBffKawuULHF6PoxzQEEOCMrvLtNR@public.gmane.org, uchida-LYU95VJlayp8UrSeD/g0lQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

Hi,

> > Would you like to split up IO into read and write IO. We know that read can be
> > very latency sensitive when compared to writes. Should we consider them
> > separately in the RFC?
> Oops, I somehow ended up leaving your first question unanswered. Sorry.
> 
> I do not think we should consider them separately, as long as there is a
> proper IO tracking infrastructure in place. As you mentioned, reads can
> be very latecy sensitive, but the read case could be treated as an
> special case IO controller/IO tracking subsystem. There certainly are
> optimization opportunities. For example, in the synchronous I/O patch ww
> could mark bios with the iocontext of the current task, because it will
> happen to be originator of that IO. By effectively caching the ownership
> information in the bio we can avoid all the accesses to struct page,
> page_cgroup, etc, and reads would definitively benefit from that. 

FYI, we should also take special care of pages being reclaimed, the free
memory of the cgroup these pages belong to may be really low.
Dm-ioband is doing this.

Thanks,
Hirokazu Takahashi.
