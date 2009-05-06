From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 01/18] io-controller: Documentation
Date: Wed, 6 May 2009 09:31:50 -0400
Message-ID: <20090506133150.GB8180__32890.1377194144$1241616909$gmane$org@redhat.com>
References: <1241553525-28095-1-git-send-email-vgoyal@redhat.com>
	<1241553525-28095-2-git-send-email-vgoyal@redhat.com>
	<4A0100F4.4040400@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4A0100F4.4040400-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
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
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, May 06, 2009 at 11:16:04AM +0800, Gui Jianfeng wrote:
> Vivek Goyal wrote:
> ...
> > +	mount -t cgroup -o io,blkio none /cgroup
> > +
> > +- Create two cgroups
> > +	mkdir -p /cgroup/test1/ /cgroup/test2
> > +
> > +- Set weights of group test1 and test2
> > +	echo 1000 > /cgroup/test1/io.ioprio
> > +	echo 500 > /cgroup/test2/io.ioprio
> 
>   Here seems should be /cgroup/test2/io.weight
> 

Forgot to update these lines while switching from the notion of ioprio
to weight for the groups. Will do that next time.

Thanks
Vivek

> > +
> > +- Create two same size files (say 512MB each) on same disk (file1, file2) and
> > +  launch two dd threads in different cgroup to read those files. Make sure
> > +  right io scheduler is being used for the block device where files are
> > +  present (the one you compiled in hierarchical mode).
> > +
> > +	echo 1 > /proc/sys/vm/drop_caches
> > +
> > +	dd if=/mnt/lv0/zerofile1 of=/dev/null &
> > +	echo $! > /cgroup/test1/tasks
> > +	cat /cgroup/test1/tasks
> > +
> > +	dd if=/mnt/lv0/zerofile2 of=/dev/null &
> > +	echo $! > /cgroup/test2/tasks
> > +	cat /cgroup/test2/tasks
> > +
> > +- At macro level, first dd should finish first. To get more precise data, keep
> > +  on looking at (with the help of script), at io.disk_time and io.disk_sectors
> > +  files of both test1 and test2 groups. This will tell how much disk time
> > +  (in milli seconds), each group got and how many secotors each group
> > +  dispatched to the disk. We provide fairness in terms of disk time, so
> > +  ideally io.disk_time of cgroups should be in proportion to the weight.
> > +  (It is hard to achieve though :-)).
> 
> -- 
> Regards
> Gui Jianfeng
