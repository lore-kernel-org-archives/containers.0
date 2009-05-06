From: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: IO scheduler based IO Controller V2
Date: Wed, 6 May 2009 23:34:54 +0200
Message-ID: <20090506213453.GC4282__9610.87716646052$1241646121$gmane$org@linux>
References: <1241553525-28095-1-git-send-email-vgoyal@redhat.com>
	<20090505132441.1705bfad.akpm@linux-foundation.org>
	<20090506023332.GA1212@redhat.com>
	<20090506203228.GH8180@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090506203228.GH8180-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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

On Wed, May 06, 2009 at 04:32:28PM -0400, Vivek Goyal wrote:
> Hi Andrea and others,
> 
> I always had this doubt in mind that any kind of 2nd level controller will
> have no idea about underlying IO scheduler queues/semantics. So while it
> can implement a particular cgroup policy (max bw like io-throttle or
> proportional bw like dm-ioband) but there are high chances that it will
> break IO scheduler's semantics in one way or other.
> 
> I had already sent out the results for dm-ioband in a separate thread.
> 
> http://linux.derkeiler.com/Mailing-Lists/Kernel/2009-04/msg07258.html
> http://linux.derkeiler.com/Mailing-Lists/Kernel/2009-04/msg07573.html
> http://linux.derkeiler.com/Mailing-Lists/Kernel/2009-04/msg08177.html
> http://linux.derkeiler.com/Mailing-Lists/Kernel/2009-04/msg08345.html
> http://linux.derkeiler.com/Mailing-Lists/Kernel/2009-04/msg08355.html
> 
> Here are some basic results with io-throttle. Andrea, please let me know
> if you think this is procedural problem. Playing with io-throttle patches
> for the first time.
> 
> I took V16 of your patches and trying it out with 2.6.30-rc4 with CFQ
> scheduler.
> 
> I have got one SATA drive with one partition on it.
> 
> I am trying to create one cgroup and assignn 8MB/s limit to it and launch
> on RT prio 0 task and one BE prio 7 task and see how this 8MB/s is divided
> between these tasks. Following are the results.
> 
> Following is my test script.
> 
> *******************************************************************
> #!/bin/bash
> 
> mount /dev/sdb1 /mnt/sdb
> 
> mount -t cgroup -o blockio blockio /cgroup/iot/
> mkdir -p /cgroup/iot/test1 /cgroup/iot/test2
> 
> # Set bw limit of 8 MB/ps on sdb
> echo "/dev/sdb:$((8 * 1024 * 1024)):0:0" >
> /cgroup/iot/test1/blockio.bandwidth-max
> 
> sync
> echo 3 > /proc/sys/vm/drop_caches
> 
> echo $$ > /cgroup/iot/test1/tasks
> 
> # Launch a normal prio reader.
> ionice -c 2 -n 7 dd if=/mnt/sdb/zerofile1 of=/dev/zero &
> pid1=$!
> echo $pid1
> 
> # Launch an RT reader  
> ionice -c 1 -n 0 dd if=/mnt/sdb/zerofile2 of=/dev/zero &
> pid2=$!
> echo $pid2
> 
> wait $pid2
> echo "RT task finished"
> **********************************************************************
> 
> Test1
> =====
> Test two readers (one RT class and one BE class) and see how BW is
> allocated with-in cgroup
> 
> With io-throttle patches
> ------------------------
> - Two readers, first BE prio 7, second RT prio 0
> 
> 234179072 bytes (234 MB) copied, 55.8482 s, 4.2 MB/s
> 234179072 bytes (234 MB) copied, 55.8975 s, 4.2 MB/s
> RT task finished
> 
> Note: See, there is no difference in the performance of RT or BE task.
> Looks like these got throttled equally.

OK, this is coherent with the current io-throttle implementation. IO
requests are throttled without the concept of the ioprio model.

We could try to distribute the throttle using a function of each task's
ioprio, but ok, the obvious drawback is that it totally breaks the logic
used by the underlying layers.

BTW, I'm wondering, is it a very critical issue? I would say why not to
move the RT task to a different cgroup with unlimited BW? or limited BW
but with other tasks running at the same IO priority... could the cgroup
subsystem be a more flexible and customizable framework respect to the
current ioprio model?

I'm not saying we have to ignore the problem, just trying to evaluate
the impact and alternatives. And I'm still convinced that also providing
per-cgroup ioprio would be an important feature.

> 
> 
> Without io-throttle patches
> ----------------------------
> - Two readers, first BE prio 7, second RT prio 0
> 
> 234179072 bytes (234 MB) copied, 2.81801 s, 83.1 MB/s
> RT task finished
> 234179072 bytes (234 MB) copied, 5.28238 s, 44.3 MB/s
> 
> Note: Because I can't limit the BW without io-throttle patches, so don't
>       worry about increased BW. But the important point is that RT task
>       gets much more BW than a BE prio 7 task.
> 
> Test2
> ====
> - Test 2 readers (One BE prio 0 and one BE prio 7) and see how BW is
> distributed among these.
> 
> With io-throttle patches
> ------------------------
> - Two readers, first BE prio 7, second BE prio 0
> 
> 234179072 bytes (234 MB) copied, 55.8604 s, 4.2 MB/s
> 234179072 bytes (234 MB) copied, 55.8918 s, 4.2 MB/s
> High prio reader finished

