From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [RFC][PATCH 6/6][usercr] Rename common.h to cr_log.h
Date: Tue, 13 Apr 2010 17:53:22 -0700
Message-ID: <20100414005322.GF13532@us.ibm.com>
References: <20100414004927.GA13012@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100414004927.GA13012-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org


From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date: Tue, 13 Apr 2010 17:12:04 -0700
Subject: [RFC][PATCH 6/6][usercr] Rename common.h to cr_log.h

common.h used to be shared between checkpoint.c and restart.c.  Since all
the code is now in one file (cr_checkpoint.c), the name 'common.h' does not
make much sense.

The definitions in the file relate to logging, so rename to cr_log.h.

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 Makefile          |    2 +-
 checkpoint-main.c |    2 +-
 common.h          |  112 -----------------------------------------------------
 cr_checkpoint.c   |    2 +-
 cr_log.h          |  110 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 restart-main.c    |    2 +-
 6 files changed, 114 insertions(+), 116 deletions(-)
 delete mode 100644 common.h
 create mode 100644 cr_log.h

diff --git a/Makefile b/Makefile
index 205320a..f2c6b18 100644
--- a/Makefile
+++ b/Makefile
@@ -52,7 +52,7 @@ $(LIB_ECLONE):
 # restart needs to be thread-safe
 restart: CFLAGS += -D__REENTRANT -pthread
 
-$(CR_OBJS): common.h cr_checkpoint.h
+$(CR_OBJS): cr_log.h cr_checkpoint.h
 
 restart: cr_checkpoint.o restart-main.o
 	$(CC) -o $@ $^
diff --git a/checkpoint-main.c b/checkpoint-main.c
index b8f96a7..34eb827 100644
--- a/checkpoint-main.c
+++ b/checkpoint-main.c
@@ -10,7 +10,7 @@
 #include <linux/checkpoint.h>
 
 #include "cr_checkpoint.h"
-#include "common.h"
+#include "cr_log.h"
 
 static int global_uerrfd = -1;
 
