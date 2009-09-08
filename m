From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC] IO scheduler based IO controller V9
Date: Tue, 8 Sep 2009 15:19:41 -0400
Message-ID: <20090908191941.GF15974__44572.9609266438$1252437810$gmane$org@redhat.com>
References: <1251495072-7780-1-git-send-email-vgoyal@redhat.com>
	<4AA4B905.8010801@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4AA4B905.8010801-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, jmarchan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, Sep 07, 2009 at 03:40:53PM +0800, Gui Jianfeng wrote:
> Hi Vivek,
> 
> I happened to encount a bug when i test IO Controller V9.
> When there are three tasks to run concurrently in three group,
> that is, one is parent group, and other two tasks are running 
> in two different child groups respectively to read or write 
> files in some disk, say disk "hdb", The task may hang up, and 
> other tasks which access into "hdb" will also hang up.
> 
> The bug only happens when using AS io scheduler.
> The following scirpt can reproduce this bug in my box.
> 

Hi Gui,

I tried reproducing this on my system and can't reproduce it. All the
three processes get killed and system does not hang.

Can you please dig deeper a bit into it. 

- If whole system hangs or it is just IO to disk seems to be hung.
- Does io scheduler switch on the device work
- If the system is not hung, can you capture the blktrace on the device.
  Trace might give some idea, what's happening.

Thanks
Vivek
 
> ===========
> #!/bin/sh
> 
> mkdir /cgroup
> mount -t cgroup -o io,blkio io  /cgroup
> 
> echo anticipatory > /sys/block/hdb/queue/scheduler
> 
> mkdir /cgroup/test1
> echo 100 > /cgroup/test1/io.weight
> 
> mkdir /cgroup/test2
> echo 400 > /cgroup/test2/io.weight
> 
> mkdir /cgroup/test2/test3
> echo 400 > /cgroup/test2/test3/io.weight
> 
> mkdir /cgroup/test2/test4
> echo 400 > /cgroup/test2/test4/io.weight
> 
> #./rwio -r -f /hdb2/2000M.3 &
> dd if=/hdb2/2000M.3 of=/dev/null &
> pid4=$!
> echo $pid4 > /cgroup/test2/test3/tasks
> echo "pid4: $pid4"
> 
> #./rwio -r -f /hdb2/2000M.1 &
> dd if=/hdb2/2000M.1 of=/dev/null &
> pid1=$!
> echo $pid1 > /cgroup/test1/tasks
> echo "pid1 $pid1"
> 
> #./rwio -r -f /hdb2/2000M.2 &
> dd if=/hdb2/2000M.2 of=/dev/null &
> pid2=$!
> echo $pid2 > /cgroup/test2/test4/tasks
> echo "pid2 $pid2"
> 
> sleep 20
> 
> for ((;1;))
> {
>         ps -p $pid1 > /dev/null 2>&1
>         if [ $? -ne 0 ]; then
>                 break
>         fi
> 
>         kill -9 $pid1 > /dev/null 2>&1
> }
> for ((;1;))
> {
>         ps -p $pid2 > /dev/null 2>&1
>         if [ $? -ne 0 ]; then
>                 break
>         fi
> 
>         kill -9 $pid2 > /dev/null 2>&1
> }
> 
> 
> kill -9 $pid4 > /dev/null 2>&1
> 
> rmdir /cgroup/test2/test3
> rmdir /cgroup/test2/test4
> rmdir /cgroup/test2
> rmdir /cgroup/test1
> 
> umount /cgroup
> rmdir /cgroup
