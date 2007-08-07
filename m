From: xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
Subject: [PATCH 7/20] Add support for pid namespaces hierarchy
Date: Tue, 07 Aug 2007 13:29:48 +0400
Message-ID: <46B83B8C.mailG3Y11OD18@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
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
To: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

Each namespace has a parent and is characterized by its "level".
Level is the number of the namespace generation. E.g. init namespace
has level 0, after cloning new one it will have level 1, the next
one - 2 and so on and so forth. This level is not explicitly limited.

True hierarchy must have some way to find each namespace's children,
but it is not used in the patches, so this ability is not added (yet).

Signed-off-by: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>

---

 include/linux/pid_namespace.h |    2 ++
 kernel/pid.c                  |    3 ++-
 2 files changed, 4 insertions(+), 1 deletion(-)

--- ./include/linux/pid_namespace.h.ve7	2007-08-06 14:54:42.000000000 +0400
+++ ./include/linux/pid_namespace.h	2007-08-06 14:58:34.000000000 +0400
@@ -21,6 +21,8 @@ struct pid_namespace {
 	int last_pid;
 	struct task_struct *child_reaper;
 	struct kmem_cache *pid_cachep;
+	int level;
+	struct pid_namespace *parent;
 };
 
 extern struct pid_namespace init_pid_ns;
--- ./kernel/pid.c.ve7	2007-08-06 14:58:17.000000000 +0400
+++ ./kernel/pid.c	2007-08-06 14:58:19.000000000 +0400
@@ -67,7 +67,8 @@ struct pid_namespace init_pid_ns = {
 		[ 0 ... PIDMAP_ENTRIES-1] = { ATOMIC_INIT(BITS_PER_PAGE), NULL }
 	},
 	.last_pid = 0,
-	.child_reaper = &init_task
+	.level = 0,
+	.child_reaper = &init_task,
 };
 EXPORT_SYMBOL(init_pid_ns);
