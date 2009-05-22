From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 24/38] C/R: x86_64 debug registers
Date: Fri, 22 May 2009 08:55:18 +0400
Message-ID: <1242968132-1044-24-git-send-email-adobriyan__15301.0827991695$1242971003$gmane$org@gmail.com>
References: <1242968132-1044-1-git-send-email-adobriyan@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1242968132-1044-1-git-send-email-adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
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
Cc: xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 include/linux/kstate-image.h  |    7 +++++++
 kernel/kstate/kstate-x86_64.c |   26 ++++++++++++++++++++++----
 2 files changed, 29 insertions(+), 4 deletions(-)

diff --git a/include/linux/kstate-image.h b/include/linux/kstate-image.h
index d697d97..7c54711 100644
--- a/include/linux/kstate-image.h
+++ b/include/linux/kstate-image.h
@@ -143,6 +143,13 @@ struct kstate_image_task_struct_x86_64 {
 	__u16		gsindex;
 	__u16		ss;
 
+	__u64		dr0;
+	__u64		dr1;
+	__u64		dr2;
+	__u64		dr3;
+	__u64		dr6;
+	__u64		dr7;
+
 	__u64		tls_array[3];
 } __packed;
 
diff --git a/kernel/kstate/kstate-x86_64.c b/kernel/kstate/kstate-x86_64.c
index 0d85704..83ed1b5 100644
--- a/kernel/kstate/kstate-x86_64.c
+++ b/kernel/kstate/kstate-x86_64.c
@@ -109,6 +109,10 @@ static int check_image_task_struct_x86_64(struct kstate_image_task_struct *tsk_i
 	if (rv < 0)
 		return rv;
 
+	rv = ptrace_check_debugreg(0, i->dr0, i->dr1, i->dr2, i->dr3, i->dr6, i->dr7);
+	if (rv < 0)
+		return rv;
+
 	if (i->tls_array[0]) {
 		rv = check_tls((struct desc_struct *)&i->tls_array[0]);
 		if (rv < 0)
@@ -150,10 +154,6 @@ int kstate_arch_check_task_struct(struct task_struct *tsk)
 		return -EINVAL;
 	}
 #endif
-	if (test_tsk_thread_flag(tsk, TIF_DEBUG)) {
-		WARN_ON(1);
-		return -EINVAL;
-	}
 	if (tsk->thread.xstate) {
 		WARN_ON(1);
 		return -EINVAL;
@@ -250,6 +250,13 @@ static int dump_task_struct_x86_64(struct kstate_context *ctx, struct task_struc
 	i->gsindex = encode_segment(tsk->thread.gsindex);
 	i->ss = encode_segment(regs->ss);
 
+	i->dr0 = tsk->thread.debugreg0;
+	i->dr1 = tsk->thread.debugreg1;
+	i->dr2 = tsk->thread.debugreg2;
+	i->dr3 = tsk->thread.debugreg3;
+	i->dr6 = tsk->thread.debugreg6;
+	i->dr7 = tsk->thread.debugreg7;
+
 	BUILD_BUG_ON(sizeof(tsk->thread.tls_array[0]) != 8);
 	BUILD_BUG_ON(sizeof(tsk->thread.tls_array) != 3 * 8);
 	memcpy(i->tls_array, tsk->thread.tls_array, sizeof(i->tls_array));
@@ -299,6 +306,17 @@ static int restore_task_struct_x86_64(struct task_struct *tsk, struct kstate_ima
 	tsk->thread.gsindex = decode_segment(i->gsindex);
 	regs->ss = decode_segment(i->ss);
 
+	tsk->thread.debugreg0 = i->dr0;
+	tsk->thread.debugreg1 = i->dr1;
+	tsk->thread.debugreg2 = i->dr2;
+	tsk->thread.debugreg3 = i->dr3;
+	tsk->thread.debugreg6 = i->dr6;
+	tsk->thread.debugreg7 = i->dr7;
+	if (i->dr7)
+		set_tsk_thread_flag(tsk, TIF_DEBUG);
+	else
+		clear_tsk_thread_flag(tsk, TIF_DEBUG);
+
 	memcpy(tsk->thread.tls_array, i->tls_array, sizeof(i->tls_array));
 
 	set_tsk_thread_flag(tsk, TIF_FORK);
-- 
1.5.6.5
