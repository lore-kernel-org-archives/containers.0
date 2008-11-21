From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH] ns_cgroup: remove unused spinlock
Date: Fri, 21 Nov 2008 11:59:16 +0800
Message-ID: <49263214.5080604__47167.0595849448$1227240105$gmane$org@cn.fujitsu.com>
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
Cc: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

I happened to find the spinlock in struct ns_cgroup is never
used.

Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 kernel/ns_cgroup.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/kernel/ns_cgroup.c b/kernel/ns_cgroup.c
index 43c2111..78bc3fd 100644
--- a/kernel/ns_cgroup.c
+++ b/kernel/ns_cgroup.c
@@ -13,7 +13,6 @@
 
 struct ns_cgroup {
 	struct cgroup_subsys_state css;
-	spinlock_t lock;
 };
 
 struct cgroup_subsys ns_subsys;
@@ -84,7 +83,6 @@ static struct cgroup_subsys_state *ns_create(struct cgroup_subsys *ss,
 	ns_cgroup = kzalloc(sizeof(*ns_cgroup), GFP_KERNEL);
 	if (!ns_cgroup)
 		return ERR_PTR(-ENOMEM);
-	spin_lock_init(&ns_cgroup->lock);
 	return &ns_cgroup->css;
 }
 
-- 
1.5.4.rc3
