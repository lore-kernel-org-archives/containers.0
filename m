From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH user-cr] handle the container configuration section in ckpt
	header
Date: Thu, 15 Oct 2009 13:48:59 -0500
Message-ID: <20091015184859.GA30490@us.ibm.com>
References: <20091015184827.GA30444@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20091015184827.GA30444-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 restart.c |   29 +++++++++++++++++++++++++++++
 1 files changed, 29 insertions(+), 0 deletions(-)

diff --git a/restart.c b/restart.c
index e6e72ac..cb81293 100644
--- a/restart.c
+++ b/restart.c
@@ -264,6 +264,7 @@ struct ckpt_ctx {
 	
 	char header[BUFSIZE];
 	char header_arch[BUFSIZE];
+	char container[BUFSIZE];
 	char tree[BUFSIZE];
 	char buf[BUFSIZE];
 	struct args *args;
@@ -303,6 +304,7 @@ static int ckpt_write_obj(struct ckpt_ctx *ctx, struct ckpt_hdr *h);
 
 static int ckpt_write_header(struct ckpt_ctx *ctx);
 static int ckpt_write_header_arch(struct ckpt_ctx *ctx);
+static int ckpt_write_container(struct ckpt_ctx *ctx);
 static int ckpt_write_tree(struct ckpt_ctx *ctx);
 
 static int _ckpt_read(int fd, void *buf, int count);
@@ -313,6 +315,7 @@ static int ckpt_read_obj_type(struct ckpt_ctx *ctx, void *b, int n, int type);
 
 static int ckpt_read_header(struct ckpt_ctx *ctx);
 static int ckpt_read_header_arch(struct ckpt_ctx *ctx);
+static int ckpt_read_container(struct ckpt_ctx *ctx);
 static int ckpt_read_tree(struct ckpt_ctx *ctx);
 
 static int hash_init(struct ckpt_ctx *ctx);
@@ -693,6 +696,12 @@ int main(int argc, char *argv[])
 		exit(1);
 	}
 
+	ret = ckpt_read_container(&ctx);
+	if (ret < 0) {
+		perror("read c/r container section");
+		exit(1);
+	}
+
 	ret = ckpt_read_tree(&ctx);
 	if (ret < 0) {
 		perror("read c/r tree");
@@ -1850,6 +1859,9 @@ static int ckpt_do_feeder(void *data)
 	if (ckpt_write_header_arch(ctx) < 0)
 		ckpt_abort(ctx, "write c/r header arch");
 
+	if (ckpt_write_container(ctx) < 0)
+		ckpt_abort(ctx, "write container section");
+
 	if (ckpt_write_tree(ctx) < 0)
 		ckpt_abort(ctx, "write c/r tree");
 
@@ -2102,6 +2114,14 @@ static int ckpt_read_header_arch(struct ckpt_ctx *ctx)
 	return 0;
 }
 
+static int ckpt_read_container(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_container *h;
+
+	h = (struct ckpt_hdr_container *) ctx->container;
+	return ckpt_read_obj_type(ctx, h, sizeof(*h), CKPT_HDR_CONTAINER);
+}
+
 static int ckpt_read_tree(struct ckpt_ctx *ctx)
 {
 	struct ckpt_hdr_tree *h;
@@ -2174,6 +2194,15 @@ static int ckpt_write_header_arch(struct ckpt_ctx *ctx)
 	return ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
 }
 
+static int ckpt_write_container(struct ckpt_ctx *ctx)
+{
+	char *ptr;
+
+	ptr = (char *) ctx->container;
+	/* write the container info section */
+	return ckpt_write_obj(ctx, (struct ckpt_hdr *) ptr);
+}
+
 static int ckpt_write_tree(struct ckpt_ctx *ctx)
 {
 	struct ckpt_hdr_tree *h;
-- 
1.6.1.1
