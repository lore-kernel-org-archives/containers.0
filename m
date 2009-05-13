From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/1] mktree: long is bigger on 64-bit
Date: Tue, 12 May 2009 22:08:30 -0500
Message-ID: <20090513030830.GA11265@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

mktree's hash function assumes that long is 32 bits.  Fix.

Signed-off-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 mktree.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/mktree.c b/mktree.c
index 7a8cecc..0195974 100644
--- a/mktree.c
+++ b/mktree.c
@@ -724,6 +724,7 @@ static int ckpt_make_tree(struct ckpt_ctx *ctx, struct task *task)
 	struct task *child;
 	struct pid_swap swap;
 	pid_t newpid;
+	int status;
 	int ret;
 
 	ckpt_dbg("pid %d: pid %d sid %d parent %d\n",
@@ -765,7 +766,7 @@ static int ckpt_make_tree(struct ckpt_ctx *ctx, struct task *task)
 	/* 3rd pass: bring out your deads ... */
 	for (child = task->children; child; child = child->next_sib) {
 		if (child->flags & TASK_DEAD) {
-			ret = waitpid(child->rpid, NULL, 0);
+			ret = waitpid(child->rpid, &status, 0);
 			if (ret < 0) {
 				perror("waitpid");
 				return -1;
@@ -1291,7 +1292,8 @@ static void hash_exit(struct ckpt_ctx *ctx)
 static inline int hash_func(long key)
 {
 	unsigned long hash = key * GOLDEN_RATIO_PRIME_32;
-	return (hash >> (32 - HASH_BITS));
+	//return (hash >> (32 - HASH_BITS));
+	return (hash >> (sizeof(long)*8 - HASH_BITS));
 }
 
 static int hash_insert(struct ckpt_ctx *ctx, long key, void *data)
-- 
1.6.1.1
