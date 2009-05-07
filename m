From: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Subject: Re: IO scheduler based IO Controller V2
Date: Thu, 07 May 2009 10:48:01 +0900 (JST)
Message-ID: <20090507.104801.104058628.ryov__27854.7541740865$1241661058$gmane$org@valinux.co.jp>
References: <20090506213453.GC4282@linux> <20090506215235.GJ8180@redhat.com>
	<20090506223512.GE4282@linux>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090506223512.GE4282@linux>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

From: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: IO scheduler based IO Controller V2
Date: Thu, 7 May 2009 00:35:13 +0200

> On Wed, May 06, 2009 at 05:52:35PM -0400, Vivek Goyal wrote:
> > On Wed, May 06, 2009 at 11:34:54PM +0200, Andrea Righi wrote:
> > > On Wed, May 06, 2009 at 04:32:28PM -0400, Vivek Goyal wrote:
> > > > Hi Andrea and others,
> > > > 
> > > > I always had this doubt in mind that any kind of 2nd level controller will
> > > > have no idea about underlying IO scheduler queues/semantics. So while it
> > > > can implement a particular cgroup policy (max bw like io-throttle or
> > > > proportional bw like dm-ioband) but there are high chances that it will
> > > > break IO scheduler's semantics in one way or other.
> > > > 
> > > > I had already sent out the results for dm-ioband in a separate thread.
> > > > 
> > > > http://linux.derkeiler.com/Mailing-Lists/Kernel/2009-04/msg07258.html
> > > > http://linux.derkeiler.com/Mailing-Lists/Kernel/2009-04/msg07573.html
> > > > http://linux.derkeiler.com/Mailing-Lists/Kernel/2009-04/msg08177.html
> > > > http://linux.derkeiler.com/Mailing-Lists/Kernel/2009-04/msg08345.html
> > > > http://linux.derkeiler.com/Mailing-Lists/Kernel/2009-04/msg08355.html
> > > > 
> > > > Here are some basic results with io-throttle. Andrea, please let me know
> > > > if you think this is procedural problem. Playing with io-throttle patches
> > > > for the first time.
> > > > 
> > > > I took V16 of your patches and trying it out with 2.6.30-rc4 with CFQ
> > > > scheduler.
> > > > 
> > > > I have got one SATA drive with one partition on it.
> > > > 
> > > > I am trying to create one cgroup and assignn 8MB/s limit to it and launch
> > > > on RT prio 0 task and one BE prio 7 task and see how this 8MB/s is divided
> > > > between these tasks. Following are the results.
> > > > 
> > > > Following is my test script.
> > > > 
> > > > *******************************************************************
> > > > #!/bin/bash
> > > > 
> > > > mount /dev/sdb1 /mnt/sdb
> > > > 
> > > > mount -t cgroup -o blockio blockio /cgroup/iot/
> > > > mkdir -p /cgroup/iot/test1 /cgroup/iot/test2
> > > > 
> > > > # Set bw limit of 8 MB/ps on sdb
> > > > echo "/dev/sdb:$((8 * 1024 * 1024)):0:0" >
> > > > /cgroup/iot/test1/blockio.bandwidth-max
> > > > 
> > > > sync
> > > > echo 3 > /proc/sys/vm/drop_caches
> > > > 
> > > > echo $$ > /cgroup/iot/test1/tasks
> > > > 
> > > > # Launch a normal prio reader.
> > > > ionice -c 2 -n 7 dd if=/mnt/sdb/zerofile1 of=/dev/zero &
> > > > pid1=$!
> > > > echo $pid1
> > > > 
> > > > # Launch an RT reader  
> > > > ionice -c 1 -n 0 dd if=/mnt/sdb/zerofile2 of=/dev/zero &
> > > > pid2=$!
> > > > echo $pid2
> > > > 
> > > > wait $pid2
> > > > echo "RT task finished"
> > > > **********************************************************************
> > > > 
> > > > Test1
> > > > =====
> > > > Test two readers (one RT class and one BE class) and see how BW is
> > > > allocated with-in cgroup
> > > > 
> > > > With io-throttle patches
> > > > ------------------------
> > > > - Two readers, first BE prio 7, second RT prio 0
> > > > 
> > > > 234179072 bytes (234 MB) copied, 55.8482 s, 4.2 MB/s
> > > > 234179072 bytes (234 MB) copied, 55.8975 s, 4.2 MB/s
> > > > RT task finished
> > > > 
> > > > Note: See, there is no difference in the performance of RT or BE task.
> > > > Looks like these got throttled equally.
> > > 
> > > OK, this is coherent with the current io-throttle implementation. IO
> > > requests are throttled without the concept of the ioprio model.
> > > 
> > > We could try to distribute the throttle using a function of each task's
> > > ioprio, but ok, the obvious drawback is that it totally breaks the logic
> > > used by the underlying layers.
> > > 
> > > BTW, I'm wondering, is it a very critical issue? I would say why not to
> > > move the RT task to a different cgroup with unlimited BW? or limited BW
> > > but with other tasks running at the same IO priority...
> > 
> > So one of hypothetical use case probably  could be following. Somebody
> > is having a hosted server and customers are going to get there
> > applications running in a particular cgroup with a limit on max bw.
> > 
> > 			root
> > 		  /      |      \
> > 	     cust1      cust2   cust3
> > 	   (20 MB/s)  (40MB/s)  (30MB/s)
> > 
> > Now all three customers will run their own applications/virtual machines
> > in their respective groups with upper limits. Will we say to these that
> > all your tasks will be considered as same class and same prio level.
> > 
> > Assume cust1 is running a hypothetical application which creates multiple
> > threads and assigns these threads different priorities based on its needs
> > at run time. How would we handle this thing?
> > 
> > You can't collect all the RT tasks from all customers and move these to a
> > single cgroup. Or ask customers to separate out their tasks based on
> > priority level and give them multiple groups of different priority.
> 
> Clear.
> 
> Unfortunately, I think, with absolute BW limits at a certain point, if
> we hit the limit, we need to block the IO request. That's the same
> either, when we dispatch or submit the request. And the risk is to break
> the logic of the IO priorities and fall in the classic priority
> inversion problem.
> 
> The difference is that probably working at the CFQ level gives a better
> control so we can handle these cases appropriately and avoid the
> priority inversion problems.
> 
> Thanks,
> -Andrea

If RT tasks in cust1 issue IOs intensively, are IOs issued from BE
tasks running on cust2 and cust3 suppressed and cust1 can use whole
bandwidth?
I think that CFQ's class and priority should be preserved within a
given bandwidth to each cgroup.

Thanks,
Ryo Tsuruta
