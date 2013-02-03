From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 55/62] cgroup: convert to idr_alloc()
Date: Sat,  2 Feb 2013 17:20:56 -0800
Message-ID: <1359854463-2538-56-git-send-email-tj@kernel.org>
References: <1359854463-2538-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1359854463-2538-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
Cc: axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, rusty-8n+1lVoiYb80n/F98K4Iww@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Convert to the much saner new idr interface.

Only compile tested.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
---
This patch depends on an earlier idr changes and I think it would be
best to route these together through -mm.  Please holler if there's
any objection.  Thanks.

 kernel/cgroup.c | 27 ++++++++-------------------
 1 file changed, 8 insertions(+), 19 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 6b18c5c..4ee1102 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -5272,7 +5272,7 @@ EXPORT_SYMBOL_GPL(free_css_id);
 static struct css_id *get_new_cssid(struct cgroup_subsys *ss, int depth)
 {
 	struct css_id *newid;
-	int myid, error, size;
+	int ret, size;
 
 	BUG_ON(!ss->use_id);
 
@@ -5280,35 +5280,24 @@ static struct css_id *get_new_cssid(struct cgroup_subsys *ss, int depth)
 	newid = kzalloc(size, GFP_KERNEL);
 	if (!newid)
 		return ERR_PTR(-ENOMEM);
-	/* get id */
-	if (unlikely(!idr_pre_get(&ss->idr, GFP_KERNEL))) {
-		error = -ENOMEM;
-		goto err_out;
-	}
+
+	idr_preload(GFP_KERNEL);
 	spin_lock(&ss->id_lock);
 	/* Don't use 0. allocates an ID of 1-65535 */
-	error = idr_get_new_above(&ss->idr, newid, 1, &myid);
+	ret = idr_alloc(&ss->idr, newid, 1, CSS_ID_MAX + 1, GFP_NOWAIT);
 	spin_unlock(&ss->id_lock);
+	idr_preload_end();
 
 	/* Returns error when there are no free spaces for new ID.*/
-	if (error) {
-		error = -ENOSPC;
+	if (ret < 0)
 		goto err_out;
-	}
-	if (myid > CSS_ID_MAX)
-		goto remove_idr;
 
-	newid->id = myid;
+	newid->id = ret;
 	newid->depth = depth;
 	return newid;
-remove_idr:
-	error = -ENOSPC;
-	spin_lock(&ss->id_lock);
-	idr_remove(&ss->idr, myid);
-	spin_unlock(&ss->id_lock);
 err_out:
 	kfree(newid);
-	return ERR_PTR(error);
+	return ERR_PTR(ret);
 
 }
 
-- 
1.8.1
