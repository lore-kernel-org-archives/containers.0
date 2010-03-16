From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 04/10] cr_tests: Add dry-run
Date: Mon, 15 Mar 2010 23:54:17 -0700
Message-ID: <20100316065417.GH3037@count0.beaverton.ibm.com>
References: <69be886209c375c99b00b0745c1b0efdf334dcc3.1268694050.git.matthltc@us.ibm.com>
	<39d445e0d6bb5b1420daf672aa48ebabf8648ffe.1268694050.git.matthltc@us.ibm.com>
	<0c89f69bdb86538762c5e8a5e03fab71bb2e3963.1268694050.git.matthltc@us.ibm.com>
	<15d3e6bcb9a476add53b72998b45dd62a529871d.1268694050.git.matthltc@us.ibm.com>
	<1268695941.4397.135.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1268695941.4397.135.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org


cr_tests: Add dry-run

Make the cgroup freezer and do_ckpt() no-ops in order to do dry-runs of the
tests. This allows us to establish a baseline for those tests that can do
dry-runsi (i.e. have a dry-run option and use it to avoid restarting checkpoint
images).

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>

Changelog for v2:
	Removed hunk which short-circuited move_to_cgroup() as suggested
		by Nathan Lynch. (Oops, left a minor cleanup.)

diff --git a/libcrtest/common.c b/libcrtest/common.c
index 6cfc9a9..68f4de5 100644
--- a/libcrtest/common.c
+++ b/libcrtest/common.c
@@ -42,6 +42,9 @@ int test_checkpoint_done(void)
 {
 	int rc;
 
+	rc = access(CKPT_DRY_RUN, F_OK);
+	if (rc == 0)
+		return 1;
 	rc = access(CKPT_DONE, F_OK);
 	if (rc == 0)
 		return 1;
@@ -57,8 +60,11 @@ int test_checkpoint_done(void)
 
 void set_checkpoint_ready()
 {
-	int fd;
+	int fd, rc;
 
+	rc = access(CKPT_DRY_RUN, F_OK);
+	if (rc == 0)
+		return;
 	fd = creat(CKPT_READY, 0666);
 	if (fd < 0) {
 		fprintf(logfp, "creat(%s) failed, %s\n", CKPT_READY,
@@ -75,7 +81,7 @@ void do_ckpt(void)
 
 	set_checkpoint_ready();
 
-	rc = access(CKPT_SKIP, F_OK);
+	rc = access(CKPT_DRY_RUN, F_OK);
 	if (rc == 0)
 		return;
 	else if (errno != ENOENT)
@@ -340,9 +346,10 @@ static void create_cgroup(char *grp)
  */
 int move_to_cgroup(char *subsys, char *grp, int pid)
 {
+	char fname[MAXPATH];
+
 	if (strcmp(subsys, "freezer"))
 		return 0;
-	char fname[MAXPATH];
 	if (!freezer_mountpoint()) {
 		printf("freezer cgroup is not mounted.\n");
 		do_exit(1);
diff --git a/libcrtest/libcrtest.h b/libcrtest/libcrtest.h
index 7f8cfff..9723c74 100644
--- a/libcrtest/libcrtest.h
+++ b/libcrtest/libcrtest.h
@@ -3,7 +3,7 @@
 
 #define CKPT_READY		"checkpoint-ready"
 #define CKPT_DONE		"checkpoint-done"
-#define CKPT_SKIP		"checkpoint-skip"
+#define CKPT_DRY_RUN		"checkpoint-skip"
 #define TEST_DONE		"test-done"
 
 extern FILE *logfp;
