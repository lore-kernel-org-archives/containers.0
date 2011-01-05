From: Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>
Subject: Re: + memcg-fix-deadlock-between-cpuset-and-memcg.patch added to
	-mm tree
Date: Wed, 5 Jan 2011 16:51:34 +0900
Message-ID: <20110105165134.46d868f4.nishimura__28283.4395803095$1294214345$gmane$org@mxp.nes.nec.co.jp>
References: <201101032131.p03LVTp8029638@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <201101032131.p03LVTp8029638-AB4EexQrvXRQetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
Cc: bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, linux-mm <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>, miaox-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, kamezawa.hiroyuki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

(resend with adding Cc: containers and linux-mm)

Hi, Andrew.

Thank you for picking up this patch.

But this version has a small race problem. This is a fix-up patch.

===
From: Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>

We must clear "mc.moving_task" before waking up all waiters at the end of
task migration.

Otherwise, there can be a small race like:

        mem_cgroup_clear_mc()        |    mem_cgroup_wait_acct_move()
    ---------------------------------+-----------------------------------
          __mem_cgroup_clear_mc()    |
            wake_up_all()            |
                                     |    prepare_to_wait()
                                     |    if (mc.moving_task) -> true
                                     |      schedule()
                                     |      -> noone wakes it up.
          mc.moving_task = NULL      |

Signed-off-by: Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>
---
 mm/memcontrol.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index b108b30..61678be 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4714,12 +4714,16 @@ static void mem_cgroup_clear_mc(void)
 {
 	struct mem_cgroup *from = mc.from;
 
+	/*
+	 * we must clear moving_task before waking up waiters at the end of
+	 * task migration.
+	 */
+	mc.moving_task = NULL;
 	__mem_cgroup_clear_mc();
 	spin_lock(&mc.lock);
 	mc.from = NULL;
 	mc.to = NULL;
 	spin_unlock(&mc.lock);
-	mc.moving_task = NULL;
 	mem_cgroup_end_move(from);
 }
 
-- 
1.7.1
