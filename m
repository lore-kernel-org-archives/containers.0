From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 3/5][lxc] lxc_checkpoint: Add --image option
Date: Thu, 18 Mar 2010 23:41:05 -0700
Message-ID: <20100319064105.GD25732@us.ibm.com>
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
Date: Wed, 10 Mar 2010 22:24:17 -0800
Subject: [PATCH 3/5][lxc] lxc_checkpoint: Add --image option

The existing --directory option to lxc_checkpoint expects to save the
checkpoint state in a directory. USERCR however uses a single regular
file to store the checkpoint image. So add a --image option to enable
checkpointing and restarting applications using USERCR.

Users should specify either --image or --directory option (but not both)
to select the file/directory where the application state will be stored.

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 src/lxc/lxc_checkpoint.c |   34 +++++++++++++++++++++++++---------
 1 files changed, 25 insertions(+), 9 deletions(-)

diff --git a/src/lxc/lxc_checkpoint.c b/src/lxc/lxc_checkpoint.c
index a8c74a9..3554518 100644
--- a/src/lxc/lxc_checkpoint.c
+++ b/src/lxc/lxc_checkpoint.c
@@ -39,10 +39,17 @@ lxc_log_define(lxc_checkpoint_ui, lxc_checkpoint);
 
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
@@ -53,6 +60,7 @@ static int my_parser(struct lxc_arguments* args, int c, char* arg)
 	case 'k': args->flags = LXC_FLAG_HALT; break;
 	case 'p': args->flags = LXC_FLAG_PAUSE; break;
 	case 'd': args->statefile = arg; break;
+	case 'i': args->imagefile = arg; break;
 	}
 	return 0;
 }
@@ -61,6 +69,7 @@ static const struct option my_longopts[] = {
 	{"kill", no_argument, 0, 'k'},
 	{"pause", no_argument, 0, 'p'},
 	{"directory", required_argument, 0, 'd'},
+	{"image", required_argument, 0, 'i'},
 	LXC_COMMON_OPTIONS
 };
 
@@ -68,6 +77,7 @@ static struct lxc_arguments my_args = {
 	.progname = "lxc-checkpoint",
 	.help     = "\
 --name=NAME --directory STATEFILE\n\
+\tlxc_checkpoint --name=NAME --image CHECKPOINT-IMAGE\n\
 \n\
 lxc-checkpoint checkpoints in STATEFILE the NAME container\n\
 \n\
@@ -75,7 +85,8 @@ Options :\n\
   -n, --name=NAME      NAME for name of the container\n\
   -k, --kill           stop the container after checkpoint\n\
   -p, --pause          don't unfreeze the container after the checkpoint\n\
-  -d, --directory=STATEFILE where to store the statefile\n",
+  -d, --directory=STATEFILE where to store the statefile (legacy mode)\n\
+  -i, --image=FILE where to store the checkpoint-image (USERCR mode)\n",
 
 	.options  = my_longopts,
 	.parser   = my_parser,
@@ -97,6 +108,7 @@ static int create_statefile(const char *dir)
 int main(int argc, char *argv[])
 {
 	int ret;
+	const char *image;
 
 	ret = lxc_arguments_parse(&my_args, argc, argv);
 	if (ret)
@@ -107,11 +119,15 @@ int main(int argc, char *argv[])
 	if (ret)
 		return ret;
 
-	ret = create_statefile(my_args.statefile);
-	if (ret)
-		return ret;
+	image = my_args.imagefile;
+	if (my_args.statefile) {
+		image = my_args.statefile;
+		ret = create_statefile(my_args.statefile);
+		if (ret)
+			return ret;
+	}
 
-	ret = lxc_checkpoint(my_args.name, my_args.statefile, my_args.flags);
+	ret = lxc_checkpoint(my_args.name, image, my_args.flags);
 	if (ret)
 		ERROR("failed to checkpoint '%s'", my_args.name);
 	else
-- 
1.6.6.1
