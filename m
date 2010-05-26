From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/3] [RFC] user-cr: Add a basic hooks system
Date: Wed, 26 May 2010 07:42:34 -0700
Message-ID: <1274884956-21005-2-git-send-email-danms@us.ibm.com>
References: <1274884956-21005-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1274884956-21005-1-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
List-Id: containers.vger.kernel.org

In order to allow users to perform parts of the checkpoint/restore
themselves, we need a system of "hooks" for the user-cr applications to
call at various times.  This patch adds a little bit of infrastructure for
that, and defines two hooks: "checkpoint-pre" and "restart-post".  The
checkpoint-pre hook gets run before we call sys_checkpoint() and the
restart-post hook gets run after we've restored the task(s).

The infrastructure calls the hooks by name by exec'ing a shell.  The
environment is set up with information about the task at hand, with
variables prefixed by "CR_".  For now, only two are defined. CR_ROOT_PID
is the pid of the root of the checkpoint or the pid of the root of the
restored task tree.  CR_BASE_FILE is the name of the file we're
checkpointing to or restoring from (or empty if using stdio).

I think it's to be expected that any checkpointing or restarting done
by the hooks will be stored separately from the main checkpoint file,
so I expect that at least initially we'll use a permutation of the base
file's name for those.

Included are two shell scripts in the hooks/ directory which can be
modified to add the actual work to be done (and potentially some logic
to decide when and how to run some of them).

Thoughts?

Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 Makefile             |    5 +-
 app-checkpoint.h     |    7 +++
 checkpoint-main.c    |    1 +
 checkpoint.c         |    7 +++
 hooks.c              |  118 ++++++++++++++++++++++++++++++++++++++++++++++++++
 hooks.h              |   21 +++++++++
 hooks/checkpoint-pre |    5 ++
 hooks/restart-post   |    5 ++
 restart-main.c       |    1 +
 restart.c            |   11 ++++-
 10 files changed, 178 insertions(+), 3 deletions(-)
 create mode 100644 hooks.c
 create mode 100644 hooks.h
 create mode 100644 hooks/checkpoint-pre
 create mode 100644 hooks/restart-post

diff --git a/Makefile b/Makefile
index 6c9ff93..ea86406 100644
--- a/Makefile
+++ b/Makefile
@@ -45,6 +45,7 @@ LDLIBS = -lm
 
 all: $(PROGS)
 	@$(MAKE) -C test
+	@$(MAKE) -C hooks
 
 $(LIB_ECLONE):
 	$(AR) ruv $(LIB_ECLONE) $^
@@ -54,9 +55,9 @@ restart: CFLAGS += -D__REENTRANT -pthread
 
 $(CR_OBJS): common.h app-checkpoint.h
 
-restart: restart.o restart-main.o
+restart: restart.o restart-main.o hooks.o
 
-checkpoint: checkpoint.o checkpoint-main.o
+checkpoint: checkpoint.o checkpoint-main.o hooks.o
 
 # eclone() is architecture specific
 ifneq ($(SUBARCH),)
