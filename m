From: xemul@openvz.org
Subject: [PATCH 6/20] Add support for pid namespaces hierarchy
Date: Fri, 10 Aug 2007 15:48:01 +0400
Message-ID: <46BC5071.mailGJD1M0IFY@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932543AbXHJLwJ@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: akpm@osdl.org
Cc: xemul@openvz.org, devel@openvz.org, linux-kernel@vger.kernel.org, containers@lists.osdl.org, oleg@tv-sign.ru, sukadev@us.ibm.com
List-Id: containers.vger.kernel.org

Each namespace has a parent and is characterized by its "level".
Level is the number of the namespace generation. E.g. init namespace
has level 0, after cloning new one it will have level 1, the next
one - 2 and so on and so forth. This level is not explicitly limited.

True hierarchy must have some way to find each namespace's children,
but it is not used in the patches, so this ability is not added (yet).

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
Cc: Oleg Nesterov <oleg@tv-sign.ru>

---

 include/linux/pid_namespace.h |    2 ++
 kernel/pid.c                  |    3 ++-
 2 files changed, 4 insertions(+), 1 deletion(-)

--- ./include/linux/pid_namespace.h.ve5	2007-08-09 17:54:49.000000000 +0400
+++ ./include/linux/pid_namespace.h	2007-08-10 12:39:22.000000000 +0400
@@ -21,6 +21,8 @@ struct pid_namespace {
 	int last_pid;
 	struct task_struct *child_reaper;
 	struct kmem_cache *pid_cachep;
+	int level;
+	struct pid_namespace *parent;
 };
 
 extern struct pid_namespace init_pid_ns;
--- ./kernel/pid.c.ve5	2007-08-09 17:54:51.000000000 +0400
+++ ./kernel/pid.c	2007-08-10 12:39:57.000000000 +0400
@@ -67,7 +67,8 @@ struct pid_namespace init_pid_ns = {
 		[ 0 ... PIDMAP_ENTRIES-1] = { ATOMIC_INIT(BITS_PER_PAGE), NULL }
 	},
 	.last_pid = 0,
-	.child_reaper = &init_task
+	.level = 0,
+	.child_reaper = &init_task,
 };
 
 int is_global_init(struct task_struct *tsk)
