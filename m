From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 10/17] cgroup: fix harmless bugs in cgroup_load_subsys() fail
	path and cgroup_unload_subsys()
Date: Mon, 12 Nov 2012 19:01:37 -0800
Message-ID: <1352775704-9023-11-git-send-email-tj@kernel.org>
References: <1352775704-9023-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1352775704-9023-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: mhocko-AlSwsSmVLrQ@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

* If idr init fails, cgroup_load_subsys() cleared dummytop->subsys[]
  before calilng ->destroy() making CSS inaccessible to the callback,
  and didn't unlink ss->sibling.  As no modular controller uses
  ->use_id, this doesn't cause any actual problems.

* cgroup_unload_subsys() was forgetting to free idr, call
  ->pre_destroy() and clear ->active.  As there currently is no
  modular controller which uses ->use_id, ->pre_destroy() or ->active,
  this doesn't cause any actual problems.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 kernel/cgroup.c | 15 ++++++++++++++-
 1 file changed, 14 insertions(+), 1 deletion(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 76f1a01..c5368c0 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -4420,9 +4420,10 @@ int __init_or_module cgroup_load_subsys(struct cgroup_subsys *ss)
 	if (ss->use_id) {
 		int ret = cgroup_init_idr(ss, css);
 		if (ret) {
-			dummytop->subsys[ss->subsys_id] = NULL;
 			ss->destroy(dummytop);
+			dummytop->subsys[ss->subsys_id] = NULL;
 			subsys[ss->subsys_id] = NULL;
+			list_del_init(&ss->sibling);
 			mutex_unlock(&cgroup_mutex);
 			return ret;
 		}
@@ -4490,7 +4491,19 @@ void cgroup_unload_subsys(struct cgroup_subsys *ss)
 	 */
 	BUG_ON(ss->root != &rootnode);
 
+	/* ->pre_destroy() should be called outside cgroup_mutex for now */
+	if (ss->pre_destroy)
+		ss->pre_destroy(dummytop);
+
 	mutex_lock(&cgroup_mutex);
+
+	ss->active = 0;
+
+	if (ss->use_id) {
+		idr_remove_all(&ss->idr);
+		idr_destroy(&ss->idr);
+	}
+
 	/* deassign the subsys_id */
 	subsys[ss->subsys_id] = NULL;
 
-- 
1.7.11.7
