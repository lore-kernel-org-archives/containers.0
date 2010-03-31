From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 3/6][lxc][v3] lxc_checkpoint: Add --statefile option
Date: Wed, 31 Mar 2010 00:07:52 -0700
Message-ID: <20100331070752.GC23567@us.ibm.com>
References: <20100331070440.GA21570@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100331070440.GA21570-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Date: Wed, 10 Mar 2010 22:24:17 -0800
Subject: [PATCH 3/6][lxc][v3] lxc_checkpoint: Add --statefile option

The existing --directory option to lxc_checkpoint expects to save the
checkpoint state in a directory. USERCR however uses a single regular
file to store the checkpoint image. So add a --statefile option to enable
checkpointing and restarting applications using USERCR.

Users should specify either --statefile or --directory option (but not both)
to select the file/directory where the application state will be stored.

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 src/lxc/lxc_checkpoint.c |   40 +++++++++++++++++++++++++++++-----------
 1 files changed, 29 insertions(+), 11 deletions(-)

diff --git a/src/lxc/lxc_checkpoint.c b/src/lxc/lxc_checkpoint.c
index a8c74a9..5e8506f 100644
--- a/src/lxc/lxc_checkpoint.c
+++ b/src/lxc/lxc_checkpoint.c
@@ -37,12 +37,21 @@
 
 lxc_log_define(lxc_checkpoint_ui, lxc_checkpoint);
 
+static char *statedir;
+
 static int my_checker(const struct lxc_arguments* args)
 {
-	if (!args->statefile) {
-		lxc_error(args, "no statefile specified");
-		return -1;
-	}
+	int d, f;
+	
+	/* make them boolean */
+	d = !!(statedir);
+	f = !!(args->statefile);
+
+        if (!(d ^ f)) {
+                lxc_error(args, "Must specify exactly one of --directory "
+                                "and --statefile options");
+                return -1;
+        }
 
 	return 0;
 }
@@ -52,7 +61,8 @@ static int my_parser(struct lxc_arguments* args, int c, char* arg)
 	switch (c) {
 	case 'k': args->flags = LXC_FLAG_HALT; break;
 	case 'p': args->flags = LXC_FLAG_PAUSE; break;
-	case 'd': args->statefile = arg; break;
+	case 'd': statedir = arg; break;
+	case 'S': args->statefile = arg; break;
 	}
 	return 0;
 }
@@ -61,13 +71,15 @@ static const struct option my_longopts[] = {
 	{"kill", no_argument, 0, 'k'},
 	{"pause", no_argument, 0, 'p'},
 	{"directory", required_argument, 0, 'd'},
+	{"statefile", required_argument, 0, 'S'},
 	LXC_COMMON_OPTIONS
 };
 
 static struct lxc_arguments my_args = {
 	.progname = "lxc-checkpoint",
 	.help     = "\
---name=NAME --directory STATEFILE\n\
+--name=NAME --directory STATEFILE (deprecated)\n\
+\tlxc_checkpoint --name=NAME --statefile=STATEFILE\n\
 \n\
 lxc-checkpoint checkpoints in STATEFILE the NAME container\n\
 \n\
@@ -75,7 +87,8 @@ Options :\n\
   -n, --name=NAME      NAME for name of the container\n\
   -k, --kill           stop the container after checkpoint\n\
   -p, --pause          don't unfreeze the container after the checkpoint\n\
-  -d, --directory=STATEFILE where to store the statefile\n",
+  -d, --directory=STATEFILE where to store the statefile (deprecated)\n\
+  -i, --statefile=STATEFILE where to store the checkpoint-image (LIBCR mode)\n",
 
 	.options  = my_longopts,
 	.parser   = my_parser,
@@ -97,6 +110,7 @@ static int create_statefile(const char *dir)
 int main(int argc, char *argv[])
 {
 	int ret;
+	const char *statefile;
 
 	ret = lxc_arguments_parse(&my_args, argc, argv);
 	if (ret)
@@ -107,11 +121,15 @@ int main(int argc, char *argv[])
 	if (ret)
 		return ret;
 
-	ret = create_statefile(my_args.statefile);
-	if (ret)
-		return ret;
+	statefile = my_args.statefile;
+	if (statedir) {
+		statefile = statedir;
+		ret = create_statefile(statefile);
+		if (ret)
+			return ret;
+	}
 
-	ret = lxc_checkpoint(my_args.name, my_args.statefile, my_args.flags);
+	ret = lxc_checkpoint(my_args.name, statefile, my_args.flags);
 	if (ret)
 		ERROR("failed to checkpoint '%s'", my_args.name);
 	else
-- 
1.6.6.1
