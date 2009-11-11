From: Yasunori Goto <y-goto-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [BUG] cpu controller can't provide fair CPU time for each group
Date: Wed, 11 Nov 2009 15:21:33 +0900
Message-ID: <20091111134910.5F42.E1E9C6FF__25545.7564410337$1257920589$gmane$org@jp.fujitsu.com>
References: <4AEF94E8.3030403@cn.fujitsu.com> <1257846518.4648.18.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1257846518.4648.18.camel@twins>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Cc: containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Linux-Kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Miao Xie <miaox-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi.

I have concern about these issues.

> On Tue, 2009-11-03 at 11:26 +0900, Miao Xie wrote:
> > Hi, Peter.
> > 
> > I found two problems about cpu controller:
> > 1) cpu controller didn't provide fair CPU time to groups when the tasks
> >     attached into those groups were bound to the same logic CPU.
> > 2) cpu controller didn't provide fair CPU time to groups when shares of
> >     each group <= 2 * nr_cpus.
>   3) if you nest them too deep you're too going to see similar funnies.
> 
> Too sodding bad gcc messed up unsigned long long for LP64 mode, so we're
> stuck with 64bit fixed point math where otherwise we could have used
> 128bit things.
> 
> Also, I don't really care much about fairness vs affinity, if you're
> going to constrain the load-balancer and make his life impossible by
> using affinities you get to keep the pieces.


I think 1) differs from 2) and 3). 1) should be fixed at least.
Because 1) is hard to understand for normal users.

------
> >    a. create 2 cpu controller groups.
> >    b. attach a task into one group and 2 tasks into the other.
> >    c. bind three tasks to the same logic cpu.
> >             +--------+     +--------+
> >             | group1 |     | group2 |
> >             +--------+     +--------+
> >                 |              |
> >    CPU0      Task A      Task B & Task C

(snip)

> >    some time later, I found the the task in the group1 got the 35% CPU time not
> >    50% CPU time. It was very strange that this result against the expected.
------


Probably, if normal users start to use cpu controller, then they must make
same test by way of trial. They will find same results which differ from their
expectation in spite of SIMPLE test case.
Then, they will think cpu controller must have many bugs, and will never
use it.

When 2) and 3), I can explain users the reason like "It's due to accurate
error of internal calculation."
Beacause the test case is a bit fussy, and user will understand it.

However, I can't explain anything for 1), because it seems not fussy case.


> But you've got a point, since you can probably see the same issue (1)
> with cpusets, and that is because the whole cpu-controller vs cpusets
> thing was done wrong.

When users use cpuset/cpu affinity, then they would like to controll cpu affinity.
Not CPU time.

When users use cpu controller, they would like to controll cpu time, right?
However, the cpu time is far from their expectation. I think it is strange.

> 
> Someone needs to fix that if they really care.

To be honest, I don't have any good idea because I'm not familiar with
schduler's code. But I have one question.


1618 static int tg_shares_up(struct task_group *tg, void *data)
1619 {
1620         unsigned long weight, rq_weight = 0, shares = 0;

(snip)

1632         for_each_cpu(i, sched_domain_span(sd)) {
1633                 weight = tg->cfs_rq[i]->load.weight;
1634                 usd->rq_weight[i] = weight;
1635 
1636                 /*
1637                  * If there are currently no tasks on the cpu pretend there
1638                  * is one of average load so that when a new task gets to
1639                  * run here it will not get delayed by group starvation.
1640                  */
1641                 if (!weight)
1642                         weight = NICE_0_LOAD; ---------(*)

I heard from test team when (*) was removed, 1) didn't occur.

The comment said (*) is to avoid starvation condition.
However, I don't understand why NICE_0_LOAD must be specified.
Could you tell me why small value (like 2 or 3) is not used for (*)?
What is side effect?



Thanks.

-- 
Yasunori Goto 
