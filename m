From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [RFC][PATCH 10/11] add checkpoint/restart compile helper
Date: Thu, 05 Mar 2009 08:39:12 -0800
Message-ID: <20090305163912.3A8363E9@kernel>
References: <20090305163857.0C18F3FD@kernel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090305163857.0C18F3FD@kernel>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Cc: containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org


This is to aid the compiler a little bit so that we
don't have to add as many #ifdefs.  Gets used in the
next patch.

Signed-off-by: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---

 linux-2.6.git-dave/include/linux/checkpoint.h |   11 +++++++++++
 1 file changed, 11 insertions(+)

diff -puN include/linux/checkpoint.h~cr-compile-helper include/linux/checkpoint.h
--- linux-2.6.git/include/linux/checkpoint.h~cr-compile-helper	2009-03-05 08:37:04.000000000 -0800
+++ linux-2.6.git-dave/include/linux/checkpoint.h	2009-03-05 08:37:04.000000000 -0800
@@ -115,6 +115,10 @@ static inline void __files_deny_checkpoi
 
 int cr_explain_file(struct file *file, char *explain, int left);
 int cr_file_supported(struct file *file);
+static inline int cr_enabled(void)
+{
+	return 1;
+}
 
 #else /* !CONFIG_CHECKPOINT_RESTART */
 
@@ -128,6 +132,13 @@ static inline int cr_file_supported(stru
 {
 	return 0;
 }
+/*
+ * Use this when you can in lieu of an #ifdef
+ */
+static inline int cr_enabled(void)
+{
+	return 0;
+}
 
 #endif /* CONFIG_CHECKPOINT_RESTART */
 #endif /* _CHECKPOINT_CKPT_H_ */
_
