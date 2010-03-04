From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 08/13][user-cr]: restart: Rename struct args.
Date: Wed, 3 Mar 2010 23:48:38 -0800
Message-ID: <20100304074838.GI29320@us.ibm.com>
References: <20100304074354.GA29320@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100304074354.GA29320-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Date: Mon, 1 Mar 2010 20:33:36 -0800
Subject: [PATCH 08/13][user-cr]: restart: Rename struct args.

Rename 'struct args' in restart.c to 'struct app_restart_args'. This
would enable us to distinguish this struct from the 'struct args' in
checkpoint.c when checkpoint/restart code is implemented as a library
interface

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 restart.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/restart.c b/restart.c
index 369e9e6..6994298 100644
--- a/restart.c
+++ b/restart.c
@@ -292,7 +292,7 @@ struct ckpt_ctx {
 	char container[BUFSIZE];
 	char tree[BUFSIZE];
 	char buf[BUFSIZE];
-	struct args *args;
+	struct app_restart_args *args;
 
 	char *freezer;
 };
@@ -371,7 +371,7 @@ struct pid_swap {
 	pid_t new;
 };
 
-struct args {
+struct app_restart_args {
 	int self;
 	int pids;
 	int pidns;
@@ -452,7 +452,7 @@ static inline int ckpt_cond_fail(struct ckpt_ctx *ctx, long mask)
 	return (ctx->args->fail & mask);
 }
 
-static void parse_args(struct args *args, int argc, char *argv[])
+static void parse_args(struct app_restart_args *args, int argc, char *argv[])
 {
 	static struct option opts[] = {
 		{ "help",	no_argument,		NULL, 'h' },
@@ -807,7 +807,7 @@ static int freezer_register(struct ckpt_ctx *ctx, pid_t pid)
 	return ret;
 }
 
-int app_restart(struct args *args)
+int app_restart(struct app_restart_args *args)
 {
 	struct ckpt_ctx ctx;
 	int ret;
@@ -918,7 +918,7 @@ int app_restart(struct args *args)
 
 int main(int argc, char *argv[])
 {
-	struct args args;
+	struct app_restart_args args;
 
 	/*
 	 * Initialize the log/error fds early so even parse_args() errors
-- 
1.6.0.4
