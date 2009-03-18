From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/2] Add UTS support to mktree (v4)
Date: Wed, 18 Mar 2009 11:55:09 -0700
Message-ID: <1237402510-29053-2-git-send-email-danms@us.ibm.com>
References: <1237402510-29053-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1237402510-29053-1-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

Changes:
 - Check return of sethostname() and setdomainname()
 - Update to match new struct name and header type to kernel patch
 - Update the method used to read the node and domain names to match
   what the updated kernel patch is doing

Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 mktree.c |  120 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 120 insertions(+), 0 deletions(-)

diff --git a/mktree.c b/mktree.c
index 55149dd..fcfa779 100644
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
@@ -98,9 +99,11 @@ static int cr_write_tree(struct cr_ctx *ctx);
 static int cr_read(int fd, void *buf, int count);
 static int cr_read_obj(struct cr_ctx *ctx, struct cr_hdr *h, void *buf, int n);
 static int cr_read_obj_type(struct cr_ctx *ctx, void *buf, int n, int type);
+static int cr_read_string(struct cr_ctx *ctx, char **buf, int len);
 
 static int cr_read_head(struct cr_ctx *ctx);
 static int cr_read_head_arch(struct cr_ctx *ctx);
+static int cr_read_namespaces(struct cr_ctx *ctx);
 static int cr_read_tree(struct cr_ctx *ctx);
 
 struct pid_swap {
@@ -191,6 +194,12 @@ int main(int argc, char *argv[])
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
@@ -511,6 +520,30 @@ static int cr_read_obj_type(struct cr_ctx *ctx, void *buf, int n, int type)
 	return ret;
 }
 
+static int cr_read_string(struct cr_ctx *ctx, char **buf, int len)
+{
+	struct cr_hdr *h = (struct cr_hdr *) ctx->buf;
+	int ret;
+
+	ret = cr_read(STDIN_FILENO, h, sizeof(*h));
+	if (ret < 0)
+		return ret;
+	if (h->type != CR_HDR_STRING)
+		return -1;
+
+	*buf = (char *) malloc(len);
+	if (!*buf)
+		return -ENOMEM;
+
+	ret = cr_read(STDIN_FILENO, *buf, len);
+	if (ret < 0) {
+		free(*buf);
+		*buf = NULL;
+	}
+
+	return ret;
+}
+
 /*
  * read/write the checkpoint image: similar to in-kernel code
  */
@@ -557,6 +590,93 @@ static int cr_read_head_arch(struct cr_ctx *ctx)
 	return 0;
 }
 
+static int cr_read_task_utsns(struct cr_ctx *ctx)
+{
+	int parent;
+	struct cr_hdr_utsns hh;
+	char *namebuf = NULL;
+	int ret = 0;
+
+	parent = cr_read_obj_type(ctx, &hh, sizeof(hh),
+				  CR_HDR_UTSNS);
+	if (parent < 0)
+		return parent;
+	else if (parent != 0) {
+		errno = -EINVAL;
+		return -1;
+	}
+
+	ret = cr_read_string(ctx, &namebuf, hh.nodename_len);
+	if (ret < 0)
+		goto out;
+
+	if (sethostname(namebuf, strlen(namebuf)) < 0) {
+		perror("sethostname");
+		goto out;
+	}
+
+	free(namebuf);
+	namebuf = NULL;
+
+	ret = cr_read_string(ctx, &namebuf, hh.domainname_len);
+	if (ret < 0)
+		goto out;
+
+	if (setdomainname(namebuf, strlen(namebuf)) < 0)
+		perror("setdomainname");
+ out:
+	free(namebuf);
+
+	return 0;
+}
+
+static int cr_read_task_namespaces(struct cr_ctx *ctx)
+{
+	struct cr_hdr_namespaces hh;
+	int parent;
+	int ret;
+
+	parent = cr_read_obj_type(ctx, &hh, sizeof(hh), CR_HDR_NS);
+	if (parent < 0)
+		return parent;
+	else if (parent != 0) {
+		errno = -EINVAL;
+		return -1;
+	}
+
+	if (hh.types == 0)
+		return 0;
+
+	if (unshare(CLONE_NEWUTS) != 0) {
+		perror("unshare(CLONE_NEWUTS)");
+		return -1;
+	}
+
+	if (hh.types & CR_NS_UTS) {
+		ret = cr_read_task_utsns(ctx);
+		if (ret < 0)
+			return ret;
+
+		/* Read other namespaces here */
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
