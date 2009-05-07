From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: IO scheduler based IO Controller V2
Date: Thu, 7 May 2009 10:11:26 -0400
Message-ID: <20090507141126.GA9463__45073.1892757632$1241706197$gmane$org@redhat.com>
References: <1241553525-28095-1-git-send-email-vgoyal@redhat.com>
	<20090505132441.1705bfad.akpm@linux-foundation.org>
	<20090506023332.GA1212@redhat.com>
	<20090506203228.GH8180@redhat.com> <20090506213453.GC4282@linux>
	<20090506215235.GJ8180@redhat.com> <20090507090450.GA4613@linux>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090507090450.GA4613@linux>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, May 07, 2009 at 11:04:50AM +0200, Andrea Righi wrote:
> On Wed, May 06, 2009 at 05:52:35PM -0400, Vivek Goyal wrote:
> > > > Without io-throttle patches
> > > > ---------------------------
> > > > - Two readers, first BE prio 7, second BE prio 0
> > > > 
> > > > 234179072 bytes (234 MB) copied, 4.12074 s, 56.8 MB/s
> > > > High prio reader finished
> > > > 234179072 bytes (234 MB) copied, 5.36023 s, 43.7 MB/s
> > > > 
> > > > Note: There is no service differentiation between prio 0 and prio 7 task
> > > >       with io-throttle patches.
> > > > 
> > > > Test 3
> > > > ======
> > > > - Run the one RT reader and one BE reader in root cgroup without any
> > > >   limitations. I guess this should mean unlimited BW and behavior should
> > > >   be same as with CFQ without io-throttling patches.
> > > > 
> > > > With io-throttle patches
> > > > =========================
> > > > Ran the test 4 times because I was getting different results in different
> > > > runs.
> > > > 
> > > > - Two readers, one RT prio 0  other BE prio 7
> > > > 
> > > > 234179072 bytes (234 MB) copied, 2.74604 s, 85.3 MB/s
> > > > 234179072 bytes (234 MB) copied, 5.20995 s, 44.9 MB/s
> > > > RT task finished
> > > > 
> > > > 234179072 bytes (234 MB) copied, 4.54417 s, 51.5 MB/s
> > > > RT task finished
> > > > 234179072 bytes (234 MB) copied, 5.23396 s, 44.7 MB/s
> > > > 
> > > > 234179072 bytes (234 MB) copied, 5.17727 s, 45.2 MB/s
> > > > RT task finished
> > > > 234179072 bytes (234 MB) copied, 5.25894 s, 44.5 MB/s
> > > > 
> > > > 234179072 bytes (234 MB) copied, 2.74141 s, 85.4 MB/s
> > > > 234179072 bytes (234 MB) copied, 5.20536 s, 45.0 MB/s
> > > > RT task finished
> > > > 
> > > > Note: Out of 4 runs, looks like twice it is complete priority inversion
> > > >       and RT task finished after BE task. Rest of the two times, the
> > > >       difference between BW of RT and BE task is much less as compared to
> > > >       without patches. In fact once it was almost same.
> > > 
> > > This is strange. If you don't set any limit there shouldn't be any
> > > difference respect to the other case (without io-throttle patches).
> > > 
> > > At worst a small overhead given by the task_to_iothrottle(), under
> > > rcu_read_lock(). I'll repeat this test ASAP and see if I'll be able to
> > > reproduce this strange behaviour.
> > 
> > Ya, I also found this strange. At least in root group there should not be
> > any behavior change (at max one might expect little drop in throughput
> > because of extra code).
> 
> Hi Vivek,
> 
> I'm not able to reproduce the strange behaviour above.
> 
> Which commands are you running exactly? is the system isolated (stupid
> question) no cron or background tasks doing IO during the tests?
> 
> Following the script I've used:
> 
> $ cat test.sh
> #!/bin/sh
> echo 3 > /proc/sys/vm/drop_caches
> ionice -c 1 -n 0 dd if=bigfile1 of=/dev/null bs=1M 2>&1 | sed "s/\(.*\)/RT: \1/" &
> cat /proc/$!/cgroup | sed "s/\(.*\)/RT: \1/"
> ionice -c 2 -n 7 dd if=bigfile2 of=/dev/null bs=1M 2>&1 | sed "s/\(.*\)/BE: \1/" &
> cat /proc/$!/cgroup | sed "s/\(.*\)/BE: \1/"
> for i in 1 2; do
> 	wait
> done
> 
> And the results on my PC:
> 

[..]

> The difference seems to be just the expected overhead.

Hm..., something is really amiss here. I took your scripts and ran on
my system and I still see the issue. There is nothing else running on the
system and it is isolated.

2.6.30-rc4 + io-throttle patches V16
===================================
It is freshly booted system with nothing extra running on it. This is a
4 core system.

Disk1
=====
This is a fast disk which supports queue depth of 31.

Following is the output picked from dmesg for my device properties.
[    3.016099] sd 2:0:0:0: [sdb] 488397168 512-byte hardware sectors: (250
GB/232 GiB)
[    3.016188] sd 2:0:0:0: Attached scsi generic sg2 type 0

