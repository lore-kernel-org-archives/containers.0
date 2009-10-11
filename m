From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: Performance numbers with IO throttling patches (Was: Re: IO
	scheduler based IO controller V10)
Date: Sun, 11 Oct 2009 08:32:19 -0400
Message-ID: <20091011123219.GA3832@redhat.com>
References: <1253820332-10246-1-git-send-email-vgoyal@redhat.com>
	<20090924143315.781cd0ac.akpm@linux-foundation.org>
	<20091010195316.GB16510@redhat.com> <20091010222728.GA30943@linux>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20091010222728.GA30943@linux>
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
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, jmarchan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

On Sun, Oct 11, 2009 at 12:27:30AM +0200, Andrea Righi wrote:

[..]
> > 
> > - Andrea, can you please also run similar tests to see if you see same
> >   results or not. This is to rule out any testing methodology errors or
> >   scripting bugs. :-). I also have collected the snapshot of some cgroup
> >   files like bandwidth-max, throttlecnt, and stats. Let me know if you want
> >   those to see what is happenig here. 
> 
> Sure, I'll do some tests ASAP. Another interesting test would be to set
> a blockio.iops-max limit also for the sequential readers' cgroup, to be
> sure we're not touching some iops physical disk limit.
> 
> Could you post all the options you used with fio, so I can repeat some
> tests as similar as possible to yours?
> 

I will respond to rest of the points later after some testing with iops-max
rules. In the mean time here are my fio options so that you can try to
replicate the tests.

I am simply copying pasting from my script. I have written my own program
"semwait" so that two different instances of fio can synchronize on an
external semaphore. Generally all the jobs go in single fio files but here
we need to put two fio instances in two different cgroups. It is important
that two fio jobs are synchronized and start at the same time after laying
out files. (Becomes primarilly useful in write testing. Reads are fine 
generally onces the files have been laid out).

Sequential readers
------------------
fio_args="--rw=read --bs=4K --size=2G --runtime=30 --numjobs=$nr_jobs --direct=1"
fio $fio_args --name=$jobname --directory=/mnt/$blockdev/fio --exec_prerun="'/usr/local/bin/semwait fiocgroup'" >> $outputdir/$outputfile &

Random Reader
-------------
fio_args="--rw=randread --bs=4K --size=1G --runtime=30 --direct=1 --numjobs=$nr_jobs"
fio $fio_args --name=$jobname --directory=/mnt/$blockdev/fio --exec_prerun="'/usr/local/bin/semwait fiocgroup'" >> $outputdir/$outputfile &

Random Writer
-------------
fio_args="--rw=randwrite --bs=64K --size=2G --runtime=30 --numjobs=$nr_jobs1 --ioengine=libaio --iodepth=4 --direct=1"

fio $fio_args --name=$jobname --directory=/mnt/$blockdev/fio --exec_prerun="'/usr/local/bin/semwait fiocgroup'" >> $outputdir/$outputfile &

Thanks
Vivek
