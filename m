From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 3/8] cr_tests: eventfd: use labels.[ch|lds] from libcrtest
Date: Tue,  9 Mar 2010 14:48:15 -0800
Message-ID: <d090f2ac4919cf161e4b0e05e589d18a4a5333f4.1268174893.git.matthltc@us.ibm.com>
References: <0c9ea18c7ffeb8688b31d01ce5f39a5a8c8a431f.1268174893.git.matthltc@us.ibm.com>
	<c30d7daea96f1706234a26c0df2a97069cfa14c8.1268174893.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <c30d7daea96f1706234a26c0df2a97069cfa14c8.1268174893.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
In-Reply-To: <0c9ea18c7ffeb8688b31d01ce5f39a5a8c8a431f.1268174893.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
References: <0c9ea18c7ffeb8688b31d01ce5f39a5a8c8a431f.1268174893.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 eventfd/libeptest.h |   46 +---------------------------------------------
 1 files changed, 1 insertions(+), 45 deletions(-)

diff --git a/eventfd/libeptest.h b/eventfd/libeptest.h
index b6629e8..3f1522e 100644
--- a/eventfd/libeptest.h
+++ b/eventfd/libeptest.h
@@ -6,6 +6,7 @@
 #include <sys/epoll.h>
 
 #include "libcrtest/libcrtest.h"
+#include "libcrtest/labels.h"
 
 extern FILE *logfp;
 
@@ -26,48 +27,3 @@ do { \
 
 /* like perror() except to the log */
 #define log_error(s) log("FAIL", "%s: %s\n", (s), strerror(errno))
-
-/*
- * A LABEL is a point in the program we can goto where it's interesting to
- * checkpoint. These enable us to have a set of labels that can be specified
- * on the commandline.
- */
-extern const char __attribute__((__section__(".LABELs"))) *first_label;
-extern const char __attribute__((__section__(".LABELs"))) *last_label;
-
-#define num_labels ((&last_label - &first_label) - 1)
-
-static inline const char * labels(int i)
-{
-	return (&first_label)[num_labels - i];
-}
-
-/* Print the labels that this program has to pout */
-void print_labels(FILE *pout);
-
-/* Signal ready for and await the checkpoint */
-void do_ckpt(void);
-
-/* The spot (LABEL or label number) where we should test checkpoint/restart */
-extern char const *ckpt_label;
-extern int ckpt_op_num;
-
-#define stringify(expr) #expr
-
-/* Label a spot in the code... */
-#define label(lbl, ret, action) \
-do { \
-	static char __attribute__((__section__(".LABELs"))) *___ ##lbl## _l = stringify(lbl); \
-	goto lbl ; \
-lbl: \
-\
-        log("INFO", "label: %s: \"%s\"\n", \
-		    labels(op_num), stringify(action)); \
-\
-	ret = action ; \
-\
-	if ((ckpt_op_num == op_num) || (ckpt_op_num == -1) || \
-	    (strcmp(ckpt_label, ___ ##lbl## _l) == 0)) \
-		do_ckpt(); \
-	op_num++; \
-} while(0)
-- 
1.6.3.3