Following are the results of 4 runs of your script. (Just changed the 
script to read right file on my system if=/mnt/sdb/zerofile1).

[root@chilli io-throttle-tests]# ./andrea-test-script.sh 
BE: 223+1 records in
BE: 223+1 records out
BE: 234179072 bytes (234 MB) copied, 4.38435 s, 53.4 MB/s
RT: 223+1 records in
RT: 223+1 records out
RT: 234179072 bytes (234 MB) copied, 5.20706 s, 45.0 MB/s

[root@chilli io-throttle-tests]# ./andrea-test-script.sh 
BE: 223+1 records in
BE: 223+1 records out
BE: 234179072 bytes (234 MB) copied, 5.12953 s, 45.7 MB/s
RT: 223+1 records in
RT: 223+1 records out
RT: 234179072 bytes (234 MB) copied, 5.23573 s, 44.7 MB/s

[root@chilli io-throttle-tests]# ./andrea-test-script.sh 
BE: 223+1 records in
BE: 223+1 records out
BE: 234179072 bytes (234 MB) copied, 3.54644 s, 66.0 MB/s
RT: 223+1 records in
RT: 223+1 records out
RT: 234179072 bytes (234 MB) copied, 5.19406 s, 45.1 MB/s

[root@chilli io-throttle-tests]# ./andrea-test-script.sh 
RT: 223+1 records in
RT: 223+1 records out
RT: 234179072 bytes (234 MB) copied, 5.21908 s, 44.9 MB/s
BE: 223+1 records in
BE: 223+1 records out
BE: 234179072 bytes (234 MB) copied, 5.23802 s, 44.7 MB/s

Disk2
=====
This is a relatively slower disk with no command queuing.

[root@chilli io-throttle-tests]# ./andrea-test-script.sh 
RT: 223+1 records in
RT: 223+1 records out
RT: 234179072 bytes (234 MB) copied, 7.06471 s, 33.1 MB/s
BE: 223+1 records in
BE: 223+1 records out
BE: 234179072 bytes (234 MB) copied, 8.01571 s, 29.2 MB/s

[root@chilli io-throttle-tests]# ./andrea-test-script.sh 
RT: 223+1 records in
RT: 223+1 records out
RT: 234179072 bytes (234 MB) copied, 7.89043 s, 29.7 MB/s
BE: 223+1 records in
BE: 223+1 records out
BE: 234179072 bytes (234 MB) copied, 8.03428 s, 29.1 MB/s

[root@chilli io-throttle-tests]# ./andrea-test-script.sh 
BE: 223+1 records in
BE: 223+1 records out
BE: 234179072 bytes (234 MB) copied, 7.38942 s, 31.7 MB/s
RT: 223+1 records in
RT: 223+1 records out
RT: 234179072 bytes (234 MB) copied, 8.01146 s, 29.2 MB/s

[root@chilli io-throttle-tests]# ./andrea-test-script.sh 
BE: 223+1 records in
BE: 223+1 records out
BE: 234179072 bytes (234 MB) copied, 7.78351 s, 30.1 MB/s
RT: 223+1 records in
RT: 223+1 records out
RT: 234179072 bytes (234 MB) copied, 8.06292 s, 29.0 MB/s

Disk3
=====
This is an Intel SSD.

[root@chilli io-throttle-tests]# ./andrea-test-script.sh 
RT: 223+1 records in
RT: 223+1 records out
RT: 234179072 bytes (234 MB) copied, 0.993735 s, 236 MB/s
BE: 223+1 records in
BE: 223+1 records out
BE: 234179072 bytes (234 MB) copied, 1.98772 s, 118 MB/s

[root@chilli io-throttle-tests]# ./andrea-test-script.sh 
RT: 223+1 records in
RT: 223+1 records out
RT: 234179072 bytes (234 MB) copied, 1.8616 s, 126 MB/s
BE: 223+1 records in
BE: 223+1 records out
BE: 234179072 bytes (234 MB) copied, 1.98499 s, 118 MB/s

[root@chilli io-throttle-tests]# ./andrea-test-script.sh 
RT: 223+1 records in
RT: 223+1 records out
RT: 234179072 bytes (234 MB) copied, 1.01174 s, 231 MB/s
BE: 223+1 records in
BE: 223+1 records out
BE: 234179072 bytes (234 MB) copied, 1.99143 s, 118 MB/s

[root@chilli io-throttle-tests]# ./andrea-test-script.sh 
RT: 223+1 records in
RT: 223+1 records out
RT: 234179072 bytes (234 MB) copied, 1.96132 s, 119 MB/s
BE: 223+1 records in
BE: 223+1 records out
BE: 234179072 bytes (234 MB) copied, 1.97746 s, 118 MB/s

Results without io-throttle patches (vanilla 2.6.30-rc4)
========================================================

Disk 1
======
This is relatively faster SATA drive with command queuing enabled.