diff --git a/common.h b/common.h
deleted file mode 100644
index 99b224d..0000000
--- a/common.h
+++ /dev/null
@@ -1,112 +0,0 @@
-#include <stdio.h>
-#include <signal.h>
-
-#define BUFSIZE  (4 * 4096)
-
-static inline void ckpt_msg(int fd, char *format, ...)
-{
-	va_list ap;
-	char *bufp;
-	if (fd < 0)
-		return;
-
-	va_start(ap, format);
-
-	bufp = malloc(BUFSIZE);
-	if(bufp) {
-		vsnprintf(bufp, BUFSIZE, format, ap);
-		write(fd, bufp, strlen(bufp));
-	}
-	free(bufp);
-
-	va_end(ap);
-}
-
-#define ckpt_perror(s) 							\
-	do {								\
-		ckpt_msg(global_uerrfd, s);				\
-		ckpt_msg(global_uerrfd, ": %s\n", strerror(errno));	\
-	} while (0)
-
-#ifdef CHECKPOINT_DEBUG
-#define ckpt_dbg(_format, _args...)					\
-	do {								\
-		if (global_debug)					\
-			ckpt_msg(global_uerrfd, "<%d>" _format, 	\
-					_gettid(), ##_args); 		\
-	} while (0)
-#define ckpt_dbg_cont(_format, _args...)				\
-	do {								\
-		if (global_debug)					\
-			ckpt_msg(global_uerrfd, _format, ##_args);	\
-	} while (0)
-#else
-#define ckpt_dbg(_format, _args...)  \
-	do { } while (0)
-#define ckpt_dbg_cont(_format, _args...)  \
-	do { } while (0)
-#endif
-
-#define ckpt_err(...)  \
-	ckpt_msg(global_uerrfd, __VA_ARGS__)
-
-#define ckpt_verbose(...)					\
-	do {							\
-		if (global_verbose)				\
-			ckpt_msg(global_ulogfd, __VA_ARGS__);	\
-	} while(0)
-
-struct signal_array {
-	int signum;
-	char *sigstr;
-};
-
-#define SIGNAL_ENTRY(signal)  { SIG ## signal, #signal }
-
-#define INIT_SIGNAL_ARRAY { 	\
-	{ 0, "NONE" },		\
-	SIGNAL_ENTRY(ALRM),	\
-	SIGNAL_ENTRY(HUP),	\
-	SIGNAL_ENTRY(INT),	\
-	SIGNAL_ENTRY(KILL),	\
-	SIGNAL_ENTRY(PIPE),	\
-	SIGNAL_ENTRY(POLL),	\
-	SIGNAL_ENTRY(PROF),	\
-	SIGNAL_ENTRY(TERM),	\
-	SIGNAL_ENTRY(USR1),	\
-	SIGNAL_ENTRY(USR2),	\
-	SIGNAL_ENTRY(VTALRM),	\
-	SIGNAL_ENTRY(STKFLT),	\
-	SIGNAL_ENTRY(PWR),	\
-	SIGNAL_ENTRY(WINCH),	\
-	SIGNAL_ENTRY(CHLD),	\
-	SIGNAL_ENTRY(URG),	\
-	SIGNAL_ENTRY(TTIN),	\
-	SIGNAL_ENTRY(TTOU),	\
-	SIGNAL_ENTRY(STOP),	\
-	SIGNAL_ENTRY(CONT),	\
-	SIGNAL_ENTRY(ABRT),	\
-	SIGNAL_ENTRY(FPE),	\
-	SIGNAL_ENTRY(ILL),	\
-	SIGNAL_ENTRY(QUIT),	\
-	SIGNAL_ENTRY(SEGV),	\
-	SIGNAL_ENTRY(TRAP),	\
-	SIGNAL_ENTRY(SYS),	\
-	SIGNAL_ENTRY(BUS),	\
-	SIGNAL_ENTRY(XCPU),	\
-	SIGNAL_ENTRY(XFSZ),	\
-	{ -1, "LAST" },		\
-}
-
-#define CKPT_COND_PIDZERO  0x1
-#define CKPT_COND_MNTPROC  0x2
-#define CKPT_COND_MNTPTY   0x4
-
-#define CKPT_COND_NONE     0
-#define CKPT_COND_ANY      ULONG_MAX
-
-/* default for skip/warn/fail */
-#define CKPT_COND_WARN     (CKPT_COND_MNTPROC | \
-			    CKPT_COND_MNTPTY)
-#define CKPT_COND_FAIL     (CKPT_COND_NONE)
-
diff --git a/cr_checkpoint.c b/cr_checkpoint.c
index e01c08e..272c54b 100644
--- a/cr_checkpoint.c
+++ b/cr_checkpoint.c
@@ -41,7 +41,7 @@
 #include "genstack.h"
 #include "compat.h"
 #include "cr_checkpoint.h"
