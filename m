From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH cgroup/for-3.12-fixes] cgroup: fix cgroup post-order
	descendant walk of empty subtree
Date: Fri, 6 Sep 2013 15:31:08 -0400
Message-ID: <20130906193108.GH22763__42069.6826339283$1378495886$gmane$org@mtj.dyndns.org>
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
To: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

bd8815a6d8 ("cgroup: make css_for_each_descendant() and friends
include the origin css in the iteration") updated cgroup descendant
iterators to include the origin css; unfortuantely, it forgot to drop
special case handling in css_next_descendant_post() for empty subtree
leading to failure to visit the origin css without any child.

Fix it by dropping the special case handling and always returning the
leftmost descendant on the first iteration.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 kernel/cgroup.c |    8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index e0aeb32..8075b72 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -3187,11 +3187,9 @@ css_next_descendant_post(struct cgroup_subsys_state *pos,
 
 	WARN_ON_ONCE(!rcu_read_lock_held());
 
-	/* if first iteration, visit the leftmost descendant */
-	if (!pos) {
-		next = css_leftmost_descendant(root);
-		return next != root ? next : NULL;
-	}
+	/* if first iteration, visit leftmost descendant which may be @root */
+	if (!pos)
+		return css_leftmost_descendant(root);
 
 	/* if we visited @root, we're done */
 	if (pos == root)
