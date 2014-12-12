From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 02/18] mnt: Update unprivileged remount test
Date: Fri, 12 Dec 2014 16:48:13 -0600
Message-ID: <1418424509-22389-2-git-send-email-ebiederm__12961.90004$1418424692$gmane$org@xmission.com>
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

- MNT_NODEV should be irrelevant except when reading back mount flags,
  no longer specify MNT_NODEV on remount.

- Test MNT_NODEV on devpts where it is meaningful even for unprivileged mounts.

- Add a test to verify that remount of a prexisting mount with the same flags
  is allowed and does not change those flags.

- Cleanup up the definitions of MS_REC, MS_RELATIME, MS_STRICTATIME that are used
  when the code is built in an environment without them.

- Correct the test error messages when tests fail.  There were not 5 tests
  that tested MS_RELATIME.

Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 .../selftests/mount/unprivileged-remount-test.c    | 172 +++++++++++++++++----
 1 file changed, 142 insertions(+), 30 deletions(-)

diff --git a/tools/testing/selftests/mount/unprivileged-remount-test.c b/tools/testing/selftests/mount/unprivileged-remount-test.c
index 1b3ff2fda4d0..9669d375625a 100644
--- a/tools/testing/selftests/mount/unprivileged-remount-test.c
+++ b/tools/testing/selftests/mount/unprivileged-remount-test.c
@@ -6,6 +6,8 @@
 #include <sys/types.h>
 #include <sys/mount.h>
 #include <sys/wait.h>
+#include <sys/vfs.h>
+#include <sys/statvfs.h>
 #include <stdlib.h>
 #include <unistd.h>
 #include <fcntl.h>
@@ -32,11 +34,14 @@
 # define CLONE_NEWPID 0x20000000
 #endif
 
+#ifndef MS_REC
+# define MS_REC 16384
+#endif
 #ifndef MS_RELATIME
-#define MS_RELATIME (1 << 21)
+# define MS_RELATIME (1 << 21)
 #endif
 #ifndef MS_STRICTATIME
-#define MS_STRICTATIME (1 << 24)
+# define MS_STRICTATIME (1 << 24)
 #endif
 
 static void die(char *fmt, ...)
@@ -87,6 +92,45 @@ static void write_file(char *filename, char *fmt, ...)
 	}
 }
 
+static int read_mnt_flags(const char *path)
+{
+	int ret;
+	struct statvfs stat;
+	int mnt_flags;
+
+	ret = statvfs(path, &stat);
+	if (ret != 0) {
+		die("statvfs of %s failed: %s\n",
+			path, strerror(errno));
+	}
+	if (stat.f_flag & ~(ST_RDONLY | ST_NOSUID | ST_NODEV | \
+			ST_NOEXEC | ST_NOATIME | ST_NODIRATIME | ST_RELATIME | \
+			ST_SYNCHRONOUS | ST_MANDLOCK)) {
+		die("Unrecognized mount flags\n");
+	}
+	mnt_flags = 0;
+	if (stat.f_flag & ST_RDONLY)
+		mnt_flags |= MS_RDONLY;
+	if (stat.f_flag & ST_NOSUID)
+		mnt_flags |= MS_NOSUID;
+	if (stat.f_flag & ST_NODEV)
+		mnt_flags |= MS_NODEV;
+	if (stat.f_flag & ST_NOEXEC)
+		mnt_flags |= MS_NOEXEC;
+	if (stat.f_flag & ST_NOATIME)
+		mnt_flags |= MS_NOATIME;
+	if (stat.f_flag & ST_NODIRATIME)
+		mnt_flags |= MS_NODIRATIME;
+	if (stat.f_flag & ST_RELATIME)
+		mnt_flags |= MS_RELATIME;
+	if (stat.f_flag & ST_SYNCHRONOUS)
+		mnt_flags |= MS_SYNCHRONOUS;
+	if (stat.f_flag & ST_MANDLOCK)
+		mnt_flags |= ST_MANDLOCK;
+
+	return mnt_flags;
+}
+
 static void create_and_enter_userns(void)
 {
 	uid_t uid;
@@ -118,7 +162,8 @@ static void create_and_enter_userns(void)
 }
 
 static
