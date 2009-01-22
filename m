From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH] Reset pos in cr_write_pids()
Date: Wed, 21 Jan 2009 21:19:32 -0800
Message-ID: <20090122051932.GA20487@us.ibm.com>
References: <20090122051407.GA20039@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090122051407.GA20039-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: orenl-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Fix typo in Oren's address


---
Oren,

Noticed this while reviewing the code in [v12] branch of your git tree.

---
From: Sukadev Bhattiprolu <suka@sukaT61.(none)>
Date: Wed, 21 Jan 2009 21:10:34 -0800
Subject: [PATCH] Reset pos in cr_write_pids()

If the number of tasks exceed CR_HDR_PIDS_CHUNK, pos must be reset
for a second iteration in the outer loop.
---
 checkpoint/checkpoint.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index fbcd9eb..3136850 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -297,7 +297,7 @@ static int cr_write_pids(struct cr_ctx *ctx)
 	struct pid_namespace *ns;
 	struct task_struct *task;
 	struct task_struct **tasks_arr;
-	int tasks_nr, n, ret = 0, pos = 0;
+	int tasks_nr, n, ret = 0, pos;
 
 	ns = ctx->root_nsproxy->pid_ns;
 	tasks_arr = ctx->tasks_arr;
@@ -306,6 +306,7 @@ static int cr_write_pids(struct cr_ctx *ctx)
 	hh = cr_hbuf_get(ctx, sizeof(*hh) * CR_HDR_PIDS_CHUNK);
 
 	while (tasks_nr > 0) {
+		pos = 0;
 		rcu_read_lock();
 		for (n = min(tasks_nr, CR_HDR_PIDS_CHUNK); n; n--) {
 			task = tasks_arr[pos];
-- 
1.5.4.3
