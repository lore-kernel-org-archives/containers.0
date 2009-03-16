From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] Add UTS support to mktree
Date: Mon, 16 Mar 2009 11:13:03 -0700
Message-ID: <1237227184-2757-2-git-send-email-danms@us.ibm.com>
References: <1237227184-2757-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1237227184-2757-1-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

Read the namespace records from the restore stream and do the unshare()
necessary to create a new namespace.  For UTS, set hostname and domainname
to match what was stored in the checkpoint.

Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 mktree.c |   66 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 66 insertions(+), 0 deletions(-)

diff --git a/mktree.c b/mktree.c
index 55149dd..e0898db 100644
--- a/mktree.c
+++ b/mktree.c
@@ -14,6 +14,7 @@
 #include <unistd.h>
 #include <errno.h>
 #include <signal.h>
+#include <sched.h>
 #include <sys/types.h>
 #include <sys/wait.h>
 #include <asm/unistd.h>
@@ -101,6 +102,7 @@ static int cr_read_obj_type(struct cr_ctx *ctx, void *buf, int n, int type);
 
 static int cr_read_head(struct cr_ctx *ctx);
 static int cr_read_head_arch(struct cr_ctx *ctx);
+static int cr_read_namespaces(struct cr_ctx *ctx);
 static int cr_read_tree(struct cr_ctx *ctx);
 
 struct pid_swap {
@@ -191,6 +193,12 @@ int main(int argc, char *argv[])
 		exit(1);
 	}
 
+	ret = cr_read_namespaces(&ctx);
+	if (ret < 0) {
+		perror("read c/r namespaces");
+		exit(1);
+	}
+
 	ret = cr_fork_feeder(&ctx);
 	if (ret < 0)
 		exit(1);
@@ -557,6 +565,64 @@ static int cr_read_head_arch(struct cr_ctx *ctx)
 	return 0;
 }
 
+static int cr_read_task_namespaces(struct cr_ctx *ctx)
+{
+
+	struct cr_hdr_nsproxy hhn;
+	struct cr_hdr_utsns hhu;
+	int parent;
+
+	parent = cr_read_obj_type(ctx, &hhn, sizeof(hhn), CR_HDR_NSP);
+	if (parent < 0)
+		return parent;
+	else if (parent != 0) {
+		errno = -EINVAL;
+		return -1;
+	}
+
+	if (hhn.types == 0)
+		return 0;
+
+	if (unshare(CLONE_NEWUTS) != 0) {
+		perror("unshare(CLONE_NEWUTS)");
+		return -1;
+	}
+
+	if (hhn.types & CR_NSP_UTS) {
+		parent = cr_read_obj_type(ctx, &hhu, sizeof(hhu),
+					  CR_HDR_UTSNS);
+		if (parent < 0)
+			return parent;
+		else if (parent != 0) {
+			errno = -EINVAL;
+			return -1;
+		}
+
+		cr_dbg("UTS namespace nn=%s dn=%s\n",
+		       hhu.nodename,
+		       hhu.domainname);
+
+		sethostname(hhu.nodename, strlen(hhu.nodename));
+		setdomainname(hhu.domainname, strlen(hhu.domainname));
+	}
+
+	return 0;
+}
+
+static int cr_read_namespaces(struct cr_ctx *ctx)
+{
+	int n;
+	int ret = 0;
+
+	for (n = 0; n < ctx->pids_nr; n++) {
+		ret = cr_read_task_namespaces(ctx);
+		if (ret < 0)
+			break;
+	}
+
+	return ret;
+}
+
 static int cr_read_tree(struct cr_ctx *ctx)
 {
 	struct cr_hdr *h = (struct cr_hdr *) ctx->buf;
-- 
1.5.6.3
