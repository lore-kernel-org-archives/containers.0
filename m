From: Jeff Moyer <jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC] IO scheduler based io controller (V5)
Date: Mon, 22 Jun 2009 12:06:42 -0400
Message-ID: <x493a9sl0bx.fsf@segfault.boston.devel.redhat.com>
References: <1245443858-8487-1-git-send-email-vgoyal@redhat.com>
	<20090621152116.GC3728@balbir.in.ibm.com>
	<20090622153030.GA15600@redhat.com>
	<x497hz4l1j9.fsf@segfault.boston.devel.redhat.com>
	<20090622160207.GC15600@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090622160207.GC15600-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> (Vivek Goyal's message of
	"Mon, 22 Jun 2009 12:02:07 -0400")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:

> On Mon, Jun 22, 2009 at 11:40:42AM -0400, Jeff Moyer wrote:
>> Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:
>> 
>> > On Sun, Jun 21, 2009 at 08:51:16PM +0530, Balbir Singh wrote:
>> >> * Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> [2009-06-19 16:37:18]:
>> >> 
>> >> > 
>> >> > Hi All,
>> >> > 
>> >> > Here is the V5 of the IO controller patches generated on top of 2.6.30.
>> >> [snip]
>> >> 
>> >> > Testing
>> >> > =======
>> >> >
>> >> 
>> >> [snip]
>> >> 
>> >> I've not been reading through the discussions in complete detail, but
>> >> I see no reference to async reads or aio. In the case of aio, aio
>> >> presumes the context of the user space process. Could you elaborate on
>> >> any testing you've done with these cases? 
>> >> 
>> >
>> > Hi Balbir,
>> >
>> > So far I had not done any testing with AIO. I have done some just now.
>> > Here are the results.
>> >
>> > Test1 (AIO reads)
>> > ================
>> > Set up two fio, AIO read jobs in two cgroup with weight 1000 and 500
>> > respectively. I am using cfq scheduler. Following are some lines from my test
>> > script.
>> >
>> > ===================================================================
>> > fio_args="--ioengine=libaio --rw=read --size=512M"
>> 
>> AIO doesn't make sense without O_DIRECT.
>> 
>
> Ok, here are the read results with --direct=1 for reads. In previous posting,
> writes were already direct.
>
> test1 statistics: time=8 16 20796   sectors=8 16 1049648
> test2 statistics: time=8 16 10551   sectors=8 16 581160
>
>
> Not sure why reads are so slow with --direct=1? In the previous test
> (no direct IO), I had cleared the caches using
> (echo 3 > /proc/sys/vm/drop_caches) so reads could not have come from page
> cache?

O_DIRECT bypasses the page cache, and hence the readahead code.  Try
driving deeper queue depths and/or using larger I/O sizes.

Cheers,
Jeff
