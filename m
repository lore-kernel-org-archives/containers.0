From: Konstantin Khlebnikov <khlebnikov-XoJtRXgx1JseBXzfvpsJ4g@public.gmane.org>
Subject: [PATCH RFC 0/3] sched/fair: cpu time reserves for cgroups
Date: Mon, 16 May 2016 12:36:19 +0300
Message-ID: <146339085068.25295.7687045977863852568.stgit__1948.02804985574$1463391890$gmane$org@buzz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

This feature allows to change cpu cgroup weight for a limited time.

Cgroup interface:
cpu.cfs_reserve_us      - reserved time for each cpu.cfs_period_us
cpu.cfs_reserve_shares  - group weight during reserved time

While cfs group consumes reserved cpu time it has different weight,
thus it gets different vruntime penalty for that execution.

        ^ weight
        |
        |
reserve |
shares  -------*
        |      |
        |      |
        |      |
shares  -      *-----------------*
        |                        |
        |                        |
        0------|-----------------|-----------> time
               reserve           quota

Reserve can work as a "low limit": boost weight for "guaranteed" time,
and as a "high limit": give normal weight for a limited time and allow
utilize cpu when nobody else needs it.

Sample setup:

level   | shares      reserve shares
--------+----------------------------
high    | 1024*16     1024*16*16
normal  | 1024        1024*16
low     | 1024/16     1024

In this way cgroups are devided into three levels.
During reserved time they are promoted to the next level.

---

Konstantin Khlebnikov (3):
      sched/fair: call __refill_cfs_bandwidth_runtime only for finite quota
      sched/fair: copy taskgroup shares to each cfs_rq
      sched/fair: pulse-weight modulation controller for cpu cgroup

 kernel/sched/core.c  |   96 +++++++++++++++++++++++++++++++++++++++++++-----
 kernel/sched/fair.c  |  101 ++++++++++++++++++++++++++++++++++++++------------
 kernel/sched/sched.h |    5 ++
 3 files changed, 168 insertions(+), 34 deletions(-)
