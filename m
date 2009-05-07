From: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: IO scheduler based IO Controller V2
Date: Thu, 7 May 2009 11:04:50 +0200
Message-ID: <20090507090450.GA4613__21098.0323529386$1241687231$gmane$org@linux>
References: <1241553525-28095-1-git-send-email-vgoyal@redhat.com>
	<20090505132441.1705bfad.akpm@linux-foundation.org>
	<20090506023332.GA1212@redhat.com>
	<20090506203228.GH8180@redhat.com> <20090506213453.GC4282@linux>
	<20090506215235.GJ8180@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090506215235.GJ8180-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, May 06, 2009 at 05:52:35PM -0400, Vivek Goyal wrote:
> > > Without io-throttle patches
> > > ---------------------------
> > > - Two readers, first BE prio 7, second BE prio 0
> > > 
> > > 234179072 bytes (234 MB) copied, 4.12074 s, 56.8 MB/s
> > > High prio reader finished
> > > 234179072 bytes (234 MB) copied, 5.36023 s, 43.7 MB/s
> > > 
> > > Note: There is no service differentiation between prio 0 and prio 7 task
> > >       with io-throttle patches.
> > > 
> > > Test 3
> > > ======
> > > - Run the one RT reader and one BE reader in root cgroup without any
> > >   limitations. I guess this should mean unlimited BW and behavior should
> > >   be same as with CFQ without io-throttling patches.
> > > 
> > > With io-throttle patches
> > > =========================
> > > Ran the test 4 times because I was getting different results in different
> > > runs.
> > > 
> > > - Two readers, one RT prio 0  other BE prio 7
> > > 
> > > 234179072 bytes (234 MB) copied, 2.74604 s, 85.3 MB/s
> > > 234179072 bytes (234 MB) copied, 5.20995 s, 44.9 MB/s
> > > RT task finished
> > > 
> > > 234179072 bytes (234 MB) copied, 4.54417 s, 51.5 MB/s
> > > RT task finished
> > > 234179072 bytes (234 MB) copied, 5.23396 s, 44.7 MB/s
> > > 
> > > 234179072 bytes (234 MB) copied, 5.17727 s, 45.2 MB/s
> > > RT task finished
> > > 234179072 bytes (234 MB) copied, 5.25894 s, 44.5 MB/s
> > > 
> > > 234179072 bytes (234 MB) copied, 2.74141 s, 85.4 MB/s
> > > 234179072 bytes (234 MB) copied, 5.20536 s, 45.0 MB/s
> > > RT task finished
> > > 
> > > Note: Out of 4 runs, looks like twice it is complete priority inversion
> > >       and RT task finished after BE task. Rest of the two times, the
> > >       difference between BW of RT and BE task is much less as compared to
> > >       without patches. In fact once it was almost same.
> > 
> > This is strange. If you don't set any limit there shouldn't be any
> > difference respect to the other case (without io-throttle patches).
> > 
> > At worst a small overhead given by the task_to_iothrottle(), under
> > rcu_read_lock(). I'll repeat this test ASAP and see if I'll be able to
> > reproduce this strange behaviour.
> 
> Ya, I also found this strange. At least in root group there should not be
> any behavior change (at max one might expect little drop in throughput
> because of extra code).

Hi Vivek,

I'm not able to reproduce the strange behaviour above.

Which commands are you running exactly? is the system isolated (stupid
question) no cron or background tasks doing IO during the tests?

Following the script I've used:

$ cat test.sh
#!/bin/sh
echo 3 > /proc/sys/vm/drop_caches
ionice -c 1 -n 0 dd if=bigfile1 of=/dev/null bs=1M 2>&1 | sed "s/\(.*\)/RT: \1/" &
cat /proc/$!/cgroup | sed "s/\(.*\)/RT: \1/"
ionice -c 2 -n 7 dd if=bigfile2 of=/dev/null bs=1M 2>&1 | sed "s/\(.*\)/BE: \1/" &
cat /proc/$!/cgroup | sed "s/\(.*\)/BE: \1/"
for i in 1 2; do
	wait
done

And the results on my PC:

2.6.30-rc4
~~~~~~~~~~
$ sudo sh test.sh | sort
BE: 234+0 records in
BE: 234+0 records out
BE: 245366784 bytes (245 MB) copied, 21.3406 s, 11.5 MB/s
RT: 234+0 records in
RT: 234+0 records out
RT: 245366784 bytes (245 MB) copied, 11.989 s, 20.5 MB/s
$ sudo sh test.sh | sort
BE: 234+0 records in
BE: 234+0 records out
BE: 245366784 bytes (245 MB) copied, 23.4436 s, 10.5 MB/s
RT: 234+0 records in
RT: 234+0 records out
RT: 245366784 bytes (245 MB) copied, 11.9555 s, 20.5 MB/s
$ sudo sh test.sh | sort
BE: 234+0 records in
BE: 234+0 records out
BE: 245366784 bytes (245 MB) copied, 21.622 s, 11.3 MB/s
RT: 234+0 records in
RT: 234+0 records out
RT: 245366784 bytes (245 MB) copied, 11.9856 s, 20.5 MB/s
$ sudo sh test.sh | sort
BE: 234+0 records in
BE: 234+0 records out
BE: 245366784 bytes (245 MB) copied, 21.5664 s, 11.4 MB/s
RT: 234+0 records in
RT: 234+0 records out
RT: 245366784 bytes (245 MB) copied, 11.8522 s, 20.7 MB/s

2.6.30-rc4 + io-throttle, no BW limit, both tasks in the root cgroup
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$ sudo sh ./test.sh | sort
BE: 234+0 records in
BE: 234+0 records out
BE: 245366784 bytes (245 MB) copied, 23.6739 s, 10.4 MB/s
BE: cgroup 4:blockio:/
RT: 234+0 records in
RT: 234+0 records out
RT: 245366784 bytes (245 MB) copied, 12.2853 s, 20.0 MB/s
RT: 4:blockio:/
$ sudo sh ./test.sh | sort
BE: 234+0 records in
BE: 234+0 records out
BE: 245366784 bytes (245 MB) copied, 23.7483 s, 10.3 MB/s
BE: cgroup 4:blockio:/
RT: 234+0 records in
RT: 234+0 records out
RT: 245366784 bytes (245 MB) copied, 12.3597 s, 19.9 MB/s
RT: 4:blockio:/
$ sudo sh ./test.sh | sort
BE: 234+0 records in
BE: 234+0 records out
BE: 245366784 bytes (245 MB) copied, 23.6843 s, 10.4 MB/s
BE: cgroup 4:blockio:/
RT: 234+0 records in
RT: 234+0 records out
RT: 245366784 bytes (245 MB) copied, 12.4886 s, 19.6 MB/s
RT: 4:blockio:/
$ sudo sh ./test.sh | sort
BE: 234+0 records in
BE: 234+0 records out
BE: 245366784 bytes (245 MB) copied, 23.8621 s, 10.3 MB/s
BE: cgroup 4:blockio:/
RT: 234+0 records in
RT: 234+0 records out
RT: 245366784 bytes (245 MB) copied, 12.6737 s, 19.4 MB/s
RT: 4:blockio:/

The difference seems to be just the expected overhead.

-Andrea
