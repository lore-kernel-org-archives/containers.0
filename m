From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 2/9] cr_tests: fs: Add a do_ckpt utility
Date: Fri, 19 Feb 2010 18:18:50 -0800
Message-ID: <a5516d2e94b044e946ac039172a3d9cab0df0c1f.1266632319.git.matthltc@us.ibm.com>
References: <1266632337-13792-1-git-send-email-matthltc@us.ibm.com>
	<72d007906376ee6de7e97ed02f3d7aa814b8017b.1266632319.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <72d007906376ee6de7e97ed02f3d7aa814b8017b.1266632319.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
In-Reply-To: <72d007906376ee6de7e97ed02f3d7aa814b8017b.1266632319.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
References: <72d007906376ee6de7e97ed02f3d7aa814b8017b.1266632319.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Makes ./checkpoint-ready, waits for ./checkpoint-done, and exits.
This utility will be useful in a python test script to ensure that
we're not testing the checkpointability of python scripts and
instead we're checkpointing simple C tasks.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 fs/do_ckpt.c |   34 ++++++++++++++++++++++++++++++++++
 fs/module.mk |    2 +-
 2 files changed, 35 insertions(+), 1 deletions(-)
 create mode 100644 fs/do_ckpt.c

diff --git a/fs/do_ckpt.c b/fs/do_ckpt.c
new file mode 100644
index 0000000..6c96cae
--- /dev/null
+++ b/fs/do_ckpt.c
@@ -0,0 +1,34 @@
+#include <stdio.h>
+#include <stdlib.h>
+#include <errno.h>
+#include <unistd.h>
+#include <string.h>
+#include <getopt.h>
+
+/* open() */
+#include <sys/types.h>
+#include <sys/stat.h>
+#include <fcntl.h>
+
+#define LOG_FILE	"log.do_ckpt"
+#include "libfstest.h"
+
+int main(int argc, char** argv)
+{
+	/* FIXME eventually stdio streams should be harmless */
+	close(0);
+	logfp = fopen(LOG_FILE, "w");
+	if (!logfp) {
+		perror("could not open logfile");
+		exit(1);
+	}
+	dup2(fileno(logfp), 1); /* redirect stdout and stderr to the log file */
+	dup2(fileno(logfp), 2);
+	if (!move_to_cgroup("freezer", "1", getpid())) {
+		log_error("move_to_cgroup");
+		exit(2);
+	}
+
+	do_ckpt();
+	exit(EXIT_SUCCESS);
+}
diff --git a/fs/module.mk b/fs/module.mk
index d0a9f26..1af5815 100644
--- a/fs/module.mk
+++ b/fs/module.mk
@@ -1,5 +1,5 @@
 local_dir := fs
-local_progs := $(addprefix $(local_dir)/, file dir)
+local_progs := $(addprefix $(local_dir)/, file dir do_ckpt)
 
 sources += $(addprefix $(local_dir)/,libeptest.c)
 progs += $(local_progs)
-- 
1.6.3.3
