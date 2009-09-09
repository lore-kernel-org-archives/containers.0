From: Rik van Riel <riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 26/23] io-controller: fix writer preemption with in a group
Date: Wed, 09 Sep 2009 00:59:30 -0400
Message-ID: <4AA73632.2020309__46444.0151387409$1252472567$gmane$org@redhat.com>
References: <1251495072-7780-1-git-send-email-vgoyal@redhat.com>
	<20090908222835.GD3558@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090908222835.GD3558-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, jmarchan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

Vivek Goyal wrote:
> o Found another issue during testing. Consider following hierarchy.
> 
> 			root
> 			/ \
> 		       R1  G1
> 			  /\
> 			 R2 W
> 
>   Generally in CFQ when readers and writers are running, reader immediately
>   preempts writers and hence reader gets the better bandwidth. In case of
>   hierarchical setup, it becomes little more tricky. In above diagram, G1
>   is a group and R1, R2 are readers and W is writer tasks.
> 
>   Now assume W runs and then R1 runs and then R2 runs. After R2 has used its
>   time slice, if R1 is schedule in, after couple of ms, R1 will get backlogged
>   again in group G1, (streaming reader). But it will not preempt R1 as R1 is
>   also a reader and also because preemption across group is not allowed for
>   isolation reasons. Hence R2 will get backlogged in G1 and will get a 
>   vdisktime much higher than W. So when G2 gets scheduled again, W will get
>   to run its full slice length despite the fact R2 is queue on same service
>   tree.
> 
>   The core issue here is that apart from regular preemptions (preemption 
>   across classes), CFQ also has this special notion of preemption with-in
>   class and that can lead to issues active task is running in a differnt
>   group than where new queue gets backlogged.
> 
>   To solve the issue keep a track of this event (I am calling it late
>   preemption). When a group becomes eligible to run again, if late_preemption
>   is set, check if there are sync readers backlogged, and if yes, expire the
>   writer after one round of dispatch.
> 
>   This solves the issue of reader not getting enough bandwidth in hierarchical
>   setups.
> 
> Signed-off-by: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

Conceptually a nice solution.  The code gets a little tricky,
but I guess any code dealing with these situations would end
up that way :)

Acked-by: Rik van Riel <riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

-- 
All rights reversed.
