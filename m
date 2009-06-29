From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC] IO scheduler based io controller (V5)
Date: Mon, 29 Jun 2009 13:23:09 -0400
Message-ID: <20090629172309.GB4622__14345.1444841505$1246296407$gmane$org@redhat.com>
References: <1245443858-8487-1-git-send-email-vgoyal@redhat.com>
	<4A48E601.2050203@vlnb.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4A48E601.2050203-d+Crzxg7Rs0@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Vladislav Bolkhovitin <vst-d+Crzxg7Rs0@public.gmane.org>
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, Jun 29, 2009 at 08:04:17PM +0400, Vladislav Bolkhovitin wrote:
> Hi,
>
> Vivek Goyal, on 06/20/2009 12:37 AM wrote:
>> Hi All,
>>
>> Here is the V5 of the IO controller patches generated on top of 2.6.30.
>>
>> Previous versions of the patches was posted here.
>>
>> (V1) http://lkml.org/lkml/2009/3/11/486
>> (V2) http://lkml.org/lkml/2009/5/5/275
>> (V3) http://lkml.org/lkml/2009/5/26/472
>> (V4) http://lkml.org/lkml/2009/6/8/580
>>
>> This patchset is still work in progress but I want to keep on getting the
>> snapshot of my tree out at regular intervals to get the feedback hence V5.
>
> [..]
>
>> Testing
>> =======
>>
>> I have been able to do only very basic testing of reads and writes.
>>
>> Test1 (Fairness for synchronous reads)
>> ======================================
>> - Two dd in two cgroups with cgrop weights 1000 and 500. Ran two "dd" in those
>>   cgroups (With CFQ scheduler and /sys/block/<device>/queue/fairness = 1)
>>
>> dd if=/mnt/$BLOCKDEV/zerofile1 of=/dev/null &
>> dd if=/mnt/$BLOCKDEV/zerofile2 of=/dev/null &
>>
>> 234179072 bytes (234 MB) copied, 3.9065 s, 59.9 MB/s
>> 234179072 bytes (234 MB) copied, 5.19232 s, 45.1 MB/s
>
> Sorry, but the above isn't a correct way to test proportional fairness  
> for synchronous reads. You need throughput only when *both* dd's  
> running, don't you?
>

Hi Vladislav,

Actually the focus here is following two lines.

group1 time=8 16 2471 group1 sectors=8 16 457840
group2 time=8 16 1220 group2 sectors=8 16 225736

I have pasted the output of dd completion output but as you pointed out
it does not mean much as higher weight dd finishes first and after that
second dd will get 100% of disk.

What I have done is that launch two dd jobs. The moment first dd finishes,
my scripts go and read up "io.disk_time" and "io.disk_sectors" files in two
cgroups.

disk_time keeps track of how much disk time a cgroup has got on a
particular disk and disk_sector keeps track of how many sector of IO a
cgroup has done on a particular disk.

Please notice above that once first dd (higher weight dd) finished, at
that point group1 got 2471 ms of disk time and group2 got 1220 ms of disk
time.

Similarly, by the time first dd finished, group1 has transferred 457840
sectors and group 2 has transferred 225736 sectors.

Here disk time of group1 is almost double of disk time received by group2.
(group1 weight=1000 and group2 weight=500). Currently like CFQ, we provide
fairness in terms of disk time.

So I think test should be fine. Just that output of "dd" is confusing and
probably I did not explain the testing procedure well. In next posting
will make the procedure more clear.

> Considering both transfers started simultaneously (which isn't obvious  
> too) in the way you test the throughput value only for the first  
> finished dd is correct, because after it finished, the second dd started  
> transferring data *alone*, hence the result throughput value for it got  
> partially for simultaneous, partially for alone reads, i.e. screwed.
>
> I'd suggest you instead test as 2 runs of:
>
> 1. while true; do dd if=/mnt/$BLOCKDEV/zerofile1 of=/dev/null; done
>    dd if=/mnt/$BLOCKDEV/zerofile2 of=/dev/null
>
> 2. while true; do dd if=/mnt/$BLOCKDEV/zerofile2 of=/dev/null; done
>    dd if=/mnt/$BLOCKDEV/zerofile1 of=/dev/null
>
> and take results from the standalone dd's.
>
> Vlad
