From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 1/2][LXC] Rename --directory option to --statefile
Date: Wed, 24 Feb 2010 00:41:08 -0800
Message-ID: <20100224084108.GG18758@us.ibm.com>
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
To: serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org, clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org


----
From 94fe79c36ac3aed69c8d97f8e4d17c9b02961b97 Mon Sep 17 00:00:00 2001
From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date: Tue, 23 Feb 2010 17:47:51 -0800
Subject: [PATCH 1/2] Rename --directory option to --statefile

[See following mail for an intro to this patch set

https://lists.linux-foundation.org/pipermail/containers/2010-February/023048.html]

The --directory is misleading since the option seems to expect
an checkpoint image file.

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 src/lxc/lxc_restart.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/src/lxc/lxc_restart.c b/src/lxc/lxc_restart.c
index 7db1d85..83d3d7b 100644
--- a/src/lxc/lxc_restart.c
+++ b/src/lxc/lxc_restart.c
@@ -52,7 +52,7 @@ static int my_checker(const struct lxc_arguments* args)
 static int my_parser(struct lxc_arguments* args, int c, char* arg)
 {
 	switch (c) {
-	case 'd': args->statefile = arg; break;
+	case 'i': args->statefile = arg; break;
 	case 'f': args->rcfile = arg; break;
 	case 'p': args->flags = LXC_FLAG_PAUSE; break;
 	case 's': return lxc_config_define_add(&defines, arg);
@@ -62,7 +62,7 @@ static int my_parser(struct lxc_arguments* args, int c, char* arg)
 }
 
 static const struct option my_longopts[] = {
-	{"directory", required_argument, 0, 'd'},
+	{"statefile", required_argument, 0, 'i'},
 	{"rcfile", required_argument, 0, 'f'},
 	{"pause", no_argument, 0, 'p'},
 	{"define", required_argument, 0, 's'},
@@ -72,14 +72,14 @@ static const struct option my_longopts[] = {
 static struct lxc_arguments my_args = {
 	.progname = "lxc-restart",
 	.help     = "\
---name=NAME --directory STATEFILE\n\
+--name=NAME --statefile STATEFILE\n\
 \n\
-lxc-restart restarts from STATEFILE the NAME container\n\
+lxc-restart restarts from checkpoint image STATEFILE the NAME container\n\
 \n\
 Options :\n\
   -n, --name=NAME      NAME for name of the container\n\
   -p, --pause          do not release the container after the restart\n\
-  -d, --directory=STATEFILE for name of statefile\n\
+  -i, --statefile=STATEFILE for name of statefile\n\
   -f, --rcfile=FILE Load configuration file FILE\n\
   -s, --define KEY=VAL Assign VAL to configuration variable KEY\n",
 	.options  = my_longopts,
-- 
1.6.6.1