Ditto.

> 
> Without io-throttle patches
> ---------------------------
> - Two readers, first BE prio 7, second BE prio 0
> 
> 234179072 bytes (234 MB) copied, 4.12074 s, 56.8 MB/s
> High prio reader finished
> 234179072 bytes (234 MB) copied, 5.36023 s, 43.7 MB/s
> 
> Note: There is no service differentiation between prio 0 and prio 7 task
>       with io-throttle patches.
> 
> Test 3
> ======
> - Run the one RT reader and one BE reader in root cgroup without any
>   limitations. I guess this should mean unlimited BW and behavior should
>   be same as with CFQ without io-throttling patches.
> 
> With io-throttle patches
> =========================
> Ran the test 4 times because I was getting different results in different
> runs.
> 
> - Two readers, one RT prio 0  other BE prio 7
> 
> 234179072 bytes (234 MB) copied, 2.74604 s, 85.3 MB/s
> 234179072 bytes (234 MB) copied, 5.20995 s, 44.9 MB/s
> RT task finished
> 
> 234179072 bytes (234 MB) copied, 4.54417 s, 51.5 MB/s
> RT task finished
> 234179072 bytes (234 MB) copied, 5.23396 s, 44.7 MB/s
> 
> 234179072 bytes (234 MB) copied, 5.17727 s, 45.2 MB/s
> RT task finished
> 234179072 bytes (234 MB) copied, 5.25894 s, 44.5 MB/s
> 
> 234179072 bytes (234 MB) copied, 2.74141 s, 85.4 MB/s
> 234179072 bytes (234 MB) copied, 5.20536 s, 45.0 MB/s
> RT task finished
> 
> Note: Out of 4 runs, looks like twice it is complete priority inversion
>       and RT task finished after BE task. Rest of the two times, the
>       difference between BW of RT and BE task is much less as compared to
>       without patches. In fact once it was almost same.

This is strange. If you don't set any limit there shouldn't be any
difference respect to the other case (without io-throttle patches).

At worst a small overhead given by the task_to_iothrottle(), under
rcu_read_lock(). I'll repeat this test ASAP and see if I'll be able to
reproduce this strange behaviour.

> 
> Without io-throttle patches.
> ===========================
> - Two readers, one RT prio 0  other BE prio 7 (4 runs)
> 
> 234179072 bytes (234 MB) copied, 2.80988 s, 83.3 MB/s
> RT task finished
> 234179072 bytes (234 MB) copied, 5.28228 s, 44.3 MB/s
> 
> 234179072 bytes (234 MB) copied, 2.80659 s, 83.4 MB/s
> RT task finished
> 234179072 bytes (234 MB) copied, 5.27874 s, 44.4 MB/s
> 
> 234179072 bytes (234 MB) copied, 2.79601 s, 83.8 MB/s
> RT task finished
> 234179072 bytes (234 MB) copied, 5.2542 s, 44.6 MB/s
> 
> 234179072 bytes (234 MB) copied, 2.78764 s, 84.0 MB/s
> RT task finished
> 234179072 bytes (234 MB) copied, 5.26009 s, 44.5 MB/s
> 
> Note, How consistent the behavior is without io-throttle patches.
> 
> In summary, I think a 2nd level solution can ensure one policy on cgroups but
> it will break other semantics/properties of IO scheduler with-in cgroup as
> 2nd level solution has no idea at run time what is the IO scheduler running
> underneath and what kind of properties it has.
> 
> Andrea, please try it on your setup and see if you get similar results
> on or. Hopefully it is not a configuration or test procedure issue on my
> side.
> 
> Thanks
> Vivek
> 
> > The only thing which concerns me is the fact that IO scheduler does not
> > have the view of higher level logical device. So if somebody has setup a
> > software RAID and wants to put max BW limit on software raid device, this
> > solution will not work. One shall have to live with max bw limits on 
> > individual disks (where io scheduler is actually running). Do your patches
> > allow to put limit on software RAID devices also? 
> > 
> > Ryo, dm-ioband breaks the notion of classes and priority of CFQ because
> > of FIFO dispatch of buffered bios. Apart from that it tries to provide
> > fairness in terms of actual IO done and that would mean a seeky workload
> > will can use disk for much longer to get equivalent IO done and slow down
> > other applications. Implementing IO controller at IO scheduler level gives
> > us tigher control. Will it not meet your requirements? If you got specific
> > concerns with IO scheduler based contol patches, please highlight these and
> > we will see how these can be addressed.
> > 
> > Thanks
> > Vivek

-Andrea
