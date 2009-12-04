From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [RFC PATCH user-cr] remount /proc for new pidns
Date: Thu, 3 Dec 2009 20:06:10 -0600
Message-ID: <20091204020610.GA17971@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
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

Not doing this can be a pain for restarted software which relies on
proc...

Signed-off-by: root <root-Z+ypJZ3u8cnx6HRWoRZK3AC/G2K4zDHf@public.gmane.org>
---
 restart.c |   14 ++++++++++++++
 1 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/restart.c b/restart.c
index d25561a..cefe639 100644
--- a/restart.c
+++ b/restart.c
@@ -1005,6 +1005,13 @@ static int ckpt_probe_child(pid_t pid, char *str)
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
@@ -1869,6 +1876,13 @@ int ckpt_fork_stub(void *data)
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
