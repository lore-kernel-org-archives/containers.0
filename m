From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 10/10] [RFC] Use call_usermodehelper to cleanup after failure
Date: Mon, 28 Feb 2011 20:05:16 -0800
Message-ID: <dc988b4723a10df05bf6889df851db2e5b228461.1298952288.git.matthltc@us.ibm.com>
References: <1298952316-15763-1-git-send-email-matthltc@us.ibm.com>
	<a6df3726c48b6f9e2422e9c12a32c4991bc53a25.1298952288.git.matthltc@us.ibm.com>
	<cbc5f629ca02554497bcb385039a2a300ef897f0.1298952288.git.matthltc@us.ibm.com>
	<6f547f7b0dd12d409f993dba3fbc899dc52f2a78.1298952288.git.matthltc@us.ibm.com>
	<1a7a344ddd1d68ac862ec2248be77f2dd9f138c8.1298952288.git.matthltc@us.ibm.com>
	<dbe36642be44152833a63e8173e8f0490dc1573f.1298952288.git.matthltc@us.ibm.com>
	<ac2a9431a97bbb45bdecf2ccd011f70ee99f2731.1298952288.git.matthltc@us.ibm.com>
	<24a5e0d9179d6e3c29ec0197a3251963ff2a4dbd.1298952288.git.matthltc@us.ibm.com>
	<3d0a3c702e5986a45676987a4f3a6607d28725e7.1298952288.git.matthltc@us.ibm.com>
	<7c6e1ebb39ca920c0c4c572e1f455250b2fbba4b.1298952288.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <7c6e1ebb39ca920c0c4c572e1f455250b2fbba4b.1298952288.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
In-Reply-To: <a6df3726c48b6f9e2422e9c12a32c4991bc53a25.1298952288.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
References: <a6df3726c48b6f9e2422e9c12a32c4991bc53a25.1298952288.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Without this sys_checkpoint may fail yet still leave files relinked
in <mnt>/lost+found/checkpoint-N/. This patch uses call_usermodehelper()
to clean up those files if sys_checkpoint has failed.

It is possible to do this from userspace instead but due to the
need to parse the image and/or traverse all mount namespaces and mounts
the complexity of the code will be much higher there. That said, this
is an "rm -rf" invoked by the kernel -- not something we want to stuff in
the kernel without considerable forethought. So I've made ths an RFC and,
until this patch gets accepted, we can plan on cleaning up from userspace.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 fs/namei.c |   18 ++++++++++++++++++
 1 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index f6361f8..0084ceb 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -2599,6 +2599,21 @@ static void mkdirname(char *path, char **delim_p)
 	}
 }
 
+static int checkpoint_rm_relink_collection(void *dq_data)
+{
+	char *argv[4], *envp[2];
+
+	argv[0] = "rm";
+	argv[1] = "-rf";
+	argv[2] = dq_data;
+	argv[3] = NULL;
+
+	envp[0] = "PATH=/sbin:/bin:/usr/sbin:/usr/bin";
+	envp[1] = NULL;
+
+	return call_usermodehelper(argv[0], argv, envp, UMH_WAIT_EXEC);
+}
+
 /*
  * Make the directory used to collect all of the links in. Remove it
  * if checkpoint fails.
@@ -2614,6 +2629,9 @@ static int checkpoint_make_relink_collection(struct ckpt_ctx *ctx,
 	if (!delim || (strlen(new_path) < 2)) /* Need a non-empty dirname */
 		return -ENOENT;
 	ret = kernel_sys_mkdir(new_path, S_IRWXU & ~current_umask());
+	if (!ret)
+		deferqueue_add(ctx->err_deferq, new_path, delim - new_path + 1,
+			       checkpoint_rm_relink_collection, NULL);
 	if (delim)
 		*delim = '/';
 	if (ret == -EEXIST) /* already created the collection dir */
-- 
1.6.3.3
