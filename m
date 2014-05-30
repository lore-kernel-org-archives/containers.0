From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH RFC RESEND 00/14] New version of the BFQ I/O Scheduler
Date: Fri, 30 May 2014 13:31:46 -0400
Message-ID: <20140530173146.GG16605@redhat.com>
References: <1401194558-5283-1-git-send-email-paolo.valente@unimore.it>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1401194558-5283-1-git-send-email-paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: paolo <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
Cc: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Fabio Checconi <fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Arianna Avanzini <avanzini.arianna-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paolo Valente <posta_paolo-whZMOeQn8C0@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, May 27, 2014 at 02:42:24PM +0200, paolo wrote:
> From: Paolo Valente <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
> 
> [Re-posting, previous attempt seems to have partially failed]
> 
> Hi,
> this patchset introduces the last version of BFQ, a proportional-share
> storage-I/O scheduler. BFQ also supports hierarchical scheduling with
> a cgroups interface. The first version of BFQ was submitted a few
> years ago [1]. It is denoted as v0 in the patches, to distinguish it
> from the version I am submitting now, v7r4. In particular, the first
> four patches introduce BFQ-v0, whereas the remaining patches turn it
> progressively into BFQ-v7r4. Here are some nice features of this last
> version.
> 
> Low latency for interactive applications
> 
> According to our results, regardless of the actual background
> workload, for interactive tasks the storage device is virtually as
> responsive as if it was idle. For example, even if one or more of the
> following background workloads are being executed:
> - one or more large files are being read or written,
> - a tree of source files is being compiled,
> - one or more virtual machines are performing I/O,
> - a software update is in progress,
> - indexing daemons are scanning filesystems and updating their
>   databases,
> starting an application or loading a file from within an application
> takes about the same time as if the storage device was idle. As a
> comparison, with CFQ, NOOP or DEADLINE, and in the same conditions,
> applications experience high latencies, or even become unresponsive
> until the background workload terminates (also on SSDs).

So how do you achieve it? IOW, how do you figure out something is
interactive and just give it priority and almost stop other. What happens
to notion of fairness in that case.

And if there is a way to figure out interactive applications, then even
in CFQ, one should be able to easily put these queues in the beginning of
service tree so that they get served first and achieve better experience?

And in general that would be a desirable thing to do. So why not modify
CFQ.

> 
> Low latency for soft real-time applications
> 
> Also soft real-time applications, such as audio and video
> players/streamers, enjoy low latency and drop rate, regardless of the
> storage-device background workload. As a consequence, these
> applications do not suffer from almost any glitch due to the
> background workload.

Again, how do you achieve it?

> 
> High throughput
> 
> On hard disks, BFQ achieves up to 30% higher throughput than CFQ,

For what workload? 

> and
> up to 150% higher throughput than DEADLINE and NOOP,

Is this true with buffered write workload also? I think these % will
be very dependent on IO pattern.

Again I would like to know how did you achieve such a high throughput
when compared to CFQ, Deadline, NOOP. One of the things which drops
throughput on rotational hard disk is non-sequential IO pattern and
CFQ already does that. So only way to achieve higher throughput will
be to accumulate more sequetial IO in the queue and then let that queue
run for longer and stop other IO from other queues. And that will mean
higher latencies for IO in other queues.

So on this rotation hard disk, how do you achieve higher throughput as
well as reduced latency.

> with half of the
> parallel workloads considered in our tests. With the rest of the
> workloads, and with all the workloads on flash-based devices, BFQ
> achieves instead about the same throughput as the other schedulers.
> 
> Strong fairness guarantees (already provided by BFQ-v0)
> 
> As for long-term guarantees, BFQ distributes the device throughput
> (and not just the device time) as desired to I/O-bound applications,

I think this is one key differece as comapred to CFQ. Fairness based
on bandwidth and not fairness based on time slice.

So if a process is doing large sequential IO and other is doing small
random IO, most of the disk time will be given to process doing small
random IOs. Is that more fair. I think that's one reason that CFQ was
switched to time based scheme. Provide time slices and after that
it is up to the application how much they can get out of disk in that
slice based on their IO pattern. At least in terms of fairness, that
sounds more fair to me.

I think this is one point which needs to be discussed that is it
a better idea to switch to bandwidth based fairness. Should we change
CFQ to achieve that or we need to introduce new IO scheduler for that.

> with any workload and regardless of the device parameters.
> 
> What allows BFQ to provide the above features is its accurate
> scheduling engine (patches 1-4), combined with a set of simple
> heuristics and improvements (patches 5-14). 

This is very hard to understand. This puzzle need to be broken down
into small pieces and explained in simple design terms so that even
5 years down the line I can explain why BFQ was better.

Thanks
Vivek
