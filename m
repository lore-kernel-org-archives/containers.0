From: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Subject: Re: [BUG] cpu controller can't provide fair CPU time for each group
Date: Wed, 11 Nov 2009 11:07:28 +0100
Message-ID: <1257934048.23203.76.camel__7450.98056872866$1257934122$gmane$org@twins>
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
> > Someone needs to fix that if they really care.
> 
> To be honest, I don't have any good idea because I'm not familiar with
> schduler's code. 

You could possible try something like the below, its rather gross but
might maybe work,.. has other issues though.


---
 kernel/sched.c |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/kernel/sched.c b/kernel/sched.c
index 91642c1..65629a3 100644
--- a/kernel/sched.c
+++ b/kernel/sched.c
@@ -1614,7 +1614,7 @@ static void update_group_shares_cpu(struct task_group *tg, int cpu,
  */
 static int tg_shares_up(struct task_group *tg, void *data)
 {
-	unsigned long weight, rq_weight = 0, shares = 0;
+	unsigned long weight, rq_weight = 0, sum_weight = 0, shares = 0;
 	unsigned long *usd_rq_weight;
 	struct sched_domain *sd = data;
 	unsigned long flags;
@@ -1630,6 +1630,7 @@ static int tg_shares_up(struct task_group *tg, void *data)
 		weight = tg->cfs_rq[i]->load.weight;
 		usd_rq_weight[i] = weight;
 
+		rq_weight += weight;
 		/*
 		 * If there are currently no tasks on the cpu pretend there
 		 * is one of average load so that when a new task gets to
@@ -1638,10 +1639,14 @@ static int tg_shares_up(struct task_group *tg, void *data)
 		if (!weight)
 			weight = NICE_0_LOAD;
 
-		rq_weight += weight;
+		sum_weight += weight;
+
 		shares += tg->cfs_rq[i]->shares;
 	}
 
+	if (!rq_weight)
+		rq_weight = sum_weight;
+
 	if ((!shares && rq_weight) || shares > tg->shares)
 		shares = tg->shares;
