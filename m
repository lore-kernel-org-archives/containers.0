From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC] IO Controller
Date: Wed, 22 Apr 2009 09:23:07 -0400
Message-ID: <20090422132307.GA23098__42486.4042587162$1240407179$gmane$org@redhat.com>
References: <1236823015-4183-1-git-send-email-vgoyal@redhat.com>
	<49DF1256.7080403@cn.fujitsu.com>
	<20090413130958.GB18007@redhat.com>
	<49EE895A.1060101@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <49EE895A.1060101-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
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
Cc: paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, oz-kernel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, arozansk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, fernando-w0OK63jvRlAuJ+9fw/WgBHgSJqDPrsil@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, Apr 22, 2009 at 11:04:58AM +0800, Gui Jianfeng wrote:
> Vivek Goyal wrote:
> > On Fri, Apr 10, 2009 at 05:33:10PM +0800, Gui Jianfeng wrote:
> >> Vivek Goyal wrote:
> >>> Hi All,
> >>>
> >>> Here is another posting for IO controller patches. Last time I had posted
> >>> RFC patches for an IO controller which did bio control per cgroup.
> >>   Hi Vivek,
> >>
> >>   I got the following OOPS when testing, can't reproduce again :(
> >>
> > 
> > Hi Gui,
> > 
> > Thanks for the report. Will look into it and see if I can reproduce it.
> 
>   Hi Vivek,
> 
>   The following script can reproduce the bug in my box.
> 
> #!/bin/sh
> 
> mkdir /cgroup
> mount -t cgroup -o io io /cgroup
> mkdir /cgroup/test1
> mkdir /cgroup/test2
> 
> echo cfq > /sys/block/sda/queue/scheduler
> echo 7 > /cgroup/test1/io.ioprio
> echo 1 > /cgroup/test2/io.ioprio
> echo 1 > /proc/sys/vm/drop_caches
> dd if=1000M.1 of=/dev/null &
> pid1=$!
> echo $pid1
> echo $pid1 > /cgroup/test1/tasks
> dd if=1000M.2 of=/dev/null
> pid2=$!
> echo $pid2
> echo $pid2 > /cgroup/test2/tasks
> 
> 
> rmdir /cgroup/test1
> rmdir /cgroup/test2
> umount /cgroup
> rmdir /cgroup

Thanks Gui. We have got races with task movement and cgroup deletion. In
the original bfq patch, Fabio had implemented the logic to migrate the
task queue synchronously. It found the logic to be little complicated so I
changed it to delayed movement of queue from old cgroup to new cgroup.
Fabio later mentioned that it introduces a race where old cgroup is
deleted before task queue has actually moved to new cgroup.

Nauman is currently implementing reference counting for io groups and that
will solve this problem at the same time some other problems like movement
of queue to root group during cgroup deletion and which can potentially 
result in unfair share for some time to that queue etc.

Thanks
Vivek
