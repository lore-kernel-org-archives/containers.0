From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH] c/r: make ckpt_debug() safe if called by dead tasks
Date: Thu, 24 Sep 2009 17:04:52 -0400
Message-ID: <1253826292-23452-1-git-send-email-orenl@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

One may not call task_pid_vnr() on dead tasks because they don't have
a valid ->nxproxy pointer. However, the ckpt_ctx cleanup may be called
by a dead task from do_exit(), in the case of zombie or "ghost" tasks.

This patch makes ckpt_debug() safe to call from dead tasks context, so
that debug printing from code called by ckpt_ctx_free() is cool.

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 include/linux/checkpoint.h |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index e00dd70..5294a96 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -334,7 +334,9 @@ extern unsigned long ckpt_debug_level;
 	do {								\
 		if (ckpt_debug_level & (level))				\
 			printk(KERN_DEBUG "[%d:%d:c/r:%s:%d] " fmt,	\
-				current->pid, task_pid_vnr(current),	\
+				current->pid,				\
+				current->nsproxy ?			\
+				task_pid_vnr(current) : -1,		\
 				__func__, __LINE__, ## args);		\
 	} while (0)
 
-- 
1.6.0.4
