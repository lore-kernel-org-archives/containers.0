From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 1/2] Fix app_checkpoint() return code
Date: Tue, 30 Mar 2010 23:54:43 -0700
Message-ID: <20100331065443.GA21065@us.ibm.com>
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
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org


From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date: Tue, 30 Mar 2010 18:59:10 -0700
Subject: [PATCH 1/2] Fix app_checkpoint() return code

Have app_checkpoint() return the return value from the system call
so callers find some useful information. Have main() can convert the
return value into a suitable exit status.

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 checkpoint-main.c |    4 +++-
 checkpoint.c      |    2 +-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/checkpoint-main.c b/checkpoint-main.c
index f6faa32..bac65cc 100644
--- a/checkpoint-main.c
+++ b/checkpoint-main.c
@@ -145,6 +145,7 @@ static void parse_args(struct app_checkpoint_args *args, int argc, char *argv[])
 
 int main(int argc, char *argv[])
 {
+	int ret;
 	struct app_checkpoint_args args;
 	unsigned long flags = 0;
 	pid_t pid;
@@ -167,5 +168,6 @@ int main(int argc, char *argv[])
 	if (!args.container)
 		flags |= CHECKPOINT_SUBTREE;
 
-	return app_checkpoint(pid, flags, &args);
+	ret = app_checkpoint(pid, flags, &args);
+	return (ret > 0) ? 0 : 1;
 }
diff --git a/checkpoint.c b/checkpoint.c
index e3a1ce8..e0290c9 100644
--- a/checkpoint.c
+++ b/checkpoint.c
@@ -55,5 +55,5 @@ int app_checkpoint(int pid, unsigned long flags,
 		ckpt_err("checkpoint id %d\n", ret);
 	}
 
-	return (ret > 0 ? 0 : 1);
+	return ret;
 }
-- 
1.6.6.1
