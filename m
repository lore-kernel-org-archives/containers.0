From: serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: [PATCH 5/9] use ckpt_err for architecture mismatch errors
Date: Mon,  8 Feb 2010 20:00:02 -0600
Message-ID: <1265680806-13295-6-git-send-email-serue@us.ibm.com>
References: <1265680806-13295-1-git-send-email-serue@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1265680806-13295-1-git-send-email-serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 arch/x86/kernel/checkpoint.c |    4 +++-
 checkpoint/restart.c         |   18 ++++++++++++++----
 2 files changed, 17 insertions(+), 5 deletions(-)

diff --git a/arch/x86/kernel/checkpoint.c b/arch/x86/kernel/checkpoint.c
index 961b131..7c73983 100644
--- a/arch/x86/kernel/checkpoint.c
+++ b/arch/x86/kernel/checkpoint.c
@@ -465,8 +465,10 @@ int restore_read_header_arch(struct ckpt_ctx *ctx)
 	/* verify FPU capabilities */
 	if (h->has_fxsr != cpu_has_fxsr ||
 	    h->has_xsave != cpu_has_xsave ||
-	    h->xstate_size != xstate_size)
+	    h->xstate_size != xstate_size) {
 		ret = -EINVAL;
+		ckpt_err(ctx, ret, "incompatible FPU capabilities");
+	}
 
 	ckpt_hdr_put(ctx, h);
 	return ret;
diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index fcd07fa..9bb17fc 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -569,12 +569,14 @@ static int check_kernel_const(struct ckpt_const *h)
 		return -EINVAL;
 	if (h->uts_nodename_len != sizeof(uts->nodename))
 		return -EINVAL;
+#if 0
 	if (h->uts_release_len != sizeof(uts->release))
 		return -EINVAL;
 	if (h->uts_version_len != sizeof(uts->version))
 		return -EINVAL;
 	if (h->uts_machine_len != sizeof(uts->machine))
 		return -EINVAL;
+#endif
 	if (h->uts_domainname_len != sizeof(uts->domainname))
 		return -EINVAL;
 	/* rlimit */
@@ -601,20 +603,28 @@ static int restore_read_header(struct ckpt_ctx *ctx)
 		return PTR_ERR(h);
 
 	ret = -EINVAL;
-	if (le16_to_cpu(h->arch_id) != CKPT_ARCH_ID)
+	if (le16_to_cpu(h->arch_id) != CKPT_ARCH_ID) {
+		ckpt_err(ctx, ret, "incompatible ARCH_ID");
 		goto out;
+	}
 	if (h->magic != CHECKPOINT_MAGIC_HEAD ||
 	    h->rev != CHECKPOINT_VERSION ||
 	    h->major != ((LINUX_VERSION_CODE >> 16) & 0xff) ||
 	    h->minor != ((LINUX_VERSION_CODE >> 8) & 0xff) ||
-	    h->patch != ((LINUX_VERSION_CODE) & 0xff))
+	    h->patch != ((LINUX_VERSION_CODE) & 0xff)) {
+		ckpt_err(ctx, ret, "incompatible VERSION");
 		goto out;
-	if (h->uflags & ~CHECKPOINT_USER_FLAGS)
+	}
+	if (h->uflags & ~CHECKPOINT_USER_FLAGS) {
+		ckpt_err(ctx, ret, "bad restart user flags");
 		goto out;
+	}
 
 	ret = check_kernel_const(&h->constants);
-	if (ret < 0)
+	if (ret < 0) {
+		ckpt_err(ctx, ret, "incompatible kernel constants");
 		goto out;
+	}
 
 	ret = -ENOMEM;
 	uts = kmalloc(sizeof(*uts), GFP_KERNEL);
-- 
1.6.0.4
