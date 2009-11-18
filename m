From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 1/9] user-cr: add eclone/clone_args header
Date: Tue, 17 Nov 2009 18:55:38 -0600
Message-ID: <1258505746-31182-2-git-send-email-ntl@pobox.com>
References: <1258505746-31182-1-git-send-email-ntl@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1258505746-31182-1-git-send-email-ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
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
Cc: Oren-FOgKQjlUJ6BQetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Declare these interfaces which will replace clone_with_pids.

Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
---
 eclone.h |   25 +++++++++++++++++++++++++
 1 files changed, 25 insertions(+), 0 deletions(-)
 create mode 100644 eclone.h

diff --git a/eclone.h b/eclone.h
new file mode 100644
index 0000000..601a621
--- /dev/null
+++ b/eclone.h
@@ -0,0 +1,25 @@
+#ifndef _ECLONE_H_
+#define _ECLONE_H_
+
+#include <stdint.h>
+
+struct clone_args {
+	uint64_t clone_flags_high;
+	uint64_t child_stack;
+	uint64_t child_stack_size;
+	uint64_t parent_tid_ptr;
+	uint64_t child_tid_ptr;
+
+	uint32_t nr_pids;
+
+	uint32_t reserved0;
+	uint64_t reserved1;
+};
+
+/* arch-dependent code implements this interface */
+extern int eclone(int (*fn)(void *), void *fn_arg,
+		  int clone_flags_low,
+		  struct clone_args *clone_args,
+		  pid_t *pids);
+
+#endif
-- 
1.6.2.5
