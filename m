From: "Kirill A. Shutemov" <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
Subject: [PATCH v2 -mmotm 2/4] cgroups: remove events before destroying
	subsystem state objects
Date: Mon, 22 Feb 2010 17:43:40 +0200
Message-ID: <690745ebd257c74a1c47d552fec7fbb0b5efb7d0.1266853233.git.kirill__25755.8965277441$1266853502$gmane$org@shutemov.name>
References: <1f8bd63acb6485c88f8539e009459a28fb6ad55b.1266853233.git.kirill@shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1f8bd63acb6485c88f8539e009459a28fb6ad55b.1266853233.git.kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
In-Reply-To: <1f8bd63acb6485c88f8539e009459a28fb6ad55b.1266853233.git.kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
References: <1f8bd63acb6485c88f8539e009459a28fb6ad55b.1266853233.git.kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org
Cc: Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, Dan Malek <dan-L1vi/lXTdtvkgf6YlCu6wwC/G2K4zDHf@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Events should be removed after rmdir of cgroup directory, but before
destroying subsystem state objects. Let's take reference to cgroup
directory dentry to do that.

Signed-off-by: Kirill A. Shutemov <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hioryu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
---
 include/linux/cgroup.h |    3 ---
 kernel/cgroup.c        |    8 ++++++++
 mm/memcontrol.c        |    9 ---------
 3 files changed, 8 insertions(+), 12 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 64cebfe..1719c75 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -395,9 +395,6 @@ struct cftype {
 	 * closes the eventfd or on cgroup removing.
 	 * This callback must be implemented, if you want provide
 	 * notification functionality.
-	 *
-	 * Be careful. It can be called after destroy(), so you have
-	 * to keep all nesessary data, until all events are removed.
 	 */
 	int (*unregister_event)(struct cgroup *cgrp, struct cftype *cft,
 			struct eventfd_ctx *eventfd);
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 46903cb..d142524 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -2979,6 +2979,7 @@ static void cgroup_event_remove(struct work_struct *work)
 
 	eventfd_ctx_put(event->eventfd);
 	kfree(event);
+	dput(cgrp->dentry);
 }
 
 /*
@@ -3099,6 +3100,13 @@ static int cgroup_write_event_control(struct cgroup *cgrp, struct cftype *cft,
 		goto fail;
 	}
 
+	/*
+	 * Events should be removed after rmdir of cgroup directory, but before
+	 * destroying subsystem state objects. Let's take reference to cgroup
+	 * directory dentry to do that.
+	 */
+	dget(cgrp->dentry);
+
 	spin_lock(&cgrp->event_list_lock);
 	list_add(&event->list, &cgrp->event_list);
 	spin_unlock(&cgrp->event_list_lock);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index a443c30..8fe6e7f 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3358,12 +3358,6 @@ static int mem_cgroup_register_event(struct cgroup *cgrp, struct cftype *cft,
 		}
 	}
 
-	/*
-	 * We need to increment refcnt to be sure that all thresholds
-	 * will be unregistered before calling __mem_cgroup_free()
-	 */
-	mem_cgroup_get(memcg);
-
 	if (type == _MEM)
 		rcu_assign_pointer(memcg->thresholds, thresholds_new);
 	else
@@ -3457,9 +3451,6 @@ assign:
 	/* To be sure that nobody uses thresholds before freeing it */
 	synchronize_rcu();
 
-	for (i = 0; i < thresholds->size - size; i++)
-		mem_cgroup_put(memcg);
-
 	kfree(thresholds);
 unlock:
 	mutex_unlock(&memcg->thresholds_lock);
-- 
1.6.6.2
