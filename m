From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 5/5] user-cr: use genstack API in nsexeccwp
Date: Fri,  4 Dec 2009 23:02:31 -0600
Message-ID: <1259989351-28552-6-git-send-email-ntl@pobox.com>
References: <1259989351-28552-1-git-send-email-ntl@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1259989351-28552-1-git-send-email-ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
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

Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
---
 Makefile    |    2 +-
 nsexeccwp.c |   11 ++++++-----
 2 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/Makefile b/Makefile
index b1485cb..35188f9 100644
--- a/Makefile
+++ b/Makefile
@@ -39,7 +39,7 @@ restart: CFLAGS += -D__REENTRANT -pthread
 ifneq ($(SUBARCH),)
 restart: clone_$(SUBARCH).o genstack.o
 restart: CFLAGS += -DARCH_HAS_ECLONE
-nsexeccwp: clone_$(SUBARCH).o
+nsexeccwp: clone_$(SUBARCH).o genstack.o
 nsexeccwp: CFLAGS += -DARCH_HAS_ECLONE
 endif
 
diff --git a/nsexeccwp.c b/nsexeccwp.c
index d3853f0..859b6c3 100644
--- a/nsexeccwp.c
+++ b/nsexeccwp.c
@@ -18,6 +18,7 @@
 
 #include "clone.h"
 #include "eclone.h"
+#include "genstack.h"
 
 extern pid_t getpgid(pid_t pid);
 extern pid_t getsid(pid_t pid);
@@ -270,17 +271,17 @@ int main(int argc, char *argv[])
 
 	if (use_clone) {
 		struct clone_args clone_args;
-		int stacksize = 4*getpagesize();
-		void *stack = malloc(stacksize);
+		size_t stacksize = 4 * sysconf(_SC_PAGESIZE);
+		genstack stack = genstack_alloc(stacksize);
 
 		if (!stack) {
-			perror("malloc");
+			perror("genstack_alloc");
 			return -1;
 		}
 
 		memset(&clone_args, 0, sizeof(clone_args));
-		clone_args.child_stack = (unsigned long)stack;
-		clone_args.child_stack_size = stacksize;
+		clone_args.child_stack = (unsigned long)genstack_base(stack);
+		clone_args.child_stack_size = genstack_size(stack);
 		clone_args.nr_pids = nr_pids;
 
 		printf("about to clone with %lx\n", flags);
-- 
1.6.0.6
