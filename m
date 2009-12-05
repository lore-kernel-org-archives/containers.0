From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 3/5] user-cr: add generic stack API
Date: Fri,  4 Dec 2009 23:02:29 -0600
Message-ID: <1259989351-28552-4-git-send-email-ntl@pobox.com>
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

A few problems exist with the management of stacks for clone/eclone in
the restart utility.

* Stacks are allocated from the heap via malloc.  This means any
  mishandling of the the stack setup by the platform eclone code can
  result in silent data corruption.  At a time when architecture
  support for eclone is an ongoing effort, this seems unwise...

* Determining a suitable stack pointer to pass to clone(2) is
  platform-dependent; we don't handle e.g. parisc where the stack
  grows upwards.

* There are at least two cases (ckpt_coordinator_pidns and
  ckpt_fork_feeder) where the stack pointer provided to
  clone(2) is outside of the region allocated.

To address these issues, introduce an opaque "genstack" (generic
stack) type and accessor functions.  Stacks are allocated via mmap()
and guard pages are instantiated at both ends.  The accessor functions
provide suitable values for passing to clone(2) and eclone(2) (via
struct clone_args in the latter case).

Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
---
 genstack.c |  101 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 genstack.h |   22 +++++++++++++
 2 files changed, 123 insertions(+), 0 deletions(-)
 create mode 100644 genstack.c
 create mode 100644 genstack.h

diff --git a/genstack.c b/genstack.c
new file mode 100644
index 0000000..c552d04
--- /dev/null
+++ b/genstack.c
@@ -0,0 +1,101 @@
+#include <stdbool.h>
+#include <stdlib.h>
+#include <unistd.h>
+#include <sys/mman.h>
+
+#include "genstack.h"
+
+struct genstack {
+	void *addr;  /* Return value from mmap. Accessors must account
+		      * for guard pages at both ends.
+		      */
+	size_t size; /* Size of the region as passed to mmap. */
+};
+
+static size_t page_size(void)
+{
+	return sysconf(_SC_PAGESIZE);
+}
+
+/* Allocate a stack region with guard pages (PROT_NONE) at both ends.
+ * The size requested will be rounded up to the system page size.
+ * Callers must check for errors with genstack_err().
+ */
+struct genstack *genstack_alloc(size_t sz)
+{
+	struct genstack *stk;
+	int mmap_flags = MAP_PRIVATE | MAP_ANONYMOUS;
+	int mmap_prot = PROT_READ | PROT_WRITE;
+	void *addr;
+
+	/* Align requested size up to page boundary */
+	sz = (sz + page_size() - 1) & (~(page_size() - 1));
+
+	if (sz == 0)
+		return NULL;
+
+	stk = malloc(sizeof(*stk));
+	if (!stk)
+		return NULL;
+
+	/* Make space for guard pages */
+	sz += page_size() * 2;
+
+	addr = mmap(NULL, sz, mmap_prot, mmap_flags, -1, 0);
+	if (addr == MAP_FAILED) {
+		free(stk);
+		return NULL;
+	}
+
+	/* guard pages */
+	mprotect(addr, page_size(), PROT_NONE);
+	mprotect(addr + sz - page_size(), page_size(), PROT_NONE);
+
+	stk->addr = addr;
+	stk->size = sz;
+
+	return stk;
+}
+
+/* Unmap the stack region. */
+void genstack_release(struct genstack *stk)
+{
+	munmap(stk->addr, stk->size);
+	free(stk);
+}
+
+/* Return the size of the usable stack region.  Suitable for providing
+ * the child_stack_size value for struct clone_args.
+ */
+size_t genstack_size(const struct genstack *stk)
+{
+	return stk->size - (page_size() * 2);
+}
+
+/* Return the lowest usable address in the stack region.  Suitable for
+ * providing the child_stack value for struct clone_args.
+ */
+void *genstack_base(const struct genstack *stk)
+{
+	return stk->addr + page_size();
+}
+
+/* Return a suitable stack pointer value for passing to clone(2),
+ * accounting for platform differences in stack behavior.
+ */
+void *genstack_sp(const struct  genstack *stk)
+{
+#ifdef __hppa__
+	/*
+	 * If stack grows upwards, return the lowest address between
+	 * the guard pages.
+	 */
+	return stk->addr + page_size();
+#else
+	/*
+	 * Otherwise return the highest address between the guard pages.
+	 * glibc's clone wrappers apply any necessary alignment.
+	 */
+	return (stk->addr + stk->size - page_size()) - 1;
+#endif
+}
diff --git a/genstack.h b/genstack.h
new file mode 100644
index 0000000..6970d99
--- /dev/null
+++ b/genstack.h
@@ -0,0 +1,22 @@
+#ifndef _GENSTACK_H_
+#define _GENSTACK_H_
+
+#include <stdbool.h>
+#include <stdint.h>
+
+/* A generic stack API. */
+
+struct genstack;
+typedef struct genstack *genstack;
+
+extern struct genstack *genstack_alloc(size_t size);
+
+extern void genstack_release(struct genstack *stack);
+
+extern size_t genstack_size(const struct genstack *stack);
+
+extern void *genstack_base(const struct genstack *stack);
+
+extern void *genstack_sp(const struct genstack *stack);
+
+#endif
-- 
1.6.0.6
