From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] io-controller: Preempt a non-rt queue if a rt ioq is
	present in ancestor or sibling groups
Date: Tue, 23 Jun 2009 10:02:50 -0400
Message-ID: <20090623140250.GA4262__6167.31626582823$1245766188$gmane$org@redhat.com>
References: <1245443858-8487-1-git-send-email-vgoyal@redhat.com>
	<1245443858-8487-21-git-send-email-vgoyal@redhat.com>
	<4A3F3648.7080007@cn.fujitsu.com>
	<20090622172123.GE15600@redhat.com>
	<4A4079B8.4020402@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4A4079B8.4020402-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
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
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Jun 23, 2009 at 02:44:08PM +0800, Gui Jianfeng wrote:
> Vivek Goyal wrote:
> > On Mon, Jun 22, 2009 at 03:44:08PM +0800, Gui Jianfeng wrote:
> >> Preempt the ongoing non-rt ioq if there are rt ioqs waiting for dispatching
> >> in ancestor or sibling groups. It will give other group's rt ioq an chance 
> >> to dispatch ASAP.
> >>
> > 
> > Hi Gui,
> > 
> > Will new preempton logic of traversing up the hiearchy so that both new
> > queue and old queue are at same level to take a preemption decision not
> > take care of above scenario?
> 
> Hi Vivek,
> 
> Would you explain a bit what do you mean about "both new queue and old queue 
> are at same level to take a preemption decision". I don't understand it well.
> 

Consider following hierarchy.

			root
			/ | 
		       A  1   
		       | 
		       2 
In the above diagram, A is the group and "1" and "2" are two io queues 
associated with tasks.

Now assume that queue "1" is being served and queue "2" gets backlogged.
Should queue 2 preempt queue 1 now?

To take that decision, we need to do the comparision between type of
entity of group A and queue 1 (That is at the same level or IOW, the
entities in question have the same parent). If group A is of class RT and
queue 1 is of type BE then queue 2 should preempt queue 1 otherwise not.

Hence in hierarchical setups to take a preemption decision, comparison
should be done at same level.

> > 
> > Please have a look at bfq_find_matching_entity().
> > 
> > At the same time we probably don't want to preempt the non-rt queue
> > with an RT queue in sibling group until and unless sibling group is an
> > RT group.
> > 
> > 		root
> > 		/  \
> > 	   BEgrpA  BEgrpB
> > 	      |     |	
> > 	  BEioq1   RTioq2
> > 
> > Above we got two BE group A and B and assume ioq in group A is being
> > served and then an RT request in group B comes. Because group B is an
> > BE class group, we should not preempt the queue in group A.
> 
>   Yes, i also have this concern. So, it does not allow non-rt group preempts
>   another group. I'll check whether there is a way to address this issue.
> 

So here also assume ioq1 is being served and ioq2 gets backlogged. To
decide whether ioq2 should preempt ioq1 or not, one needs to go up the 
hiearchy till two paths share the parent. That means one needs to go up
at the BEgrpA and BEgrpB level where they have common parent "root". Now
both the groups are of class BE hence ioq2 should not preempt ioq1.

Hope it helps.

Thanks
Vivek
