From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 09/17] cgroup: lock cgroup_mutex in cgroup_init_subsys()
Date: Mon, 12 Nov 2012 19:01:36 -0800
Message-ID: <1352775704-9023-10-git-send-email-tj@kernel.org>
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

Make cgroup_init_subsys() grab cgroup_mutex while initializing a
subsystem so that all helpers and callbacks are called under the
context they expect.  This isn't strictly necessary as
cgroup_init_subsys() doesn't race with anybody but will allow adding
lockdep assertions.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 kernel/cgroup.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 6df17cb..76f1a01 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -4317,6 +4317,8 @@ static void __init cgroup_init_subsys(struct cgroup_subsys *ss)
 
 	printk(KERN_INFO "Initializing cgroup subsys %s\n", ss->name);
 
+	mutex_lock(&cgroup_mutex);
+
 	/* init base cftset */
 	cgroup_init_cftsets(ss);
 
@@ -4346,6 +4348,8 @@ static void __init cgroup_init_subsys(struct cgroup_subsys *ss)
 	if (ss->post_create)
 		ss->post_create(dummytop);
 
+	mutex_unlock(&cgroup_mutex);
+
 	/* this function shouldn't be used with modular subsystems, since they
 	 * need to register a subsys_id, among other things */
 	BUG_ON(ss->module);
-- 
1.7.11.7
