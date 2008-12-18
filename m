From: Gowrishankar M <gowrishankar.m-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 2/5] pid: use namespaced iteration on processes while using
	sysrq
Date: Thu, 18 Dec 2008 22:12:30 +0530
Message-ID: <1229618553-6348-3-git-send-email-gowrishankar.m@linux.vnet.ibm.com>
References: <1229618553-6348-1-git-send-email-gowrishankar.m@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1229618553-6348-1-git-send-email-gowrishankar.m-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Cc: Dave <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Eric <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Sukadev <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Balbir <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

From: Gowrishankar M <gomuthuk-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>

At present, while signalling processes using sysrq, process iteration
goes beyond current PID namespace.

Below patch uses one of the proposed namespace iteration macros to fix
the boundary.

Signed-off-by: Gowrishankar M <gowrishankar.m-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 drivers/char/sysrq.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/char/sysrq.c b/drivers/char/sysrq.c
index ce0d9da..adca5da 100644
--- a/drivers/char/sysrq.c
+++ b/drivers/char/sysrq.c
@@ -13,6 +13,7 @@
  */
 
 #include <linux/sched.h>
+#include <linux/pid_namespace.h>
 #include <linux/interrupt.h>
 #include <linux/mm.h>
 #include <linux/fs.h>
@@ -293,8 +294,8 @@ static void send_sig_all(int sig)
 {
 	struct task_struct *p;
 
-	for_each_process(p) {
-		if (p->mm && !is_global_init(p))
+	for_each_process_in_ns(p, current->nsproxy->pid_ns) {
+		if (p->mm && !is_container_init(p))
 			/* Not swapper, init nor kernel thread */
 			force_sig(sig, p);
 	}
-- 
1.5.5.1