-bool test_unpriv_remount(int mount_flags, int remount_flags, int invalid_flags)
+bool test_unpriv_remount(const char *fstype, const char *mount_options,
+			 int mount_flags, int remount_flags, int invalid_flags)
 {
 	pid_t child;
 
@@ -151,9 +196,11 @@ bool test_unpriv_remount(int mount_flags, int remount_flags, int invalid_flags)
 			strerror(errno));
 	}
 
-	if (mount("testing", "/tmp", "ramfs", mount_flags, NULL) != 0) {
-		die("mount of /tmp failed: %s\n",
-			strerror(errno));
+	if (mount("testing", "/tmp", fstype, mount_flags, mount_options) != 0) {
+		die("mount of %s with options '%s' on /tmp failed: %s\n",
+		    fstype,
+		    mount_options? mount_options : "",
+		    strerror(errno));
 	}
 
 	create_and_enter_userns();
@@ -181,62 +228,127 @@ bool test_unpriv_remount(int mount_flags, int remount_flags, int invalid_flags)
 
 static bool test_unpriv_remount_simple(int mount_flags)
 {
-	return test_unpriv_remount(mount_flags, mount_flags, 0);
+	return test_unpriv_remount("ramfs", NULL, mount_flags, mount_flags, 0);
 }
 
 static bool test_unpriv_remount_atime(int mount_flags, int invalid_flags)
 {
-	return test_unpriv_remount(mount_flags, mount_flags, invalid_flags);
+	return test_unpriv_remount("ramfs", NULL, mount_flags, mount_flags,
+				   invalid_flags);
+}
+
+static bool test_priv_mount_unpriv_remount(void)
+{
+	pid_t child;
+	int ret;
+	const char *orig_path = "/dev";
+	const char *dest_path = "/tmp";
+	int orig_mnt_flags, remount_mnt_flags;
+
+	child = fork();
+	if (child == -1) {
+		die("fork failed: %s\n",
+			strerror(errno));
+	}
+	if (child != 0) { /* parent */
+		pid_t pid;
+		int status;
+		pid = waitpid(child, &status, 0);
+		if (pid == -1) {
+			die("waitpid failed: %s\n",
+				strerror(errno));
+		}
+		if (pid != child) {
+			die("waited for %d got %d\n",
+				child, pid);
+		}
+		if (!WIFEXITED(status)) {
+			die("child did not terminate cleanly\n");
+		}
+		return WEXITSTATUS(status) == EXIT_SUCCESS ? true : false;
+	}
+
+	orig_mnt_flags = read_mnt_flags(orig_path);
+
+	create_and_enter_userns();
+	ret = unshare(CLONE_NEWNS);
+	if (ret != 0) {
+		die("unshare(CLONE_NEWNS) failed: %s\n",
+			strerror(errno));
+	}
+
+	ret = mount(orig_path, dest_path, "bind", MS_BIND | MS_REC, NULL);
+	if (ret != 0) {
+		die("recursive bind mount of %s onto %s failed: %s\n",
+			orig_path, dest_path, strerror(errno));
+	}
+
+	ret = mount(dest_path, dest_path, "none",
+		    MS_REMOUNT | MS_BIND | orig_mnt_flags , NULL);
+	if (ret != 0) {
+		/* system("cat /proc/self/mounts"); */
+		die("remount of /tmp failed: %s\n",
+		    strerror(errno));
+	}
+
+	remount_mnt_flags = read_mnt_flags(dest_path);
+	if (orig_mnt_flags != remount_mnt_flags) {
+		die("Mount flags unexpectedly changed during remount of %s originally mounted on %s\n",
+			dest_path, orig_path);
+	}
+	exit(EXIT_SUCCESS);
 }
 
 int main(int argc, char **argv)
 {
-	if (!test_unpriv_remount_simple(MS_RDONLY|MS_NODEV)) {
+	if (!test_unpriv_remount_simple(MS_RDONLY)) {
 		die("MS_RDONLY malfunctions\n");
 	}
-	if (!test_unpriv_remount_simple(MS_NODEV)) {
+	if (!test_unpriv_remount("devpts", "newinstance", MS_NODEV, MS_NODEV, 0)) {
 		die("MS_NODEV malfunctions\n");
 	}
-	if (!test_unpriv_remount_simple(MS_NOSUID|MS_NODEV)) {
+	if (!test_unpriv_remount_simple(MS_NOSUID)) {
 		die("MS_NOSUID malfunctions\n");
 	}
-	if (!test_unpriv_remount_simple(MS_NOEXEC|MS_NODEV)) {
+	if (!test_unpriv_remount_simple(MS_NOEXEC)) {
 		die("MS_NOEXEC malfunctions\n");
 	}
-	if (!test_unpriv_remount_atime(MS_RELATIME|MS_NODEV,
-				       MS_NOATIME|MS_NODEV))
+	if (!test_unpriv_remount_atime(MS_RELATIME,
+				       MS_NOATIME))
 	{
 		die("MS_RELATIME malfunctions\n");
 	}
-	if (!test_unpriv_remount_atime(MS_STRICTATIME|MS_NODEV,
-				       MS_NOATIME|MS_NODEV))
+	if (!test_unpriv_remount_atime(MS_STRICTATIME,
+				       MS_NOATIME))
 	{
 		die("MS_STRICTATIME malfunctions\n");
 	}
-	if (!test_unpriv_remount_atime(MS_NOATIME|MS_NODEV,
-				       MS_STRICTATIME|MS_NODEV))
+	if (!test_unpriv_remount_atime(MS_NOATIME,
+				       MS_STRICTATIME))
 	{
-		die("MS_RELATIME malfunctions\n");
+		die("MS_NOATIME malfunctions\n");
 	}
-	if (!test_unpriv_remount_atime(MS_RELATIME|MS_NODIRATIME|MS_NODEV,
-				       MS_NOATIME|MS_NODEV))
+	if (!test_unpriv_remount_atime(MS_RELATIME|MS_NODIRATIME,
+				       MS_NOATIME))
 	{
-		die("MS_RELATIME malfunctions\n");
+		die("MS_RELATIME|MS_NODIRATIME malfunctions\n");
 	}
-	if (!test_unpriv_remount_atime(MS_STRICTATIME|MS_NODIRATIME|MS_NODEV,
-				       MS_NOATIME|MS_NODEV))
+	if (!test_unpriv_remount_atime(MS_STRICTATIME|MS_NODIRATIME,
+				       MS_NOATIME))
 	{
-		die("MS_RELATIME malfunctions\n");
+		die("MS_STRICTATIME|MS_NODIRATIME malfunctions\n");
 	}
-	if (!test_unpriv_remount_atime(MS_NOATIME|MS_NODIRATIME|MS_NODEV,
-				       MS_STRICTATIME|MS_NODEV))
+	if (!test_unpriv_remount_atime(MS_NOATIME|MS_NODIRATIME,
+				       MS_STRICTATIME))
 	{
-		die("MS_RELATIME malfunctions\n");
+		die("MS_NOATIME|MS_DIRATIME malfunctions\n");
 	}
-	if (!test_unpriv_remount(MS_STRICTATIME|MS_NODEV, MS_NODEV,
-				 MS_NOATIME|MS_NODEV))
+	if (!test_unpriv_remount("ramfs", NULL, MS_STRICTATIME, 0, MS_NOATIME))
 	{
 		die("Default atime malfunctions\n");
 	}
+	if (!test_priv_mount_unpriv_remount()) {
+		die("Mount flags unexpectedly changed after remount\n");
+	}
 	return EXIT_SUCCESS;
 }
-- 
1.9.1
