From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/1] cr: allocate security context for msg_msg
Date: Thu, 25 Jun 2009 13:57:32 -0500
Message-ID: <20090625185732.GA11699@us.ibm.com>
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

Since we create msg_msg structs by hand, we also need to
ask LSM to allocate a security context.  Otherwise
selinux_msg_queue_msgrcv will throw a fit dereferencing
msg->security (6b6b6b6b6b6b6000).

With this patch, cr tests can be executed with selinux
enabled.

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 ipc/checkpoint_msg.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/ipc/checkpoint_msg.c b/ipc/checkpoint_msg.c
index 51385b0..fca8e7d 100644
--- a/ipc/checkpoint_msg.c
+++ b/ipc/checkpoint_msg.c
@@ -17,6 +17,7 @@
 #include <linux/sched.h>
 #include <linux/syscalls.h>
 #include <linux/nsproxy.h>
+#include <linux/security.h>
 #include <linux/ipc_namespace.h>
 
 #include "util.h"
@@ -248,6 +249,8 @@ static struct msg_msg *restore_msg_contents_one(struct ckpt_ctx *ctx, int *clen)
 	msg->m_type = h->m_type;
 	msg->m_ts = h->m_ts;
 	*clen = h->m_ts;
+	ret = security_msg_msg_alloc(msg);
+
  out:
 	if (ret < 0 && msg) {
 		free_msg(msg);
-- 
1.6.1
