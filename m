From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/3] cr: debug: define ckpt_error()
Date: Thu, 22 Oct 2009 23:13:25 -0500
Message-ID: <20091023041325.GA2863@us.ibm.com>
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

For starters it just amounts to a _ckpt_debug(CKPT_ERR),
and has no callers.

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 include/linux/checkpoint.h |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index dfcb59b..351f9ac 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -330,6 +330,7 @@ static inline int ckpt_validate_errno(int errno)
 #define CKPT_DMEM	0x20		/* memory state */
 #define CKPT_DPAGE	0x40		/* memory pages */
 #define CKPT_DIPC	0x80		/* sysvipc */
+#define CKPT_ERR	0x100		/* error */
 
 #define CKPT_DDEFAULT	0xffff		/* default debug level */
 
@@ -370,6 +371,15 @@ static inline void restore_debug_free(struct ckpt_ctx *ctx) {}
 
 #endif /* CONFIG_CHECKPOINT_DEBUG */
 
+#define ckpt_log_error(ctx, fmt, args...)	do { } while (0)
+
+#define ckpt_error(ctx, fmt, args...)					\
+	do {								\
+		ckpt_log_error(ctx, "%s:%d " fmt, __func__, __LINE__,	\
+			       ## args);				\
+		_ckpt_debug(CKPT_ERR, fmt, ## args);			\
+	} while (0)
+
 #endif /* CONFIG_CHECKPOINT */
 #endif /* __KERNEL__ */
 
-- 
1.6.1
