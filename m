From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: [PATCH 2/10] Pidns: use kzalloc to allocate new pid namespace
Date: Thu, 10 Apr 2008 12:43:18 +0400
Message-ID: <47FDD326.8070105@openvz.org>
References: <47FDD267.80700@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <47FDD267.80700-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>, Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Alexey Dobriyan <adobriyan-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

It makes many fields initialization implicit, fixes void * = 0
(the ns->pidmap[i].page = 0) noise and will help in auto-setting 
to NULL bsd-acct related field.

Signed-off-by: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>

---
 kernel/pid_namespace.c |    8 ++------
 1 files changed, 2 insertions(+), 6 deletions(-)

diff --git a/kernel/pid_namespace.c b/kernel/pid_namespace.c
index cb17497..06331cc 100644
--- a/kernel/pid_namespace.c
+++ b/kernel/pid_namespace.c
@@ -71,7 +71,7 @@ static struct pid_namespace *create_pid_namespace(unsigned int level)
 	struct pid_namespace *ns;
 	int i;
 
-	ns = kmem_cache_alloc(pid_ns_cachep, GFP_KERNEL);
+	ns = kmem_cache_zalloc(pid_ns_cachep, GFP_KERNEL);
 	if (ns == NULL)
 		goto out;
 
@@ -84,17 +84,13 @@ static struct pid_namespace *create_pid_namespace(unsigned int level)
 		goto out_free_map;
 
 	kref_init(&ns->kref);
-	ns->last_pid = 0;
-	ns->child_reaper = NULL;
 	ns->level = level;
 
 	set_bit(0, ns->pidmap[0].page);
 	atomic_set(&ns->pidmap[0].nr_free, BITS_PER_PAGE - 1);
 
-	for (i = 1; i < PIDMAP_ENTRIES; i++) {
-		ns->pidmap[i].page = 0;
+	for (i = 1; i < PIDMAP_ENTRIES; i++)
 		atomic_set(&ns->pidmap[i].nr_free, BITS_PER_PAGE);
-	}
 
 	return ns;
 
-- 
1.5.3.4
