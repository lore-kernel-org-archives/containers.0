From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 2/6][v3][lxc] lxc_restart: Add --statefile option
Date: Wed, 31 Mar 2010 18:55:54 -0700
Message-ID: <20100401015554.GB25712@us.ibm.com>
References: <20100401015503.GA25228@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100401015503.GA25228-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org


From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date: Sat, 27 Mar 2010 00:08:17 -0700
Subject: [PATCH 2/6][v3][lxc] lxc_restart: Add --statefile option

The existing --directory option to lxc_restart expects the checkpoint state
to be a directory. USERCR however uses a single regular file to store the
checkpoint image. So add a --statefile option to enable checkpointing and
restarting applications using USERCR.

Depending on how the application was checkpointed, users should specify
either --statefile=STATEFILE or the --directory=STATEFILE option (but not
both).

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 src/lxc/lxc_restart.c |   30 +++++++++++++++++++++++-------
 1 files changed, 23 insertions(+), 7 deletions(-)

diff --git a/src/lxc/lxc_restart.c b/src/lxc/lxc_restart.c
index 7db1d85..4be6f92 100644
--- a/src/lxc/lxc_restart.c
+++ b/src/lxc/lxc_restart.c
@@ -38,11 +38,19 @@
 lxc_log_define(lxc_restart_ui, lxc_restart);
 
 static struct lxc_list defines;
+static char *statedir;
 
 static int my_checker(const struct lxc_arguments* args)
 {
-	if (!args->statefile) {
-		lxc_error(args, "no statefile specified");
+	int d, f;
+
+	/* make them boolean */
+	d = !!(statedir);
+	f = !!(args->statefile);
+
+	if (!(d ^ f)) {
+		lxc_error(args, "Must specify exactly one of --directory "
+				"and --statefile options");
 		return -1;
 	}
 
@@ -52,8 +60,9 @@ static int my_checker(const struct lxc_arguments* args)
 static int my_parser(struct lxc_arguments* args, int c, char* arg)
 {
 	switch (c) {
-	case 'd': args->statefile = arg; break;
+	case 'd': statedir = arg; break;
 	case 'f': args->rcfile = arg; break;
+	case 'S': args->statefile = arg; break;
 	case 'p': args->flags = LXC_FLAG_PAUSE; break;
 	case 's': return lxc_config_define_add(&defines, arg);
 	}
@@ -66,21 +75,24 @@ static const struct option my_longopts[] = {
 	{"rcfile", required_argument, 0, 'f'},
 	{"pause", no_argument, 0, 'p'},
 	{"define", required_argument, 0, 's'},
+	{"statefile", required_argument, 0, 'S'},
 	LXC_COMMON_OPTIONS
 };
 
 static struct lxc_arguments my_args = {
 	.progname = "lxc-restart",
 	.help     = "\
---name=NAME --directory STATEFILE\n\
+--name=NAME --directory STATEFILE (deprecated)\n\
+\tlxc_restart --name=NAME --statefile=STATEFILE\n\
 \n\
 lxc-restart restarts from STATEFILE the NAME container\n\
 \n\
 Options :\n\
   -n, --name=NAME      NAME for name of the container\n\
   -p, --pause          do not release the container after the restart\n\
-  -d, --directory=STATEFILE for name of statefile\n\
+  -d, --directory=STATEFILE for name of statefile (legacy mode, deprecated)\n\
   -f, --rcfile=FILE Load configuration file FILE\n\
+  -i, --statefile=STATEFILE Load the application state from STATEFILE (libcr mode)\n\
   -s, --define KEY=VAL Assign VAL to configuration variable KEY\n",
 	.options  = my_longopts,
 	.parser   = my_parser,
@@ -90,6 +102,7 @@ Options :\n\
 int main(int argc, char *argv[])
 {
 	char *rcfile = NULL;
+	const char *statefile;
 	struct lxc_conf *conf;
 
 	lxc_list_init(&defines);
@@ -131,6 +144,9 @@ int main(int argc, char *argv[])
 	if (lxc_config_define_load(&defines, conf))
 		return -1;
 
-	return lxc_restart(my_args.name, my_args.statefile, conf,
-			   my_args.flags);
+	statefile = my_args.statefile;
+	if (statedir)
+		statefile = statedir;
+
+	return lxc_restart(my_args.name, statefile, conf, my_args.flags);
 }
-- 
1.6.0.4
