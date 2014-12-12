From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 18/18] userns: Unbreak the unprivileged remount tests
Date: Fri, 12 Dec 2014 16:48:29 -0600
Message-ID: <1418424509-22389-18-git-send-email-ebiederm__15132.944394327$1418424946$gmane$org@xmission.com>
References: <87k31wzehb.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87k31wzehb.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Cc: Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>, stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

A security fix in caused the way the unprivileged remount tests were
using user namespaces to break.  Tweak the way user namespaces are
being used so the test works again.

Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 .../selftests/mount/unprivileged-remount-test.c    | 32 ++++++++++++++++------
 1 file changed, 24 insertions(+), 8 deletions(-)

diff --git a/tools/testing/selftests/mount/unprivileged-remount-test.c b/tools/testing/selftests/mount/unprivileged-remount-test.c
index 9669d375625a..517785052f1c 100644
--- a/tools/testing/selftests/mount/unprivileged-remount-test.c
+++ b/tools/testing/selftests/mount/unprivileged-remount-test.c
@@ -53,17 +53,14 @@ static void die(char *fmt, ...)
 	exit(EXIT_FAILURE);
 }
 
-static void write_file(char *filename, char *fmt, ...)
+static void vmaybe_write_file(bool enoent_ok, char *filename, char *fmt, va_list ap)
 {
 	char buf[4096];
 	int fd;
 	ssize_t written;
 	int buf_len;
-	va_list ap;
 
-	va_start(ap, fmt);
 	buf_len = vsnprintf(buf, sizeof(buf), fmt, ap);
-	va_end(ap);
 	if (buf_len < 0) {
 		die("vsnprintf failed: %s\n",
 		    strerror(errno));
@@ -74,6 +71,8 @@ static void write_file(char *filename, char *fmt, ...)
 
 	fd = open(filename, O_WRONLY);
 	if (fd < 0) {
+		if ((errno == ENOENT) && enoent_ok)
+			return;
 		die("open of %s failed: %s\n",
 		    filename, strerror(errno));
 	}
@@ -92,6 +91,26 @@ static void write_file(char *filename, char *fmt, ...)
 	}
 }
 
+static void maybe_write_file(char *filename, char *fmt, ...)
+{
+	va_list ap;
+
+	va_start(ap, fmt);
+	vmaybe_write_file(true, filename, fmt, ap);
+	va_end(ap);
+
+}
+
+static void write_file(char *filename, char *fmt, ...)
+{
+	va_list ap;
+
+	va_start(ap, fmt);
+	vmaybe_write_file(false, filename, fmt, ap);
+	va_end(ap);
+
+}
+
 static int read_mnt_flags(const char *path)
 {
 	int ret;
@@ -144,13 +163,10 @@ static void create_and_enter_userns(void)
 			strerror(errno));
 	}
 
+	maybe_write_file("/proc/self/setgroups", "deny");
 	write_file("/proc/self/uid_map", "0 %d 1", uid);
 	write_file("/proc/self/gid_map", "0 %d 1", gid);
 
-	if (setgroups(0, NULL) != 0) {
-		die("setgroups failed: %s\n",
-			strerror(errno));
-	}
 	if (setgid(0) != 0) {
 		die ("setgid(0) failed %s\n",
 			strerror(errno));
-- 
1.9.1
