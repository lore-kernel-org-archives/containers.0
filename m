From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 2/5][lxc] lxc_restart: Add --image option
Date: Thu, 18 Mar 2010 23:40:46 -0700
Message-ID: <20100319064046.GC25732@us.ibm.com>
References: <20100319063912.GA25732@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100319063912.GA25732-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Date: Wed, 10 Mar 2010 21:59:39 -0800
Subject: [PATCH 2/5][lxc] lxc_restart: Add --image option

The existing --directory option to lxc_restart expects the checkpoint state
to be a directory. USERCR however uses a single regular file to store the
checkpoint image. So add a --image option to enable checkpointing and
restarting applications using USERCR.

Depending on how the application was checkpointed, users should specify
either --image=CHECKPOINT-IMAGE or the --directory=STATEFILE option (but not
both).

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 src/lxc/arguments.h   |    1 +
 src/lxc/lxc_restart.c |   29 ++++++++++++++++++++++-------
 2 files changed, 23 insertions(+), 7 deletions(-)

diff --git a/src/lxc/arguments.h b/src/lxc/arguments.h
index 3bc027d..30953ee 100644
--- a/src/lxc/arguments.h
+++ b/src/lxc/arguments.h
@@ -45,6 +45,7 @@ struct lxc_arguments {
 	int daemonize;
 	const char *rcfile;
 	const char *statefile;
+	const char *imagefile;
 
 	/* for lxc-checkpoint */
 	int flags;
diff --git a/src/lxc/lxc_restart.c b/src/lxc/lxc_restart.c
index 7db1d85..39f7ea8 100644
--- a/src/lxc/lxc_restart.c
+++ b/src/lxc/lxc_restart.c
@@ -41,10 +41,17 @@ static struct lxc_list defines;
 
 static int my_checker(const struct lxc_arguments* args)
 {
-	if (!args->statefile) {
-		lxc_error(args, "no statefile specified");
-		return -1;
-	}
+	int i, s;
+	
+	/* make them boolean */
+	i = !!(args->imagefile);
+	s = !!(args->statefile);
+
+        if (!(i ^ s)) {
+                lxc_error(args, "Must specify exactly one of --directory "
+                                "and --image options");
+                return -1;
+        }
 
 	return 0;
 }
@@ -54,6 +61,7 @@ static int my_parser(struct lxc_arguments* args, int c, char* arg)
 	switch (c) {
 	case 'd': args->statefile = arg; break;
 	case 'f': args->rcfile = arg; break;
+	case 'i': args->imagefile = arg; break;
 	case 'p': args->flags = LXC_FLAG_PAUSE; break;
 	case 's': return lxc_config_define_add(&defines, arg);
 	}
@@ -66,6 +74,7 @@ static const struct option my_longopts[] = {
 	{"rcfile", required_argument, 0, 'f'},
 	{"pause", no_argument, 0, 'p'},
 	{"define", required_argument, 0, 's'},
+	{"image", required_argument, 0, 'i'},
 	LXC_COMMON_OPTIONS
 };
 
@@ -73,14 +82,16 @@ static struct lxc_arguments my_args = {
 	.progname = "lxc-restart",
 	.help     = "\
 --name=NAME --directory STATEFILE\n\
+\tlxc_restart --name=NAME --image CHECKPOINT-IMAGE\n\
 \n\
 lxc-restart restarts from STATEFILE the NAME container\n\
 \n\
 Options :\n\
   -n, --name=NAME      NAME for name of the container\n\
   -p, --pause          do not release the container after the restart\n\
-  -d, --directory=STATEFILE for name of statefile\n\
+  -d, --directory=STATEFILE for name of statefile(legacy mode)\n\
   -f, --rcfile=FILE Load configuration file FILE\n\
+  -i, --image=FILE Load the application state from FILE(user-cr mode)\n\
   -s, --define KEY=VAL Assign VAL to configuration variable KEY\n",
 	.options  = my_longopts,
 	.parser   = my_parser,
@@ -90,6 +101,7 @@ Options :\n\
 int main(int argc, char *argv[])
 {
 	char *rcfile = NULL;
+	const char *image = NULL;
 	struct lxc_conf *conf;
 
 	lxc_list_init(&defines);
@@ -131,6 +143,9 @@ int main(int argc, char *argv[])
 	if (lxc_config_define_load(&defines, conf))
 		return -1;
 
-	return lxc_restart(my_args.name, my_args.statefile, conf,
-			   my_args.flags);
+	image = my_args.imagefile;
+	if (my_args.statefile)
+		image = my_args.statefile;
+
+	return lxc_restart(my_args.name, image, conf, my_args.flags);
 }
-- 
1.6.6.1
