From: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Subject: [RFC PATCH 2/2] capabilities: allow nice if we are privileged
Date: Tue, 23 Jul 2013 13:18:53 -0500
Message-ID: <20130723181853.GA7005@sergelap>
References: <20130723181606.GA6342@sergelap>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130723181606.GA6342@sergelap>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

We allow task A to change B's nice level if it has a supserset of
B's privileges, or of it has CAP_SYS_NICE.  Also allow it if A has
CAP_SYS_NICE with respect to B - meaning it is root in the same
namespace, or it created B's namespace.

Signed-off-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
---
 security/commoncap.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/security/commoncap.c b/security/commoncap.c
index d78b003..ef98b56 100644
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
1.7.9.5
