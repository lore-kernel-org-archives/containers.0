From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH] cgroup: fix default notify_on_release setting
Date: Mon, 25 Feb 2008 13:53:47 +0800
Message-ID: <47C257EB.5060600__23379.9294954681$1203924414$gmane$org@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

The documentation says the default value of notify_on_release of
a child cgroup is inherited from its parent, which is reasonable,
but the implementation just sets the flag disabled.

Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 kernel/cgroup.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index d8abe99..e9c2fb0 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -2232,7 +2232,6 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
 
 	mutex_lock(&cgroup_mutex);
 
-	cgrp->flags = 0;
 	INIT_LIST_HEAD(&cgrp->sibling);
 	INIT_LIST_HEAD(&cgrp->children);
 	INIT_LIST_HEAD(&cgrp->css_sets);
@@ -2242,6 +2241,9 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
 	cgrp->root = parent->root;
 	cgrp->top_cgroup = parent->top_cgroup;
 
+	if (notify_on_release(parent))
+		set_bit(CGRP_NOTIFY_ON_RELEASE, &cgrp->flags);
+
 	for_each_subsys(root, ss) {
 		struct cgroup_subsys_state *css = ss->create(ss, cgrp);
 		if (IS_ERR(css)) {
-- 
1.5.4.rc3
