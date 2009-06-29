From: Vladislav Bolkhovitin <vst-d+Crzxg7Rs0@public.gmane.org>
Subject: Re: [RFC] IO scheduler based io controller (V5)
Date: Mon, 29 Jun 2009 20:04:17 +0400
Message-ID: <4A48E601.2050203__33098.9820686684$1246291811$gmane$org@vlnb.net>
References: <1245443858-8487-1-git-send-email-vgoyal@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1245443858-8487-1-git-send-email-vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

Hi,

Vivek Goyal, on 06/20/2009 12:37 AM wrote:
> Hi All,
> 
> Here is the V5 of the IO controller patches generated on top of 2.6.30.
> 
> Previous versions of the patches was posted here.
> 
> (V1) http://lkml.org/lkml/2009/3/11/486
> (V2) http://lkml.org/lkml/2009/5/5/275
> (V3) http://lkml.org/lkml/2009/5/26/472
> (V4) http://lkml.org/lkml/2009/6/8/580
> 
> This patchset is still work in progress but I want to keep on getting the
> snapshot of my tree out at regular intervals to get the feedback hence V5.

[..]

> Testing
> =======
> 
> I have been able to do only very basic testing of reads and writes.
> 
> Test1 (Fairness for synchronous reads)
> ======================================
> - Two dd in two cgroups with cgrop weights 1000 and 500. Ran two "dd" in those
>   cgroups (With CFQ scheduler and /sys/block/<device>/queue/fairness = 1)
> 
> dd if=/mnt/$BLOCKDEV/zerofile1 of=/dev/null &
> dd if=/mnt/$BLOCKDEV/zerofile2 of=/dev/null &
> 
> 234179072 bytes (234 MB) copied, 3.9065 s, 59.9 MB/s
> 234179072 bytes (234 MB) copied, 5.19232 s, 45.1 MB/s

Sorry, but the above isn't a correct way to test proportional fairness 
for synchronous reads. You need throughput only when *both* dd's 
running, don't you?

Considering both transfers started simultaneously (which isn't obvious 
too) in the way you test the throughput value only for the first 
finished dd is correct, because after it finished, the second dd started 
transferring data *alone*, hence the result throughput value for it got 
partially for simultaneous, partially for alone reads, i.e. screwed.

I'd suggest you instead test as 2 runs of:

1. while true; do dd if=/mnt/$BLOCKDEV/zerofile1 of=/dev/null; done
    dd if=/mnt/$BLOCKDEV/zerofile2 of=/dev/null

2. while true; do dd if=/mnt/$BLOCKDEV/zerofile2 of=/dev/null; done
    dd if=/mnt/$BLOCKDEV/zerofile1 of=/dev/null

and take results from the standalone dd's.

Vlad
