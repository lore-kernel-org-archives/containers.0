From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 2/3] c/r: Add CR_COPY() macro (v2)
Date: Wed, 25 Feb 2009 13:12:08 -0500
Message-ID: <1235585529-806-3-git-send-email-danms@us.ibm.com>
References: <1235585529-806-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1235585529-806-1-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

As suggested by Dave, this provides us a way to make the copy-in and
copy-out processes symmetric.  I also added CR_COPY_BIT() to use with
the s390 bitfields, since we can't memcpy() those.

Changelog:
    Feb 25:
            . Changed WARN_ON() to BUILD_BUG_ON()

Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 include/linux/checkpoint.h |   20 ++++++++++++++++++++
 1 files changed, 20 insertions(+), 0 deletions(-)

diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 217cf6e..3add90e 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -149,4 +149,24 @@ static inline void process_deny_checkpointing(struct task_struct *task) {}
 
 #endif
 
+#define CR_CPT 1
+#define CR_RST 2
+
+#define CR_COPY(op, a, b)				\
+	do {						\
+		BUILD_BUG_ON(sizeof(a) != sizeof(b));	\
+		if (op == CR_CPT)			\
+			memcpy(&a, &b, sizeof(a));	\
+		else					\
+			memcpy(&b, &a, sizeof(a));	\
+	} while (0);
+
+#define CR_COPY_BIT(op, a, b)				\
+	do {						\
+		if (op == CR_CPT)			\
+			a = b;				\
+		else					\
+			b = a;				\
+	} while (0);
+
 #endif /* _CHECKPOINT_CKPT_H_ */
-- 
1.6.1
