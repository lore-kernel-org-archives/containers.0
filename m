From: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH] cgroups: defer free css_set
Date: Fri, 21 Nov 2008 16:49:31 +0800
Message-ID: <4926761B.2060608__45306.5325310037$1227265090$gmane$org@cn.fujitsu.com>
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
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers@lists.l>
List-Id: containers.vger.kernel.org


we free css_set when refcnt became 0 immediately(except cgroup_attach_task()).
I will destroy the data which read side maybe still access it.
this patch use call_rcu() to defer free css_set

Signed-off-by: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 1164963..22901ff 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -178,6 +178,8 @@ struct css_set {
 	 */
 	struct list_head cg_links;
 
+	struct rcu_head rcu;
+
 	/*
 	 * Set of subsystem states, one for each subsystem. This array
 	 * is immutable after creation apart from the init_css_set
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 358e775..ddc10ac 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -252,6 +252,11 @@ static void unlink_css_set(struct css_set *cg)
 	}
 }
 
+static void rcu_free_css_set(struct rcu_head *head)
+{
+	kfree(container_of(head, struct css_set, rcu));
+}
+
 static void __put_css_set(struct css_set *cg, int taskexit)
 {
 	int i;
@@ -281,7 +286,7 @@ static void __put_css_set(struct css_set *cg, int taskexit)
 		}
 	}
 	rcu_read_unlock();
-	kfree(cg);
+	call_rcu(&cg->rcu, rcu_free_css_set);
 }
 
 /*
@@ -1267,7 +1277,6 @@ int cgroup_attach_task(struct cgroup *cgrp, struct task_struct *tsk)
 			ss->attach(ss, cgrp, oldcgrp, tsk);
 	}
 	set_bit(CGRP_RELEASABLE, &oldcgrp->flags);
-	synchronize_rcu();
 	put_css_set(cg);
 	return 0;
 }
