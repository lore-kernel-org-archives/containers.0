From: Fabio Checconi <fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 01/10] Documentation
Date: Thu, 12 Mar 2009 15:48:42 +0100
Message-ID: <20090312144842.GS12361@gandalf.sssup.it>
References: <1236823015-4183-1-git-send-email-vgoyal@redhat.com>
	<1236823015-4183-2-git-send-email-vgoyal@redhat.com>
	<20090312100054.GA8024@linux.vnet.ibm.com>
	<20090312140450.GE10919@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090312140450.GE10919-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
Cc: oz-kernel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, Dhaval Giani <dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, arozansk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, fernando-w0OK63jvRlAuJ+9fw/WgBHgSJqDPrsil@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

> From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> Date: Thu, Mar 12, 2009 10:04:50AM -0400
>
> On Thu, Mar 12, 2009 at 03:30:54PM +0530, Dhaval Giani wrote:
...
> > > +Some Test Results
> > > +=================
> > > +- Two dd in two cgroups with prio 0 and 4. Ran two "dd" in those cgroups.
> > > +
> > > +234179072 bytes (234 MB) copied, 10.1811 s, 23.0 MB/s
> > > +234179072 bytes (234 MB) copied, 12.6187 s, 18.6 MB/s
> > > +
> > > +- Three dd in three cgroups with prio 0, 4, 4.
> > > +
> > > +234179072 bytes (234 MB) copied, 13.7654 s, 17.0 MB/s
> > > +234179072 bytes (234 MB) copied, 19.476 s, 12.0 MB/s
> > > +234179072 bytes (234 MB) copied, 20.1858 s, 11.6 MB/s
> > 
> > Hi Vivek,
> > 
> > I would be interested in knowing if these are the results expected?
> > 
> 
> Hi Dhaval, 
> 
> Good question. Keeping current expectation in mind, yes these are expected
> results. To begin with, current expectations are that try to emulate
> cfq behavior and the kind of service differentiation we get between
> threads of different priority, same kind of service differentiation we
> should get from different cgroups.
>  
> Having said that, in theory a more accurate estimate should be amount 
> of actual disk time a queue/cgroup got. I have put a tracing message
> to keep track of total service received by a queue. If you run "blktrace"
> then you can see that. Ideally, total service received by two threads
> over a period of time should be in same proportion as their cgroup
> weights.
> 
> It will not be easy to achive it given the constraints we have got in
> terms of how to accurately we can account for disk time actually used by a
> queue in certain situations. So to begin with I am targetting that
> try to meet same kind of service differentation between cgroups as
> cfq provides between threads and then slowly refine it to see how
> close one can come to get accurate numbers in terms of "total_serivce"
> received by each queue.
> 

There is also another issue to consider; to achieve a proper weighted
distribution of ``service time'' (assuming that service time can be
attributed accurately) over any time window, we need also that the tasks
actually compete for disk service during this window.

For example, in the case above with three tasks, the highest weight task
terminates earlier than the other ones, so we have two time frames:
during the first one disk time is divided among all the three tasks
according to their weights, then the highest weight one terminates,
and disk time is divided (equally) among the remaining ones.
