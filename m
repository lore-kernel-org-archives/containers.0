From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH user-cr] use syscall(NR_getpid) to avoid cached pid
Date: Tue, 16 Feb 2010 18:24:09 -0600
Message-ID: <20100217002409.GA3267@us.ibm.com>
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

otherwise glibc caches getpid() result and we put the parent
process in the new cgroup, in the case of 'nsexec -cg /bin/sleep 10'

Signed-off-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 nsexec.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/nsexec.c b/nsexec.c
index 3a825f1..79fcc70 100644
--- a/nsexec.c
+++ b/nsexec.c
@@ -154,7 +154,7 @@ int move_to_new_cgroup(int newcgroup)
 	fout = fopen(tasksfname, "w");
 	if (!fout)
 		return 0;
-	fprintf(fout, "%d\n", getpid());
+	fprintf(fout, "%d\n", syscall(__NR_getpid));
 	fclose(fout);
 	return 1;
 }
@@ -193,7 +193,7 @@ int do_child(void *vargv)
 
 	/* if pid == 1 then remount /proc */
 	/* But if the container has no /proc don't fret */
-	if (getpid() == 1) {
+	if (syscall(__NR_getpid) == 1) {
 		umount2("/proc", MNT_DETACH);
 		mount("proc", "/proc", "proc", 0, NULL);
 	}
-- 
1.6.4.4
