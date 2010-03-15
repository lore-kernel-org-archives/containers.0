From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [PATCH] c/r: fix lockdep complaint in restore_obj_files()
Date: Mon, 15 Mar 2010 17:04:30 -0400
Message-ID: <1268687070-20066-1-git-send-email-orenl@cs.columbia.edu>
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
Cc: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

"""
  ... the pthread1 test triggers a lockdep warning
  "BUG: spinlock wrong CPU on CPU#4, pthread1/25906"
  ...
"""

(Reported by Nathan Lynch)

This patch moves put_files_struct() outside the spinlock.

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 checkpoint/files.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/checkpoint/files.c b/checkpoint/files.c
index 2859cf9..55c5eb3 100644
--- a/checkpoint/files.c
+++ b/checkpoint/files.c
@@ -921,11 +921,15 @@ int restore_obj_file_table(struct ckpt_ctx *ctx, int files_objref)
 		return PTR_ERR(files);
 
 	if (files != current->files) {
+		struct files_struct *prev;
+
 		task_lock(current);
-		put_files_struct(current->files);
+		prev = current->files;
 		current->files = files;
-		task_unlock(current);
 		atomic_inc(&files->count);
+		task_unlock(current);
+
+		put_files_struct(prev);
 	}
 
 	return 0;
-- 
1.6.3.3
