From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [PATCH 3/4] restart thread safety: remove malloc from genstack
Date: Fri, 30 Jul 2010 13:08:32 -0400
Message-ID: <1280509713-6745-3-git-send-email-orenl@cs.columbia.edu>
References: <1280169472.7875.4290.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1280169472.7875.4290.camel@localhost>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: Nathan Lynch <nathanl-V7BBcbaFuwjMbYB6QlFGEg@public.gmane.org>
List-Id: containers.vger.kernel.org

We use clone and eclone directly and not through glibc, therefore
must explicitly care about thread-safety of malloc.

This patch eliminates the use of malloc() in genstack_alloc().
Use mmap() instead. While an overkill, I don't expect performance
issues of this.

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 genstack.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/genstack.c b/genstack.c
index c552d04..c97e0c0 100644
--- a/genstack.c
+++ b/genstack.c
@@ -34,7 +34,11 @@ struct genstack *genstack_alloc(size_t sz)
 	if (sz == 0)
 		return NULL;
 
-	stk = malloc(sizeof(*stk));
+	/*
+	 * This is clearly an overkill; however, we must not use
+	 * malloc because it may not be thread-safe!
+	 */
+	stk = mmap(NULL, page_size(), mmap_prot, mmap_flags, -1, 0);
 	if (!stk)
 		return NULL;
 
@@ -61,7 +65,7 @@ struct genstack *genstack_alloc(size_t sz)
 void genstack_release(struct genstack *stk)
 {
 	munmap(stk->addr, stk->size);
-	free(stk);
+	munmap(stk, page_size());
 }
 
 /* Return the size of the usable stack region.  Suitable for providing
-- 
1.7.0.4
