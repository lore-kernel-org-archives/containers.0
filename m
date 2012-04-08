From: "\"Eric W. Beiderman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 43/43] userns: Convert the move_pages,
	and migrate_pages permission checks to use uid_eq
Date: Sat,  7 Apr 2012 22:15:39 -0700
Message-ID: <1333862139-31737-43-git-send-email-ebiederm__4480.4897429005$1333862147$gmane$org@xmission.com>
References: <m11unyn70b.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m11unyn70b.fsf-+imSwln9KH6u2/kzUuoCbdi2O/JbrIOy@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Cyrill Gorcunov <gorcunov-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

From: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 mm/mempolicy.c |    4 ++--
 mm/migrate.c   |    4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index cfb6c86..7b44fc8 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1334,8 +1334,8 @@ SYSCALL_DEFINE4(migrate_pages, pid_t, pid, unsigned long, maxnode,
 	 * userid as the target process.
 	 */
 	tcred = __task_cred(task);
-	if (cred->euid != tcred->suid && cred->euid != tcred->uid &&
-	    cred->uid  != tcred->suid && cred->uid  != tcred->uid &&
+	if (!uid_eq(cred->euid, tcred->suid) && !uid_eq(cred->euid, tcred->uid) &&
+	    !uid_eq(cred->uid,  tcred->suid) && !uid_eq(cred->uid,  tcred->uid) &&
 	    !capable(CAP_SYS_NICE)) {
 		rcu_read_unlock();
 		err = -EPERM;
diff --git a/mm/migrate.c b/mm/migrate.c
index 51c08a0..1cf5252 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1371,8 +1371,8 @@ SYSCALL_DEFINE6(move_pages, pid_t, pid, unsigned long, nr_pages,
 	 * userid as the target process.
 	 */
 	tcred = __task_cred(task);
-	if (cred->euid != tcred->suid && cred->euid != tcred->uid &&
-	    cred->uid  != tcred->suid && cred->uid  != tcred->uid &&
+	if (!uid_eq(cred->euid, tcred->suid) && !uid_eq(cred->euid, tcred->uid) &&
+	    !uid_eq(cred->uid,  tcred->suid) && !uid_eq(cred->uid,  tcred->uid) &&
 	    !capable(CAP_SYS_NICE)) {
 		rcu_read_unlock();
 		err = -EPERM;
-- 
1.7.2.5
