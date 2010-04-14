From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [RFC][PATCH 2/6][usercr] Remove flags parameter to cr_checkpoint()
Date: Tue, 13 Apr 2010 17:52:21 -0700
Message-ID: <20100414005221.GB13532@us.ibm.com>
References: <20100414004927.GA13012@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100414004927.GA13012-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org


From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date: Tue, 13 Apr 2010 15:28:55 -0700
Subject: [RFC][PATCH 2/6][usercr] Remove flags parameter to cr_checkpoint()

For consistency with cr_restart(), remove 'flags' parameter to cr_checkpoint().
Given that we pass in the 'struct cr_checkpoint_args' the flags parameter is
anyway redundant.

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 checkpoint-main.c |    6 +-----
 checkpoint.c      |    7 +++++--
 cr_checkpoint.h   |    4 +---
 3 files changed, 7 insertions(+), 10 deletions(-)

diff --git a/checkpoint-main.c b/checkpoint-main.c
index 48c54f6..b8f96a7 100644
--- a/checkpoint-main.c
+++ b/checkpoint-main.c
@@ -147,7 +147,6 @@ int main(int argc, char *argv[])
 {
 	int ret;
 	struct cr_checkpoint_args args;
-	unsigned long flags = 0;
 	pid_t pid;
 
 	global_uerrfd = fileno(stderr);
@@ -165,9 +164,6 @@ int main(int argc, char *argv[])
 		exit(1);
 	}
 
-	if (!args.container)
-		flags |= CHECKPOINT_SUBTREE;
-
-	ret = cr_checkpoint(pid, flags, &args);
+	ret = cr_checkpoint(pid, &args);
 	return (ret > 0) ? 0 : 1;
 }
diff --git a/checkpoint.c b/checkpoint.c
index 5472bfe..90d4d35 100644
--- a/checkpoint.c
+++ b/checkpoint.c
@@ -31,10 +31,10 @@ inline static int checkpoint(pid_t pid, int fd, unsigned long flags, int logfd)
 	return syscall(__NR_checkpoint, pid, fd, flags, logfd);
 }
 
-int cr_checkpoint(int pid, unsigned long flags,
-				struct cr_checkpoint_args *args)
+int cr_checkpoint(int pid, struct cr_checkpoint_args *args)
 {
 	int ret;
+	unsigned long flags;
 
 	global_uerrfd = args->uerrfd;
 
@@ -46,6 +46,9 @@ int cr_checkpoint(int pid, unsigned long flags,
 	if (args->logfd < 0)
 		args->logfd = CHECKPOINT_FD_NONE;
 
+	if (!args->container)
+		flags |= CHECKPOINT_SUBTREE;
+
 	ret = checkpoint(pid, args->outfd, flags, args->logfd);
 
 	if (ret < 0) {
diff --git a/cr_checkpoint.h b/cr_checkpoint.h
index 81fa2c2..37f9f2a 100644
--- a/cr_checkpoint.h
+++ b/cr_checkpoint.h
@@ -39,7 +39,5 @@ struct cr_restart_args {
  */
 extern int global_send_sigint;
 
-extern int cr_checkpoint(int pid, unsigned long flags,
-				struct cr_checkpoint_args *args);
-
+extern int cr_checkpoint(int pid, struct cr_checkpoint_args *args);
 extern int cr_restart(struct cr_restart_args *args);
-- 
1.6.6.1
