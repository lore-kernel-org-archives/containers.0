From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC][PATCH 00/11] track files for checkpointability
Date: Tue, 10 Mar 2009 11:00:00 -0500
Message-ID: <20090310110000.24893e0c__44783.7434396662$1236701021$gmane$org@thinkcentre.lan>
References: <20090305163857.0C18F3FD@kernel>
	<20090310105702.43eb1402@thinkcentre.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090310105702.43eb1402-4v5LP+xe+1byhTdZtsIeww@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Alexey-FOgKQjlUJ6BQetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

From 3695fbda6225d2436e4af67a4bce6984df0891be Mon Sep 17 00:00:00 2001
From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Date: Mon, 9 Mar 2009 22:36:40 -0500
Subject: [PATCH] ratelimit files_deny_checkpointing output

Any common distribution's boot sequence causes thousands of
"<something> performed an action that cannot be checkpointed"
messages.  Kernels are known to produce other messages of interest at
times, so ratelimit the output of files_deny_checkpointing.


Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
---
 include/linux/checkpoint.h |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 27366ac..efdb8f0 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -108,8 +108,10 @@ static inline void __files_deny_checkpointing(const struct task_struct *tsk,
 {
 	if (!test_and_clear_bit(0, &files->may_checkpoint))
 		return;
-	printk(KERN_INFO "%s/%i performed an action that can not be "
-	       "checkpointed at: %s:%d\n", tsk->comm, tsk->pid, file, line);
+	if (printk_ratelimit())
+		printk(KERN_INFO "%s/%i performed an action that can not be "
+				"checkpointed at: %s:%d\n",
+				tsk->comm, tsk->pid, file, line);
 }
 #define files_deny_checkpointing(tsk,f)				\
 	__files_deny_checkpointing(tsk, f, __FILE__, __LINE__)
-- 
1.6.0.6
