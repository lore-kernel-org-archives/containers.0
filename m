From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 11/13][user-cr]: checkpoint: Rename struct args
Date: Wed, 3 Mar 2010 23:50:01 -0800
Message-ID: <20100304075001.GL29320@us.ibm.com>
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
Date: Wed, 3 Mar 2010 11:24:54 -0800
Subject: [PATCH 11/13][user-cr]: checkpoint: Rename struct args

Rename 'struct args' in checkpoint.c to 'struct app_checkpoint_args'.
This would give the struct a more specific name when checkpoint/restart
code is implemented as a library interface.

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 checkpoint.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/checkpoint.c b/checkpoint.c
index ca77d8b..d5fcfee 100644
--- a/checkpoint.c
+++ b/checkpoint.c
@@ -39,7 +39,7 @@ static char usage_str[] =
 "  -v,--verbose          verbose output\n"
 "";
 
-struct args {
+struct app_checkpoint_args {
 	int outfd;
 	int logfd;
 	int container;
@@ -69,7 +69,7 @@ static int str2num(char *str)
 	return num;
 }
 
-static void parse_args(struct args *args, int argc, char *argv[])
+static void parse_args(struct app_checkpoint_args *args, int argc, char *argv[])
 {
 	static struct option opts[] = {
 		{ "help",	no_argument,		NULL, 'h' },
@@ -162,7 +162,7 @@ static void parse_args(struct args *args, int argc, char *argv[])
 
 int main(int argc, char *argv[])
 {
-	struct args args;
+	struct app_checkpoint_args args;
 	unsigned long flags = 0;
 	pid_t pid;
 	int ret;
-- 
1.6.0.4
