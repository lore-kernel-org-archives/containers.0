From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: IO scheduler based IO controller V10
Date: Fri, 25 Sep 2009 16:26:36 -0400
Message-ID: <20090925202636.GC15007__9412.13174160129$1253910486$gmane$org@redhat.com>
References: <1253820332-10246-1-git-send-email-vgoyal@redhat.com>
	<4ABC28DE.7050809@datenparkplatz.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4ABC28DE.7050809-7vBoImwI/YtIVYojq0lqJrNAH6kLmebB@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ulrich Lukas <stellplatz-nr.13a-7vBoImwI/YtIVYojq0lqJrNAH6kLmebB@public.gmane.org>
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, jmarchan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, Sep 25, 2009 at 04:20:14AM +0200, Ulrich Lukas wrote:
> Vivek Goyal wrote:
> > Notes:
> > - With vanilla CFQ, random writers can overwhelm a random reader.
> >   Bring down its throughput and bump up latencies significantly.
> 
> 
> IIRC, with vanilla CFQ, sequential writing can overwhelm random readers,
> too.
> 
> I'm basing this assumption on the observations I made on both OpenSuse
> 11.1 and Ubuntu 9.10 alpha6 which I described in my posting on LKML
> titled: "Poor desktop responsiveness with background I/O-operations" of
> 2009-09-20.
> (Message ID: 4AB59CBB.8090907-7vBoImwI/YtIVYojq0lqJrNAH6kLmebB@public.gmane.org)
> 
> 
> Thus, I'm posting this to show that your work is greatly appreciated,
> given the rather disappointig status quo of Linux's fairness when it
> comes to disk IO time.
> 
> I hope that your efforts lead to a change in performance of current
> userland applications, the sooner, the better.
> 
[Please don't remove people from original CC list. I am putting them back.]

Hi Ulrich,

I quicky went through that mail thread and I tried following on my
desktop.

##########################################
dd if=/home/vgoyal/4G-file of=/dev/null &
sleep 5
time firefox
# close firefox once gui pops up.
##########################################

It was taking close to 1 minute 30 seconds to launch firefox and dd got 
following.

4294967296 bytes (4.3 GB) copied, 100.602 s, 42.7 MB/s

(Results do vary across runs, especially if system is booted fresh. Don't
 know why...).


Then I tried putting both the applications in separate groups and assign
them weights 200 each.

##########################################
dd if=/home/vgoyal/4G-file of=/dev/null &
echo $! > /cgroup/io/test1/tasks
sleep 5
echo $$ > /cgroup/io/test2/tasks
time firefox
# close firefox once gui pops up.
##########################################

Now I firefox pops up in 27 seconds. So it cut down the time by 2/3.

4294967296 bytes (4.3 GB) copied, 84.6138 s, 50.8 MB/s

Notice that throughput of dd also improved.

I ran the block trace and noticed in many a cases firefox threads
immediately preempted the "dd". Probably because it was a file system
request. So in this case latency will arise from seek time.

In some other cases, threads had to wait for up to 100ms because dd was
not preempted. In this case latency will arise both from waiting on queue
as well as seek time.

With cgroup thing, We will run 100ms slice for the group in which firefox
is being launched and then give 100ms uninterrupted time slice to dd. So
it should cut down on number of seeks happening and that's why we probably
see this improvement.

So grouping can help in such cases. May be you can move your X session in
one group and launch the big IO in other group. Most likely you should
have better desktop experience without compromising on dd thread output.

Thanks
Vivek
