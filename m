From: Rami Rosen <ramirose-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] devcg: remove parent_cgroup.
Date: Tue, 16 Apr 2013 23:24:55 +0300
Message-ID: <1366143895-21535-1-git-send-email-ramirose@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, aris-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Rami Rosen <ramirose-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

In devcgroup_css_alloc(), there is no longer need for parent_cgroup.
bd2953ebbb("devcg: propagate local changes down the hierarchy") made
the variable parent_cgroup redundant. This patch removes parent_cgroup
from devcgroup_css_alloc().

Signed-off-by: Rami Rosen <ramirose-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 security/device_cgroup.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/security/device_cgroup.c b/security/device_cgroup.c
index 994aecc..dd0dc57 100644
--- a/security/device_cgroup.c
+++ b/security/device_cgroup.c
@@ -236,7 +236,6 @@ static void devcgroup_offline(struct cgroup *cgroup)
 static struct cgroup_subsys_state *devcgroup_css_alloc(struct cgroup *cgroup)
 {
 	struct dev_cgroup *dev_cgroup;
-	struct cgroup *parent_cgroup;
 
 	dev_cgroup = kzalloc(sizeof(*dev_cgroup), GFP_KERNEL);
 	if (!dev_cgroup)
@@ -244,7 +243,6 @@ static struct cgroup_subsys_state *devcgroup_css_alloc(struct cgroup *cgroup)
 	INIT_LIST_HEAD(&dev_cgroup->exceptions);
 	INIT_LIST_HEAD(&dev_cgroup->propagate_pending);
 	dev_cgroup->behavior = DEVCG_DEFAULT_NONE;
-	parent_cgroup = cgroup->parent;
 
 	return &dev_cgroup->css;
 }
-- 
1.8.1.4
