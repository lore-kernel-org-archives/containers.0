From: "Satoshi UCHIDA" <s-uchida-LYU95VJlayp8UrSeD/g0lQ@public.gmane.org>
Subject: RE: [RFC][v2][patch 0/12][CFQ-cgroup]Yet another I/O bandwidth
	controlling subsystem for CGroups based on CFQ
Date: Fri, 9 May 2008 19:17:44 +0900
Message-ID: <004901c8b1bd$ec22fb70$c468f250$__45104.4918773279$1210328510$gmane$org@jp.nec.com>
References: <008001c893db$4e2eccf0$ea8c66d0$@jp.nec.com>	<6599ad830804021541s3c1e3197y77d87f63bf47e4b3@mail.gmail.com>	<005d01c89559$9e538200$dafa8600$@jp.nec.com>
	<20080425.185444.115924172.ryov@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080425.185444.115924172.ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Content-Language: ja
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: 'Ryo Tsuruta' <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, vtaras-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
Cc: axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, tom-sugawara-LYU95VJlayp8UrSeD/g0lQ@public.gmane.org
List-Id: containers.vger.kernel.org

Hi, Ryo-San.
Thank you for your test results.

In the test #2 and #3, did you use direct write?
I guess you have used the non-direct write I/O (using cache).

CFQ I/O scheduler was extended in my and Vasily's controllers so that both controllers inherit the features of CFQ.

The current CFQ I/O scheduler cannot control non-direct write I/Os.
This main cause is a cache system.
Bio data is created by special daemon process, such as pdflush or kswapd, for the write I/O using cache.
Therefore, many non-direct write I/Os will belong to one of cgroup (perhaps, root of cgroup).

We consider that this problem should be resolved by fixing cache system.
Specifically, I/Os created by collection of cache pages belong to I/O-context for task which wrote data to cache.
This resolution has a problem.
 * Who is the owner of cache page?
     Cache is reused by many tasks.
     Therefore, it is difficult to decide owner.

In the test #3, It seems that system could control I/Os only among read (sdc2 and sdc3).
Therefore, your test shows that our controller can control I/O without above problem.


Meanwhile, I'm very interested in the result of your test #2.
In the non-direct write I/O, performance will be influenced to task scheduling and sequence of output pages.
Therefore, non-direct write I/O will be fair in the current default task scheduler.
However, your result shows almost fair in Vasilly's controller, whereas non fair in ours. 
I'm just wondering if this is an accidental result or an usual result.


Thanks,
   Satoshi UCHIDA.


> -----Original Message-----
> From: Ryo Tsuruta [mailto:ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org]
> Sent: Friday, April 25, 2008 6:55 PM
> To: s-uchida-LYU95VJlayp8UrSeD/g0lQ@public.gmane.org; vtaras-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
> Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org;
> containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org; axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org;
> tom-sugawara-LYU95VJlayp8UrSeD/g0lQ@public.gmane.org; m-takahashi-kvZsz0w9TrB8UrSeD/g0lQ@public.gmane.org; devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
> Subject: Re: [RFC][v2][patch 0/12][CFQ-cgroup]Yet another I/O bandwidth
> controlling subsystem for CGroups based on CFQ
> 
> Hi,
> 
> I report benchmark results of the following I/O bandwidth controllers.
> 
>   From:	Vasily Tarasov <vtaras-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
>   Subject: [RFC][PATCH 0/9] cgroups: block: cfq: I/O bandwidth
>            controlling subsystem for CGroups based on CFQ
>   Date: Fri, 15 Feb 2008 01:53:34 -0500
> 
>   From: "Satoshi UCHIDA" <s-uchida-LYU95VJlayp8UrSeD/g0lQ@public.gmane.org>
>   Subject: [RFC][v2][patch 0/12][CFQ-cgroup]Yet another I/O bandwidth
>            controlling subsystem for CGroups based on CFQ
>   Date: Thu, 3 Apr 2008 16:09:12 +0900
> 
> The test procedure is as follows:
>   o Prepare 3 partitions sdc2, sdc3 and sdc4.
>   o Run 100 processes issuing random direct I/O with 4KB data on each
>     partitions.
>   o Run 3 tests:
>     #1 issuing read I/O only.
>     #2 issuing write I/O only.
>     #3 sdc2 and sdc3 are read, sdc4 is write.
>   o Count up the number of I/Os which have done in 60 seconds.
> 
> Unfortunately, both bandwidth controllers didn't work as I expected,
> On the test #3, the write I/O ate up the bandwidth regardless of the
> specified priority level.
> 
>                           Vasily's scheduler
>                The number of I/Os (percentage to total I/Os)
> 
> ---------------------------------------------------------------------
>   | partition     |     sdc2     |     sdc3     |     sdc4     | total
> |
>   | priority      |  7(highest)  |      4       |  0(lowest)   |  I/Os
> |
> 
> |---------------+--------------+--------------+--------------|--------
> |
>   | #1 read       |  3620(35.6%) |  3474(34.2%) |  3065(30.2%) |  10159
> |
>   | #2 write      | 21985(36.6%) | 19274(32.1%) | 18856(31.4%) |  60115
> |
>   | #3 read&write |  5571( 7.5%) |  3253( 4.4%) | 64977(88.0%) |  73801
> |
> 
> ---------------------------------------------------------------------
> 
>                           Satoshi's scheduler
>                The number of I/Os (percentage to total I/O)
> 
> ---------------------------------------------------------------------
>   | partition     |     sdc2     |     sdc3     |     sdc4     | total
> |
>   | priority      |  0(highest)  |      4       |  7(lowest)   |  I/Os
> |
> 
> |---------------+--------------+--------------+--------------|--------
> |
>   | #1 read       |  4523(47.8%) |  3733(39.5%) |  1204(12.7%) |   9460
> |
>   | #2 write      | 65202(59.0%) | 35603(32.2%) |  9673( 8.8%) | 110478
> |
>   | #3 read&write |  5328(23.0%) |  4153(17.9%) | 13694(59.1%) |  23175
> |
> 
> ---------------------------------------------------------------------
> 
> I'd like to see other benchmark results if anyone has.
> 
> Thanks,
> Ryo Tsuruta
