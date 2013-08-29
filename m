From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [REVIEW][PATCH 4/5] capabilities: allow nice if we are privileged
Date: Thu, 29 Aug 2013 16:55:35 -0700
Message-ID: <8761uoyruw.fsf@xmission.com>
References: <87ob8gys0d.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87ob8gys0d.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> (Eric W. Biederman's message of
	"Thu, 29 Aug 2013 16:52:18 -0700")
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
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org


We allow task A to change B's nice level if it has a supserset of
B's privileges, or of it has CAP_SYS_NICE.  Also allow it if A has
CAP_SYS_NICE with respect to B - meaning it is root in the same
namespace, or it created B's namespace.

Signed-off-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Reviewed-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 security/commoncap.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/security/commoncap.c b/security/commoncap.c
index 9fccf71..b9d613e 100644
--- a/security/commoncap.c
+++ b/security/commoncap.c
@@ -768,16 +768,16 @@ int cap_task_fix_setuid(struct cred *new, const struct cred *old, int flags)
  */
 static int cap_safe_nice(struct task_struct *p)
 {
-	int is_subset;
+	int is_subset, ret = 0;
 
 	rcu_read_lock();
 	is_subset = cap_issubset(__task_cred(p)->cap_permitted,
 				 current_cred()->cap_permitted);
+	if (!is_subset && !ns_capable(__task_cred(p)->user_ns, CAP_SYS_NICE))
+		ret = -EPERM;
 	rcu_read_unlock();
 
-	if (!is_subset && !capable(CAP_SYS_NICE))
-		return -EPERM;
-	return 0;
+	return ret;
 }
 
 /**
-- 
1.7.5.4
