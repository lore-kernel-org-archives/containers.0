From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC PATCH user-cr] remount /proc for new pidns
Date: Thu, 10 Dec 2009 13:04:38 -0600
Message-ID: <20091210190438.GA19528@us.ibm.com>
References: <20091204020610.GA17971@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20091204020610.GA17971-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Serge E. Hallyn (serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> Not doing this can be a pain for restarted software which relies on
> proc...

How embarrassing...  if we don't unshare(CLONE_NEWNS) for pidns we
mess up the proc mount for the whole system...  Pls use this version
instead.

From 57588540937a892a49b692a4630b34d5984a8792 Mon Sep 17 00:00:00 2001
From: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date: Thu, 3 Dec 2009 21:40:30 -0600
Subject: [PATCH 1/1] remount /proc for new pidns

Changelog: Dec 10: unshare(CLONE_NEWNS) for --pidns

Signed-off-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 restart.c |   27 ++++++++++++++++++++++-----
 1 files changed, 22 insertions(+), 5 deletions(-)

diff --git a/restart.c b/restart.c
index ddd0a63..6c9ac5d 100644
--- a/restart.c
+++ b/restart.c
@@ -777,6 +777,14 @@ int main(int argc, char *argv[])
 		exit(1);
 	}
 
+	if (args.pty || args.pidns) {
+		ret = unshare(CLONE_NEWNS);
+		if (ret) {
+			perror("unshare mounts ns (for -pty)");
+			exit(1);
+		}
+	}
+
 	/* private devpts namespace? */
 	if (args.pty) {
 		struct stat ptystat;
@@ -790,11 +798,6 @@ int main(int argc, char *argv[])
 			printf("Error: /dev/ptmx must be a link to /dev/pts/ptmx\n");
 			exit(1);
 		}
-		ret = unshare(CLONE_NEWNS);
-		if (ret) {
-			perror("unshare mounts ns (for -pty)");
-			exit(1);
-		}
 		ret = mount("pts", "/dev/pts", "devpts", 0, "newinstance");
 		if (ret) {
 			perror("mount -t devpts -o newinstance");
@@ -1005,6 +1008,13 @@ static int ckpt_probe_child(pid_t pid, char *str)
 static int __ckpt_coordinator(void *arg)
 {
 	struct ckpt_ctx *ctx = (struct ckpt_ctx *) arg;
+	int ret;
+
+	ret = mount("proc", "/proc", "proc", 0, NULL);
+	if (ret) {
+		perror("mount -t proc proc /proc");
+		exit(1);
+	}
 
 	if (!ctx->args->wait)
 		close(ctx->pipe_coord[0]);
@@ -1869,6 +1879,13 @@ int ckpt_fork_stub(void *data)
 	struct task *task = (struct task *) data;
 	struct ckpt_ctx *ctx = task->ctx;
 
+	if (task->flags & TASK_NEWPID) {
+		int ret = mount("proc", "/proc", "proc", 0, NULL);
+		if (ret) {
+			perror("mount -t proc");
+			exit(1);
+		}
+	}
 	/*
 	 * In restart into a new pid namespace (--pidns), coordinator
 	 * is the container init, hence if it terminated permatutely
-- 
1.6.4.4
