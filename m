From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 08/17] cgroup: trivial cleanup for cgroup_init/load_subsys()
Date: Mon, 12 Nov 2012 19:01:35 -0800
Message-ID: <1352775704-9023-9-git-send-email-tj@kernel.org>
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

Consistently use @css and @dummytop in these two functions instead of
referring to them indirectly.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 kernel/cgroup.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index d849efd..6df17cb 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -4332,7 +4332,7 @@ static void __init cgroup_init_subsys(struct cgroup_subsys *ss)
 	 * pointer to this state - since the subsystem is
 	 * newly registered, all tasks and hence the
 	 * init_css_set is in the subsystem's top cgroup. */
-	init_css_set.subsys[ss->subsys_id] = dummytop->subsys[ss->subsys_id];
+	init_css_set.subsys[ss->subsys_id] = css;
 
 	need_forkexit_callback |= ss->fork || ss->exit;
 
@@ -4344,7 +4344,7 @@ static void __init cgroup_init_subsys(struct cgroup_subsys *ss)
 	ss->active = 1;
 
 	if (ss->post_create)
-		ss->post_create(&ss->root->top_cgroup);
+		ss->post_create(dummytop);
 
 	/* this function shouldn't be used with modular subsystems, since they
 	 * need to register a subsys_id, among other things */
@@ -4456,7 +4456,7 @@ int __init_or_module cgroup_load_subsys(struct cgroup_subsys *ss)
 	ss->active = 1;
 
 	if (ss->post_create)
-		ss->post_create(&ss->root->top_cgroup);
+		ss->post_create(dummytop);
 
 	/* success! */
 	mutex_unlock(&cgroup_mutex);
-- 
1.7.11.7