diff --git a/app-checkpoint.h b/app-checkpoint.h
index 8c8ebbb..fe08560 100644
--- a/app-checkpoint.h
+++ b/app-checkpoint.h
@@ -1,8 +1,12 @@
+#ifndef __APP_CHECKPOINT_H
+#define __APP_CHECKPOINT_H
+
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
 
 struct app_checkpoint_args {
 	int outfd;
+	char *output;
 	int logfd;
 	int uerrfd;
 	int container;
@@ -24,6 +28,7 @@ struct app_restart_args {
 	char *freezer;
 	int keep_frozen;
 	int infd;
+	char *input;
 	int klogfd;
 	int ulogfd;
 	int uerrfd;
@@ -44,3 +49,5 @@ extern int app_checkpoint(int pid, unsigned long flags,
 				struct app_checkpoint_args *args);
 
 extern int app_restart(struct app_restart_args *args);
+
+#endif
diff --git a/checkpoint-main.c b/checkpoint-main.c
index 24d89eb..1329f84 100644
--- a/checkpoint-main.c
+++ b/checkpoint-main.c
@@ -131,6 +131,7 @@ static void parse_args(struct app_checkpoint_args *args, int argc, char *argv[])
 			ckpt_perror("open output file");
 			exit(1);
 		}
+		args->output = output;
 	}
 
 	if (logfile && args->logfd >= 0) {
diff --git a/checkpoint.c b/checkpoint.c
index e0290c9..2a36df0 100644
--- a/checkpoint.c
+++ b/checkpoint.c
@@ -23,6 +23,7 @@
 
 #include "app-checkpoint.h"
 #include "common.h"
+#include "hooks.h"
 
 static int global_uerrfd = -1;
 
@@ -36,6 +37,12 @@ int app_checkpoint(int pid, unsigned long flags,
 {
 	int ret;
 
+	ret = call_checkpoint_hook("pre", pid, args);
+	if (ret) {
+		ckpt_err("Hook checkpoint-pre failed: %i\n", ret);
+		return ret;
+	}
+
 	global_uerrfd = args->uerrfd;
 
 	/* output file descriptor (default: stdout) */
diff --git a/hooks.c b/hooks.c
new file mode 100644
index 0000000..c55c211
--- /dev/null
+++ b/hooks.c
@@ -0,0 +1,118 @@
+/*
+ *  hooks.c: implementation of standard hook-calling mechanism
+ *
+ *  Copyright 2010 IBM Corporation
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+#define _GNU_SOURCE
+#include <stdio.h>
+#include <string.h>
+#include <unistd.h>
+#include <stdlib.h>
+#include <errno.h>
+#include <sys/types.h>
+#include <sys/wait.h>
+
+#include "app-checkpoint.h"
+
+static int call_hook(const char *hook, char *const env[])
+{
+	int pid;
+	int ret;
+	int status;
+
+	pid = fork();
+	if (!pid) {
+		ret = execle("/bin/sh", "/bin/sh", "-c", hook, NULL, env);
+		perror("execle");
+		exit(ret);
+	}
+
+	ret = waitpid(pid, &status, 0);
+	if (ret < 0)
+		return ret;
+
+	return WEXITSTATUS(status);
+}
+
+#define RESTART_HOOK_ENV_LEN 3
+
+int call_restart_hook(const char *hook, int root_pid,
+		      struct app_restart_args *args)
+{
+	char *env[RESTART_HOOK_ENV_LEN+1];
+	char *hook_cmd = NULL;
+	int ret;
+	int i = 0;
+
+	ret = asprintf(&env[i++], "PATH=%s", getenv("PATH"));
+	if (ret < 0)
+		goto err;
+
+	ret = asprintf(&env[i++], "CR_ROOT_PID=%i", root_pid);
+	if (ret < 0)
+		goto err;
+
+	ret = asprintf(&env[i++], "CR_BASE_FILE=%s",
+		       args->input ? args->input : "");
+	if (ret < 0)
+		goto err;
+
+	env[RESTART_HOOK_ENV_LEN] = NULL;
+
+	ret = asprintf(&hook_cmd, "restart-%s", hook);
+	if (ret < 0)
+		goto err;
+
+	return call_hook(hook_cmd, env);
+ err:
+	for (i = 0; i < RESTART_HOOK_ENV_LEN; i++)
+		free(env[i]);
+
+	free(hook_cmd);
+
+	return -ENOMEM;
+}
+
+#define CHECKPOINT_HOOK_ENV_LEN 3
+
+int call_checkpoint_hook(const char *hook, int root_pid,
+			 struct app_checkpoint_args *args)
+{
+	char *env[CHECKPOINT_HOOK_ENV_LEN+1];
+	char *hook_cmd = NULL;
+	int ret;
+	int i = 0;
+
+	ret = asprintf(&env[i++], "PATH=%s", getenv("PATH"));
+	if (ret < 0)
+		goto err;
+
+	ret = asprintf(&env[i++], "CR_ROOT_PID=%i", root_pid);
+	if (ret < 0)
+		goto err;
+
+	ret = asprintf(&env[i++], "CR_BASE_FILE=%s",
+		       args->output ? args->output : "");
+	if (ret < 0)
+		goto err;
+
+	env[CHECKPOINT_HOOK_ENV_LEN] = NULL;
+
+	ret = asprintf(&hook_cmd, "checkpoint-%s", hook);
+	if (ret < 0)
+		goto err;
+
+	return call_hook(hook_cmd, env);
+ err:
+	for (i = 0; i < CHECKPOINT_HOOK_ENV_LEN; i++)
+		free(env[i]);
+
+	free(hook_cmd);
+
+	return -ENOMEM;
+}
diff --git a/hooks.h b/hooks.h
new file mode 100644
index 0000000..132d60e
--- /dev/null
+++ b/hooks.h
@@ -0,0 +1,21 @@
+/*
+ *  hooks.h: interfaces for calling hooks
+ *
+ *  Copyright 2010 IBM Corporation
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+#ifndef __HOOKS_H
+#define __HOOKS_H
+
+#include "app-checkpoint.h"
+
+int call_restart_hook(const char *hook, int root_pid,
+		      struct app_restart_args *args);
+int call_checkpoint_hook(const char *hook, int root_pid,
+			 struct app_checkpoint_args *args);
+
+#endif
diff --git a/hooks/checkpoint-pre b/hooks/checkpoint-pre
new file mode 100644
index 0000000..c586275
--- /dev/null
+++ b/hooks/checkpoint-pre
@@ -0,0 +1,5 @@
+#!/bin/bash
+
+echo "========= CHECKPOINT PRE HOOK ============"
+
+echo "========= CHECKPOINT PRE HOOK ============"
diff --git a/hooks/restart-post b/hooks/restart-post
new file mode 100644
index 0000000..dbce024
--- /dev/null
+++ b/hooks/restart-post
@@ -0,0 +1,5 @@
+#!/bin/bash
+
+echo "========= RESTART POST HOOK ============"
+
+echo "========= RESTART POST HOOK ============"
diff --git a/restart-main.c b/restart-main.c
index 656d49f..a019bc3 100644
--- a/restart-main.c
+++ b/restart-main.c
@@ -279,6 +279,7 @@ static void parse_args(struct app_restart_args *args, int argc, char *argv[])
 			ckpt_perror("open input file");
 			exit(1);
 		}
+		args->input = strdup(input);
 	}
 
 	if (klogfile && args->klogfd >= 0) {
diff --git a/restart.c b/restart.c
index c5c65a2..c29206a 100644
--- a/restart.c
+++ b/restart.c
@@ -42,6 +42,7 @@
 #include "compat.h"
 #include "app-checkpoint.h"
 #include "common.h"
+#include "hooks.h"
 
 /*
  * By default, 'restart' creates a new pid namespace in which the
@@ -877,8 +878,10 @@ static int ckpt_coordinator_pidns(struct ckpt_ctx *ctx)
 	ctx->args->copy_status = copy;
 
 	ret = ckpt_coordinator_status(ctx);
+	if (ret != 0)
+		return ret;
 
-	if (ret == 0 && ctx->args->wait)
+	if (ctx->args->wait)
 		ret = ckpt_collect_child(ctx);
 
 	return ret;
@@ -928,6 +931,12 @@ static int ckpt_coordinator(struct ckpt_ctx *ctx)
 		exit(1);
 	}
 
+	ret = call_restart_hook("post", root_pid, ctx->args);
+	if (ret < 0) {
+		printf("Hook restart-post failed: %i\n", ret);
+		return ret;
+	}
+
 	ckpt_verbose("Success\n");
 	ckpt_dbg("restart succeeded\n");
 
-- 
1.7.0.4
