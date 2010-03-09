From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH RFC user-cr] add -p option to ckptinfo to dump pids tree
Date: Tue, 9 Mar 2010 15:05:40 -0600
Message-ID: <20100309210540.GB5789@us.ibm.com>
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

This will be used by a restart wrapper to analyze /proc/$$/mountinfo.

Also add the new rpids field to ckpt_pids to reflect kernel.

It depends on the patch I just sent for linux-cr adding rpid to
struct ckpt_pids.

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 ckptinfo.c                     |   36 +++++++++++++++++++++++++++++++++++-
 include/linux/checkpoint_hdr.h |    1 +
 2 files changed, 36 insertions(+), 1 deletions(-)

diff --git a/ckptinfo.c b/ckptinfo.c
index 6190301..b5922da 100644
--- a/ckptinfo.c
+++ b/ckptinfo.c
@@ -28,6 +28,7 @@ static char usage_str[] =
 "\tOptions:\n"
 "\t -h,--help             print this help message\n"
 "\t -e,--error            show error messages\n"
+"\t -p,--pids		  just list process tree\n"
 "\t -v,--verbose          verbose output\n"
 "\t    --show-arch-regs   show registers contents\n"
 "";
@@ -36,6 +37,7 @@ struct args {
 	int error;
 	int verbose;
 	int show_arch_regs;
+	int show_process_tree;
 };
 
 int __verbose;
@@ -55,6 +57,7 @@ static int image_parse_vma(struct ckpt_hdr *h, int fd, struct args *args);
 static int image_parse_file(struct ckpt_hdr *h, int fd, struct args *args);
 static int image_parse_objref(struct ckpt_hdr *h, int fd, struct args *args);
 static int image_parse_error(struct ckpt_hdr *h, int fd, struct args *args);
+static void show_tasks(struct ckpt_hdr *h, int numpids);
 
 #ifdef __i386__
 #define __HAVE_image_parse_cpu
@@ -85,10 +88,11 @@ static void parse_args(struct args *args, int argc, char *argv[])
 		{ "help",	no_argument,		NULL, 'h' },
 		{ "error",	no_argument,		NULL, 'e' },
 		{ "verbose",	no_argument,		NULL, 'v' },
+		{ "pids",	no_argument,		NULL, 'p' },
 		{ "show-arch-regs",	no_argument,	NULL, 1 },
 		{ NULL,		0,			NULL, 0 }
 	};
-	static char optc[] = "hve";
+	static char optc[] = "hvep";
 
 	while (1) {
 		int c = getopt_long(argc, argv, optc, opts, NULL);
@@ -99,6 +103,9 @@ static void parse_args(struct args *args, int argc, char *argv[])
 			exit(1);
 		case 'h':
 			usage(usage_str);
+		case 'p':
+			args->show_process_tree = 1;
+			break;
 		case 'e':
 			args->error = 1;
 			break;
@@ -208,6 +215,7 @@ static int image_parse(int fd, struct args *args)
 {
 	struct ckpt_hdr *h;
 	int ret;
+	int numpids, next_read_pids = 0;
 
 	do {
 		ret = image_read_obj(fd, &h);
@@ -215,6 +223,11 @@ static int image_parse(int fd, struct args *args)
 			break;
 		if (!h)
 			continue;
+		if (next_read_pids) {
+			next_read_pids = 0;
+			if (args->show_process_tree)
+				show_tasks(h, numpids);
+		}
 		switch (h->type) {
 		case CKPT_HDR_OBJREF:
 			ret = image_parse_objref(h, fd, args);
@@ -232,12 +245,33 @@ static int image_parse(int fd, struct args *args)
 			ret = image_parse_error(h, fd, args);
 			break;
 		}
+		if (h->type == CKPT_HDR_TREE) {
+			struct ckpt_hdr_tree *t = (struct ckpt_hdr_tree *) h;
+			numpids = t->nr_tasks;
+			next_read_pids = 1;
+		}
 		free(h);
 	} while (ret > 0);
 
 	return ret;
 }
 
+struct ckpt_hdr_pids {
+	struct ckpt_hdr h;
+	struct ckpt_pids p;
+};
+
+static void show_tasks(struct ckpt_hdr *h, int numpids)
+{
+	struct ckpt_hdr_pids *pp = (struct ckpt_hdr_pids *)h;
+	struct ckpt_pids *p = &pp->p;
+	int i;
+
+	for (i=0; i<numpids; i++)
+		printf("Task %d: rpid %d pid %d vppid %d\n", i, p[i].rpid,
+			p[i].vpid, p[i].vppid);
+}
+
 static int image_parse_objref(struct ckpt_hdr *h, int fd, struct args *args)
 {
 	struct ckpt_hdr_objref *hh = (struct ckpt_hdr_objref *) h;
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index e8eaf23..9c6bc6d 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -321,6 +321,7 @@ struct ckpt_hdr_tree {
 } __attribute__((aligned(8)));
 
 struct ckpt_pids {
+	__s32 rpid;
 	__s32 vpid;
 	__s32 vppid;
 	__s32 vtgid;
-- 
1.6.0.6
