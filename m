From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [GIT PULL] cgroup fixes for v3.7-rc5
Date: Tue, 13 Nov 2012 08:26:27 -0800
Message-ID: <20121113162627.GB18227@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Please pull from the following branch to receive fixes for v3.7-rc5.
It contains two fix patches for device_cgroup.  One fixes a regression
introduced earlier in 3.7 cycle where device_cgroup could try to
dereference the NULL parent of the root cgroup.  The other one is RCU
usage fix.

  git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git for-3.7-fixes

Thanks.
---
Aristeu Rozanski (1):
      device_cgroup: fix unchecked cgroup parent usage

Tejun Heo (1):
      device_cgroup: fix RCU usage

 security/device_cgroup.c | 18 +++++++++++++-----
 1 file changed, 13 insertions(+), 5 deletions(-)

diff --git a/security/device_cgroup.c b/security/device_cgroup.c
index 842c254..b08d20c 100644
--- a/security/device_cgroup.c
+++ b/security/device_cgroup.c
@@ -164,8 +164,8 @@ static void dev_exception_clean(struct dev_cgroup *dev_cgroup)
 	struct dev_exception_item *ex, *tmp;
 
 	list_for_each_entry_safe(ex, tmp, &dev_cgroup->exceptions, list) {
-		list_del(&ex->list);
-		kfree(ex);
+		list_del_rcu(&ex->list);
+		kfree_rcu(ex, rcu);
 	}
 }
 
@@ -298,7 +298,7 @@ static int may_access(struct dev_cgroup *dev_cgroup,
 	struct dev_exception_item *ex;
 	bool match = false;
 
-	list_for_each_entry(ex, &dev_cgroup->exceptions, list) {
+	list_for_each_entry_rcu(ex, &dev_cgroup->exceptions, list) {
 		if ((refex->type & DEV_BLOCK) && !(ex->type & DEV_BLOCK))
 			continue;
 		if ((refex->type & DEV_CHAR) && !(ex->type & DEV_CHAR))
@@ -352,6 +352,8 @@ static int parent_has_perm(struct dev_cgroup *childcg,
  */
 static inline int may_allow_all(struct dev_cgroup *parent)
 {
+	if (!parent)
+		return 1;
 	return parent->behavior == DEVCG_DEFAULT_ALLOW;
 }
 
@@ -376,11 +378,14 @@ static int devcgroup_update_access(struct dev_cgroup *devcgroup,
 	int count, rc;
 	struct dev_exception_item ex;
 	struct cgroup *p = devcgroup->css.cgroup;
-	struct dev_cgroup *parent = cgroup_to_devcgroup(p->parent);
+	struct dev_cgroup *parent = NULL;
 
 	if (!capable(CAP_SYS_ADMIN))
 		return -EPERM;
 
+	if (p->parent)
+		parent = cgroup_to_devcgroup(p->parent);
+
 	memset(&ex, 0, sizeof(ex));
 	b = buffer;
 
@@ -391,11 +396,14 @@ static int devcgroup_update_access(struct dev_cgroup *devcgroup,
 			if (!may_allow_all(parent))
 				return -EPERM;
 			dev_exception_clean(devcgroup);
+			devcgroup->behavior = DEVCG_DEFAULT_ALLOW;
+			if (!parent)
+				break;
+
 			rc = dev_exceptions_copy(&devcgroup->exceptions,
 						 &parent->exceptions);
 			if (rc)
 				return rc;
-			devcgroup->behavior = DEVCG_DEFAULT_ALLOW;
 			break;
 		case DEVCG_DENY:
 			dev_exception_clean(devcgroup);
