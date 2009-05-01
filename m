From: Divyesh Shah <dpshah-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC] IO Controller
Date: Thu, 30 Apr 2009 18:25:37 -0700
Message-ID: <49FA4F91.204__26895.4620966271$1241141322$gmane$org@google.com>
References: <1236823015-4183-1-git-send-email-vgoyal@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1236823015-4183-1-git-send-email-vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
Cc: oz-kernel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, arozansk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, fernando-w0OK63jvRlAuJ+9fw/WgBHgSJqDPrsil@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

Vivek Goyal wrote:
> Hi All,
> 
> Here is another posting for IO controller patches. Last time I had posted
> RFC patches for an IO controller which did bio control per cgroup.
> 
> http://lkml.org/lkml/2008/11/6/227
> 
> One of the takeaway from the discussion in this thread was that let us
> implement a common layer which contains the proportional weight scheduling
> code which can be shared by all the IO schedulers.
> 
> Implementing IO controller will not cover the devices which don't use
> IO schedulers but it should cover the common case.
> 
> There were more discussions regarding 2 level vs 1 level IO control at
> following link.
> 
> https://lists.linux-foundation.org/pipermail/containers/2009-January/015402.html
> 
> So in the mean time we took the discussion off the list and spent time on
> making the 1 level control apporoach work where majority of the proportional
> weight control is shared by the four schedulers instead of each one having
> to replicate the code. We make use of BFQ code for fair queuing as posted
> by Paolo and Fabio here.
> 
> http://lkml.org/lkml/2008/11/11/148
> 
> Details about design and howto have been put in documentation patch.
> 
> I have done very basic testing of running 2 or 3 "dd" threads in different
> cgroups. Wanted to get the patchset out for feedback/review before we dive
> into more bug fixing, benchmarking, optimizations etc.
> 
> Your feedback/comments are welcome.
> 
> Patch series contains 10 patches. It should be compilable and bootable after
> every patch. Intial 2 patches implement flat fair queuing (no cgroup
> support) and make cfq to use that. Later patches introduce hierarchical
> fair queuing support in elevator layer and modify other IO schdulers to use
> that.
> 
> Thanks
> Vivek

Hi Vivek,
   While testing these patches along with the bio-cgroup patches I noticed that for the case of 2 buffered writers (dd) with different weights, one of them would be able to use up a very large timeslice (I've seen upto 500ms) when the other queue is empty and not be accounted for it. This is due to the check in cfq_dispatch_requests() where  a given cgroup can empty its entire queue (100 IOs or more) within its timeslice and have them sit in the dispatch queue ready for the disk driver to pick up. Moreover, this huge timeslice is not accounted for as this cgroup is charged only for the length of the intended timeslice and not the actual time taken.
  The following patch fixes this by not optimizing on the single busy queue fact inside cfq_dispatch_requests. Note that this does not hurt throughput in any sense but just causes more IOs to be dispatched only when the drive is ready for them thus leading to better accounting too.

Fix bug where a given ioq can run through all its requests at once.

Signed-off-by: Divyesh Shah <dpshah-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
---
diff --git a/2.6.26/block/cfq-iosched.c b/2.6.26/block/cfq-iosched.c
index 5a275a2..c0199a6 100644
--- a/2.6.26/block/cfq-iosched.c
+++ b/2.6.26/block/cfq-iosched.c
@@ -848,8 +848,7 @@ static int cfq_dispatch_requests(struct request_queue *q, int force)
		if (cfq_class_idle(cfqq))
			max_dispatch = 1;

-		if (elv_ioq_nr_dispatched(cfqq->ioq) >= max_dispatch &&
-			elv_nr_busy_ioq(q->elevator) > 1)
+		if (elv_ioq_nr_dispatched(cfqq->ioq) >= max_dispatch)
			break;

		if (cfqd->sync_flight && !cfq_cfqq_sync(cfqq))