RT: 223+1 records in
RT: 223+1 records out
RT: 234179072 bytes (234 MB) copied, 2.84065 s, 82.4 MB/s
BE: 223+1 records in
BE: 223+1 records out
BE: 234179072 bytes (234 MB) copied, 5.30087 s, 44.2 MB/s

[root@chilli io-throttle-tests]# ./andrea-test-script.sh 
RT: 223+1 records in
RT: 223+1 records out
RT: 234179072 bytes (234 MB) copied, 2.69688 s, 86.8 MB/s
BE: 223+1 records in
BE: 223+1 records out
BE: 234179072 bytes (234 MB) copied, 5.18175 s, 45.2 MB/s

[root@chilli io-throttle-tests]# ./andrea-test-script.sh 
RT: 223+1 records in
RT: 223+1 records out
RT: 234179072 bytes (234 MB) copied, 2.73279 s, 85.7 MB/s
BE: 223+1 records in
BE: 223+1 records out
BE: 234179072 bytes (234 MB) copied, 5.21803 s, 44.9 MB/s

[root@chilli io-throttle-tests]# ./andrea-test-script.sh 
RT: 223+1 records in
RT: 223+1 records out
RT: 234179072 bytes (234 MB) copied, 2.69304 s, 87.0 MB/s
BE: 223+1 records in
BE: 223+1 records out
BE: 234179072 bytes (234 MB) copied, 5.17821 s, 45.2 MB/s

Disk 2
======
Slower disk with no command queuing.

[root@chilli io-throttle-tests]# ./andrea-test-script.sh 
RT: 223+1 records in
RT: 223+1 records out
RT: 234179072 bytes (234 MB) copied, 4.29453 s, 54.5 MB/s
BE: 223+1 records in
BE: 223+1 records out
BE: 234179072 bytes (234 MB) copied, 8.04978 s, 29.1 MB/s

[root@chilli io-throttle-tests]# ./andrea-test-script.sh 
RT: 223+1 records in
RT: 223+1 records out
RT: 234179072 bytes (234 MB) copied, 3.96924 s, 59.0 MB/s
BE: 223+1 records in
BE: 223+1 records out
BE: 234179072 bytes (234 MB) copied, 7.74984 s, 30.2 MB/s

[root@chilli io-throttle-tests]# ./andrea-test-script.sh 
RT: 223+1 records in
RT: 223+1 records out
RT: 234179072 bytes (234 MB) copied, 4.11254 s, 56.9 MB/s
BE: 223+1 records in
BE: 223+1 records out
BE: 234179072 bytes (234 MB) copied, 7.8678 s, 29.8 MB/s

[root@chilli io-throttle-tests]# ./andrea-test-script.sh 
RT: 223+1 records in
RT: 223+1 records out
RT: 234179072 bytes (234 MB) copied, 3.95979 s, 59.1 MB/s
BE: 223+1 records in
BE: 223+1 records out
BE: 234179072 bytes (234 MB) copied, 7.73976 s, 30.3 MB/s

Disk3
=====
Intel SSD

[root@chilli io-throttle-tests]# ./andrea-test-script.sh 
RT: 223+1 records in
RT: 223+1 records out
RT: 234179072 bytes (234 MB) copied, 0.996762 s, 235 MB/s
BE: 223+1 records in
BE: 223+1 records out
BE: 234179072 bytes (234 MB) copied, 1.93268 s, 121 MB/s

[root@chilli io-throttle-tests]# ./andrea-test-script.sh 
RT: 223+1 records in
RT: 223+1 records out
RT: 234179072 bytes (234 MB) copied, 0.98511 s, 238 MB/s
BE: 223+1 records in
BE: 223+1 records out
BE: 234179072 bytes (234 MB) copied, 1.92481 s, 122 MB/s

[root@chilli io-throttle-tests]# ./andrea-test-script.sh 
RT: 223+1 records in
RT: 223+1 records out
RT: 234179072 bytes (234 MB) copied, 0.986981 s, 237 MB/s
BE: 223+1 records in
BE: 223+1 records out
BE: 234179072 bytes (234 MB) copied, 1.9312 s, 121 MB/s

[root@chilli io-throttle-tests]# ./andrea-test-script.sh 
RT: 223+1 records in
RT: 223+1 records out
RT: 234179072 bytes (234 MB) copied, 0.988448 s, 237 MB/s
BE: 223+1 records in
BE: 223+1 records out
BE: 234179072 bytes (234 MB) copied, 1.93885 s, 121 MB/s

So I am still seeing the issue with differnt kind of disks also. At this point
of time I am really not sure why I am seeing such results.

I have following patches applied on 30-rc4 (V16).

3954-vivek.goyal2008-res_counter-introduce-ratelimiting-attributes.patch
3955-vivek.goyal2008-page_cgroup-provide-a-generic-page-tracking-infrastructure.patch
3956-vivek.goyal2008-io-throttle-controller-infrastructure.patch
3957-vivek.goyal2008-kiothrottled-throttle-buffered-io.patch
3958-vivek.goyal2008-io-throttle-instrumentation.patch
3959-vivek.goyal2008-io-throttle-export-per-task-statistics-to-userspace.patch

Thanks
Vivek
