From: serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: [PATCH 3/9] x86_64: keep __u32s in even groups
Date: Mon,  8 Feb 2010 20:00:00 -0600
Message-ID: <1265680806-13295-4-git-send-email-serue@us.ibm.com>
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

Otherwise the struct will be different size on x86-32 and x86-64.

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 include/linux/checkpoint_hdr.h |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index e591fd1..5a68178 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -345,6 +345,9 @@ struct ckpt_hdr_task {
 	__u32 exit_code;
 	__u32 exit_signal;
 	__u32 pdeath_signal;
+	__u32 compat_robust_futex_head_len;
+	__u32 compat_robust_futex_list; /* a compat __user ptr */
+	__u32 robust_futex_head_len;
 
 #ifdef CONFIG_AUDITSYSCALL
 	/* would audit want to track the checkpointed ids,
@@ -354,9 +357,6 @@ struct ckpt_hdr_task {
 	__u64 set_child_tid;
 	__u64 clear_child_tid;
 
-	__u32 compat_robust_futex_head_len;
-	__u32 compat_robust_futex_list; /* a compat __user ptr */
-	__u32 robust_futex_head_len;
 	__u64 robust_futex_list; /* a __user ptr */
 } __attribute__((aligned(8)));
 
-- 
1.6.0.4
