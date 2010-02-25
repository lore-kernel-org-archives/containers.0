From: "Kirill A. Shutemov" <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
Subject: [PATCH] cgroup: do not use dprintf in cgroup_event_listener
Date: Thu, 25 Feb 2010 12:24:07 +0200
Message-ID: <1267093447-2607-1-git-send-email-kirill__13227.0950744443$1267093549$gmane$org@shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

glibc's dprintf(3) is buggy:
http://sourceware.org/bugzilla/show_bug.cgi?id=11319

Let's not to use it in the example.

Signed-off-by: Kirill A. Shutemov <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
---
 Documentation/cgroups/cgroup_event_listener.c |   11 +++++++++--
 1 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/Documentation/cgroups/cgroup_event_listener.c b/Documentation/cgroups/cgroup_event_listener.c
index 8c2d7aa..8c2bfc4 100644
--- a/Documentation/cgroups/cgroup_event_listener.c
+++ b/Documentation/cgroups/cgroup_event_listener.c
@@ -23,6 +23,7 @@ int main(int argc, char **argv)
 	int cfd = -1;
 	int event_control = -1;
 	char event_control_path[PATH_MAX];
+	char line[LINE_MAX];
 	int ret;
 
 	if (argc != 3) {
@@ -39,7 +40,7 @@ int main(int argc, char **argv)
 
 	ret = snprintf(event_control_path, PATH_MAX, "%s/cgroup.event_control",
 			dirname(argv[1]));
-	if (ret > PATH_MAX) {
+	if (ret >= PATH_MAX) {
 		fputs("Path to cgroup.event_control is too long\n", stderr);
 		goto out;
 	}
@@ -57,7 +58,13 @@ int main(int argc, char **argv)
 		goto out;
 	}
 
-	ret = dprintf(event_control, "%d %d %s", efd, cfd, argv[2]);
+	ret = snprintf(line, LINE_MAX, "%d %d %s", efd, cfd, argv[2]);
+	if (ret >= LINE_MAX) {
+		fputs("Arguments string is too long\n", stderr);
+		goto out;
+	}
+
+	ret = write(event_control, line, strlen(line) + 1);
 	if (ret == -1) {
 		perror("Cannot write to cgroup.event_control");
 		goto out;
-- 
1.6.6.2
