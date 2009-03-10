From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC][PATCH 00/11] track files for checkpointability
Date: Tue, 10 Mar 2009 10:57:02 -0500
Message-ID: <20090310105702.43eb1402__34577.9156698429$1236701288$gmane$org@thinkcentre.lan>
References: <20090305163857.0C18F3FD@kernel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090305163857.0C18F3FD@kernel>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Alexey-FOgKQjlUJ6BQetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Please consider this and a following patch.

From a0fb96aa41c4d360559013cfd7f32f07f449c1c4 Mon Sep 17 00:00:00 2001
From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Date: Mon, 9 Mar 2009 22:23:02 -0500
Subject: [PATCH] checkpoint: make files_deny_checkpointing print task name and pid

This lets the developer know *which* task performed an action that
prevents checkpoint.


Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
---
 fs/file.c                  |    2 +-
 fs/open.c                  |    2 +-
 include/linux/checkpoint.h |   13 +++++++------
 3 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/fs/file.c b/fs/file.c
index 0501af6..fcb2803 100644
--- a/fs/file.c
+++ b/fs/file.c
@@ -299,7 +299,7 @@ static void __scan_files_for_cr(struct files_struct *files)
 			continue;
 		if (cr_file_supported(f))
 			continue;
-		files_deny_checkpointing(files);
+		files_deny_checkpointing(current, files);
 	}
 }
 
diff --git a/fs/open.c b/fs/open.c
index 7f575b0..327ff5b 100644
--- a/fs/open.c
+++ b/fs/open.c
@@ -1018,7 +1018,7 @@ void fd_install(unsigned int fd, struct file *file)
 	struct fdtable *fdt;
 
 	if (!cr_file_supported(file))
-		files_deny_checkpointing(files);
+		files_deny_checkpointing(current, files);
 
 	spin_lock(&files->file_lock);
 	fdt = files_fdtable(files);
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index e77393f..27366ac 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -13,6 +13,7 @@
 #include <linux/path.h>
 #include <linux/fs.h>
 #include <linux/fdtable.h>
+#include <linux/sched.h>
 
 #ifdef CONFIG_CHECKPOINT_RESTART
 
@@ -102,16 +103,16 @@ extern int cr_read_files(struct cr_ctx *ctx);
 
 #define pr_fmt(fmt) "[%d:c/r:%s] " fmt, task_pid_vnr(current), __func__
 
-static inline void __files_deny_checkpointing(struct files_struct *files,
-		char *file, int line)
+static inline void __files_deny_checkpointing(const struct task_struct *tsk,
+		struct files_struct *files, char *file, int line)
 {
 	if (!test_and_clear_bit(0, &files->may_checkpoint))
 		return;
-	printk(KERN_INFO "process performed an action that can not be "
-			"checkpointed at: %s:%d\n", file, line);
+	printk(KERN_INFO "%s/%i performed an action that can not be "
+	       "checkpointed at: %s:%d\n", tsk->comm, tsk->pid, file, line);
 }
-#define files_deny_checkpointing(f)  \
-	__files_deny_checkpointing(f, __FILE__, __LINE__)
+#define files_deny_checkpointing(tsk,f)				\
+	__files_deny_checkpointing(tsk, f, __FILE__, __LINE__)
 
 int cr_explain_file(struct file *file, char *explain, int left);
 int cr_file_supported(struct file *file);
-- 
1.6.0.6
