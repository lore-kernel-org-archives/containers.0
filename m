From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 2/2] ipcns 2/2: extract create_ipc_ns()
Date: Mon, 4 May 2009 03:26:16 +0400
Message-ID: <20090503232616.GC16631__28826.9187011339$1241393265$gmane$org@x200.localdomain>
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
To: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

clone_ipc_ns() is misnamed, it doesn't clone anything and doesn't use passed
parameter. Rename it.

create_ipc_ns() will be used by C/R to create fresh ipcns.

Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 ipc/namespace.c |    9 ++-------
 1 files changed, 2 insertions(+), 7 deletions(-)

diff --git a/ipc/namespace.c b/ipc/namespace.c
index a56fc59..231ee53 100644
--- a/ipc/namespace.c
+++ b/ipc/namespace.c
@@ -14,7 +14,7 @@
 
 #include "util.h"
 
-static struct ipc_namespace *clone_ipc_ns(struct ipc_namespace *old_ns)
+static struct ipc_namespace *create_ipc_ns(void)
 {
 	struct ipc_namespace *ns;
 	int err;
@@ -48,14 +48,9 @@ static struct ipc_namespace *clone_ipc_ns(struct ipc_namespace *old_ns)
 
 struct ipc_namespace *copy_ipcs(unsigned long flags, struct ipc_namespace *ns)
 {
-	struct ipc_namespace *new_ns;
-
 	if (!(flags & CLONE_NEWIPC))
 		return get_ipc_ns(ns);
-
-	new_ns = clone_ipc_ns(ns);
-
-	return new_ns;
+	return create_ipc_ns();
 }
 
 /*
