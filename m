From: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Subject: Re: [BUG] cpu controller can't provide fair CPU time for each group
Date: Wed, 11 Nov 2009 08:20:07 +0100
Message-ID: <1257924007.23203.18.camel__15270.6227767796$1257924076$gmane$org@twins>
References: <4AEF94E8.3030403@cn.fujitsu.com> <1257846518.4648.18.camel@twins>
	<20091111134910.5F42.E1E9C6FF@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091111134910.5F42.E1E9C6FF-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Yasunori Goto <y-goto-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Linux-Kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Miao Xie <miaox-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, 2009-11-11 at 15:21 +0900, Yasunori Goto wrote:

> When users use cpuset/cpu affinity, then they would like to controll cpu affinity.
> Not CPU time.

What are people using affinity for? The only use of affinity is to
restrict or disable the load-balancer. Don't complain the load-balancer
doesn't work when you're taking active steps to hinder its work.

If you don't want things load-balanced, turn it off, if you want the
load-balancer to work on smaller groups of cpus, use cpusets.

Anyway, I said there needs to be done something because the interaction
between cpusets and the cpu-controller is utter crap, they never should
have been separated like they are.

> To be honest, I don't have any good idea because I'm not familiar with
> schduler's code. But I have one question.
> 
> 
> 1618 static int tg_shares_up(struct task_group *tg, void *data)
> 1619 {
> 1620         unsigned long weight, rq_weight = 0, shares = 0;
> 
> (snip)
> 
> 1632         for_each_cpu(i, sched_domain_span(sd)) {
> 1633                 weight = tg->cfs_rq[i]->load.weight;
> 1634                 usd->rq_weight[i] = weight;
> 1635 
> 1636                 /*
> 1637                  * If there are currently no tasks on the cpu pretend there
> 1638                  * is one of average load so that when a new task gets to
> 1639                  * run here it will not get delayed by group starvation.
> 1640                  */
> 1641                 if (!weight)
> 1642                         weight = NICE_0_LOAD; ---------(*)
> 
> I heard from test team when (*) was removed, 1) didn't occur.
> 
> The comment said (*) is to avoid starvation condition.
> However, I don't understand why NICE_0_LOAD must be specified.
> Could you tell me why small value (like 2 or 3) is not used for (*)?
> What is side effect? 

Exactly what the comment says, it will get delayed because the group
won't get scheduled on that cpu until all the group weights get
re-adjusted again, which can be much longer than the typical runtimes of
the workload in question.

Regular weights are NICE_0_LOAD, if you stick a 3 next to that I'll not
get ran much -> starvation.
