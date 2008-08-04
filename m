From: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Too many I/O controller patches
Date: Mon, 04 Aug 2008 22:44:26 +0200
Message-ID: <48976A2A.9060600__30039.1318429776$1217882833$gmane$org@gmail.com>
References: <20080804.175126.193692178.ryov@valinux.co.jp>	
	<1217870433.20260.101.camel@nimitz> <489748E6.5080106@gmail.com>
	<1217876521.20260.123.camel@nimitz>
Reply-To: righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1217876521.20260.123.camel@nimitz>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: xen-devel-GuqFBffKawuULHF6PoxzQEEOCMrvLtNR@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org
List-Id: containers.vger.kernel.org

Dave Hansen wrote:
> On Mon, 2008-08-04 at 20:22 +0200, Andrea Righi wrote:
>> But I'm not yet convinced that limiting the IO writes at the device
>> mapper layer is the best solution. IMHO it would be better to throttle
>> applications' writes when they're dirtying pages in the page cache (the
>> io-throttle way), because when the IO requests arrive to the device
>> mapper it's too late (we would only have a lot of dirty pages that are
>> waiting to be flushed to the limited block devices, and maybe this could
>> lead to OOM conditions). IOW dm-ioband is doing this at the wrong level
>> (at least for my requirements). Ryo, correct me if I'm wrong or if I've
>> not understood the dm-ioband approach.
> 
> The avoid-lots-of-page-dirtying problem sounds like a hard one.  But, if
> you look at this in combination with the memory controller, they would
> make a great team.
> 
> The memory controller keeps you from dirtying more than your limit of
> pages (and pinning too much memory) even if the dm layer is doing the
> throttling and itself can't throttle the memory usage.

mmh... but in this way we would just move the OOM inside the cgroup,
that is a nice improvement, but the main problem is not resolved...

A safer approach IMHO is to force the tasks to wait synchronously on
each operation that directly or indirectly generates i/o.

In particular the solution used by the io-throttle controller to limit
the dirty-ratio in memory is to impose a sleep via
schedule_timeout_killable() in balance_dirty_pages() when a generic
process exceeds the limits defined for the belonging cgroup.

Limiting read operations is a lot more easy, because they're always
synchronized with i/o requests.

-Andrea
