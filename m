From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 2/3] c/r: Add CR_COPY() macro (v4)
Date: Thu, 19 Mar 2009 15:41:18 -0400
Message-ID: <1237491679-14433-3-git-send-email-danms@us.ibm.com>
References: <1237491679-14433-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1237491679-14433-1-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

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

1: https://lists.linux-foundation.org/pipermail/containers/2009-February/015821.html (all the way at the bottom)
---
 include/linux/checkpoint.h |   23 +++++++++++++++++++++++
 1 files changed, 23 insertions(+), 0 deletions(-)

diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index e77393f..f748a75 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -120,6 +120,29 @@ static inline int cr_enabled(void)
 	return 1;
 }
 
+#define CR_CPT 1
+#define CR_RST 2
+
+#define CR_COPY(op, a, b)				        \
+	do {							\
+		if (op == CR_CPT)				\
+			a = b;					\
+		else						\
+			b = a;					\
+	} while (0)
+
+/* Copy @count items from @b to @a if op is CR_CPT (otherwise,
+ * copy in the reverse direction)
+ */
+#define CR_COPY_ARRAY(op, a, b, count)				\
+	do {							\
+		BUILD_BUG_ON(sizeof(*a) != sizeof(*b));		\
+		if (op == CR_CPT)				\
+			memcpy(a, b, count * sizeof(*a));	\
+		else						\
+			memcpy(b, a, count * sizeof(*a));	\
+	} while (__must_be_array(a) && __must_be_array(b) && 0)
+
 #else /* !CONFIG_CHECKPOINT_RESTART */
 
 static inline void files_deny_checkpointing(struct files_struct *files) {}
-- 
1.6.1
