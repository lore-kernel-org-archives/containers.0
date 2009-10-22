From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] ipc_ind_to_str unused if !CONFIG_CHECKPOINT_DEBUG
Date: Thu, 22 Oct 2009 14:36:57 -0500
Message-ID: <20091022193657.GA12321@us.ibm.com>
References: <20091022143238.GA31778@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20091022143238.GA31778-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

(compilation cleanup on top of
	fix-compile-with-CONFIG_CHECKPOINT_DEBUG-n.patch
)

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 ipc/checkpoint.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/ipc/checkpoint.c b/ipc/checkpoint.c
index 8e6e9ba..ab9110a 100644
--- a/ipc/checkpoint.c
+++ b/ipc/checkpoint.c
@@ -21,7 +21,9 @@
 #include "util.h"
 
 /* for ckpt_debug */
+#ifdef CONFIG_CHECKPOINT_DEBUG
 static char *ipc_ind_to_str[] = { "sem", "msg", "shm" };
+#endif
 
 #define shm_ids(ns)	((ns)->ids[IPC_SHM_IDS])
 #define msg_ids(ns)	((ns)->ids[IPC_MSG_IDS])
-- 
1.6.1