-#include "common.h"
+#include "cr_log.h"
 
 /*
  * By default, 'restart' creates a new pid namespace in which the
diff --git a/cr_log.h b/cr_log.h
new file mode 100644
index 0000000..c971b74
--- /dev/null
+++ b/cr_log.h
@@ -0,0 +1,110 @@
+#include <stdio.h>
+#include <signal.h>
+
+#define BUFSIZE  (4 * 4096)
+
+static inline void ckpt_msg(int fd, char *format, ...)
+{
+	va_list ap;
+	char *bufp;
+	if (fd < 0)
+		return;
+
+	va_start(ap, format);
+
+	bufp = malloc(BUFSIZE);
+	if(bufp) {
+		vsnprintf(bufp, BUFSIZE, format, ap);
+		write(fd, bufp, strlen(bufp));
+	}
+	free(bufp);
+
+	va_end(ap);
+}
+
+#define ckpt_perror(s) 							\
+	do {								\
+		ckpt_msg(global_uerrfd, s);				\
+		ckpt_msg(global_uerrfd, ": %s\n", strerror(errno));	\
+	} while (0)
+
+#ifdef CHECKPOINT_DEBUG
+#define ckpt_dbg(_format, _args...)					\
+	do {								\
+		if (global_debug)					\
+			ckpt_msg(global_uerrfd, "<%d>" _format, 	\
+					_gettid(), ##_args); 		\
+	} while (0)
+#define ckpt_dbg_cont(_format, _args...)				\
+	do {								\
+		if (global_debug)					\
+			ckpt_msg(global_uerrfd, _format, ##_args);	\
+	} while (0)
+#else
+#define ckpt_dbg(_format, _args...)  \
+	do { } while (0)
+#define ckpt_dbg_cont(_format, _args...)  \
+	do { } while (0)
+#endif
+
+#define ckpt_err(...)  \
+	ckpt_msg(global_uerrfd, __VA_ARGS__)
+
+#define ckpt_verbose(...)					\
+	do {							\
+		if (global_verbose)				\
+			ckpt_msg(global_ulogfd, __VA_ARGS__);	\
+	} while(0)
+
+struct signal_array {
+	int signum;
+	char *sigstr;
+};
+
+#define SIGNAL_ENTRY(signal)  { SIG ## signal, #signal }
+
+#define INIT_SIGNAL_ARRAY { 	\
+	{ 0, "NONE" },		\
+	SIGNAL_ENTRY(ALRM),	\
+	SIGNAL_ENTRY(HUP),	\
+	SIGNAL_ENTRY(INT),	\
+	SIGNAL_ENTRY(KILL),	\
+	SIGNAL_ENTRY(PIPE),	\
+	SIGNAL_ENTRY(POLL),	\
+	SIGNAL_ENTRY(PROF),	\
+	SIGNAL_ENTRY(TERM),	\
+	SIGNAL_ENTRY(USR1),	\
+	SIGNAL_ENTRY(USR2),	\
+	SIGNAL_ENTRY(VTALRM),	\
+	SIGNAL_ENTRY(STKFLT),	\
+	SIGNAL_ENTRY(PWR),	\
+	SIGNAL_ENTRY(WINCH),	\
+	SIGNAL_ENTRY(CHLD),	\
+	SIGNAL_ENTRY(URG),	\
+	SIGNAL_ENTRY(TTIN),	\
+	SIGNAL_ENTRY(TTOU),	\
+	SIGNAL_ENTRY(STOP),	\
+	SIGNAL_ENTRY(CONT),	\
+	SIGNAL_ENTRY(ABRT),	\
+	SIGNAL_ENTRY(FPE),	\
+	SIGNAL_ENTRY(ILL),	\
+	SIGNAL_ENTRY(QUIT),	\
+	SIGNAL_ENTRY(SEGV),	\
+	SIGNAL_ENTRY(TRAP),	\
+	SIGNAL_ENTRY(SYS),	\
+	SIGNAL_ENTRY(BUS),	\
+	SIGNAL_ENTRY(XCPU),	\
+	SIGNAL_ENTRY(XFSZ),	\
+	{ -1, "LAST" },		\
+}
+
+#define CKPT_COND_PIDZERO  0x1
+#define CKPT_COND_MNTPROC  0x2
+#define CKPT_COND_MNTPTY   0x4
+
+#define CKPT_COND_NONE     0
+#define CKPT_COND_ANY      ULONG_MAX
+
+/* default for skip/warn/fail */
+#define CKPT_COND_WARN     (CKPT_COND_MNTPROC | CKPT_COND_MNTPTY)
+#define CKPT_COND_FAIL     (CKPT_COND_NONE)
diff --git a/restart-main.c b/restart-main.c
index 1f1a749..c3100ac 100644
--- a/restart-main.c
+++ b/restart-main.c
@@ -9,7 +9,7 @@
 #include <getopt.h>
 
 #include "cr_checkpoint.h"
-#include "common.h"
+#include "cr_log.h"
 
 static int global_ulogfd;
 static int global_uerrfd;
-- 
1.6.6.1
