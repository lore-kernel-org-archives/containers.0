From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [RFC v14-rc3][PATCH 26/36] c/r: Add CR_COPY() macro (v4)
Date: Tue,  7 Apr 2009 08:27:34 -0400
Message-ID: <1239107264-21775-27-git-send-email-orenl@cs.columbia.edu>
References: <1239107264-21775-1-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1239107264-21775-1-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

As suggested by Dave[1], this provides us a way to make the copy-in and
copy-out processes symmetric.  CR_COPY_ARRAY() provides us a way to do
the same thing but for arrays.  It's not critical, but it helps us unify
the checkpoint and restart paths for some things.

Changelog:
    Mar 04:
            . Removed semicolons
            . Added build-time check for __must_be_array in CR_COPY_ARRAY
    Feb 27:
            . Changed CR_COPY() to use assignment, eliminating the need
              for the CR_COPY_BIT() macro
            . Add CR_COPY_ARRAY() macro to help copying register arrays,
              etc
            . Move the macro definitions inside the CR #ifdef
    Feb 25:
            . Changed WARN_ON() to BUILD_BUG_ON()

Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

1: https://lists.linux-foundation.org/pipermail/containers/2009-February/015821.html (all the way at the bottom)
---
 include/linux/checkpoint.h |   28 ++++++++++++++++++++++++++++
 1 files changed, 28 insertions(+), 0 deletions(-)

diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index c83e448..043535c 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -129,6 +129,34 @@ extern int do_checkpoint(struct cr_ctx *ctx, pid_t pid);
 extern int do_restart(struct cr_ctx *ctx, pid_t pid);
 
 
+/* useful macros to copy fields and buffers to/from cr_hdr_xxx structures */
+#define CR_CPT 1
+#define CR_RST 2
+
+#define CR_COPY(op, SAVE, LIVE)				        \
+	do {							\
+		if (op == CR_CPT)				\
+			SAVE = LIVE;				\
+		else						\
+			LIVE = SAVE;				\
+	} while (0)
+
+/*
+ * Copy @count items from @LIVE to @SAVE if op is CR_CPT (otherwise,
+ * copy in the reverse direction)
+ */
+#define CR_COPY_ARRAY(op, SAVE, LIVE, count)				\
+	do {								\
+		(void)__must_be_array(SAVE);				\
+		(void)__must_be_array(LIVE);				\
+		BUILD_BUG_ON(sizeof(*SAVE) != sizeof(*LIVE));		\
+		if (op == CR_CPT)					\
+			memcpy(SAVE, LIVE, count * sizeof(*SAVE));	\
+		else							\
+			memcpy(LIVE, SAVE, count * sizeof(*SAVE));	\
+	} while (0)
+
+
 #define cr_debug(fmt, args...)  \
 	pr_debug("[%d:c/r:%s] " fmt, task_pid_vnr(current), __func__, ## args)
 
-- 
1.5.4.3
