From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH] user_ns: Improve the user_ns on-the-slab packaging
Date: Tue, 07 Dec 2010 17:12:33 +0300
Message-ID: <4CFE40D1.5000309@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>, Linux Containers <containers@lists.osdl.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Serge E. Hallyn" <serge@hallyn.com>
List-Id: containers.vger.kernel.org

Currently on 64-bit arch the user_namespace is 2096 and when
being kmalloc-ed it resides on a 4k slab wasting 2003 bytes.

If we allocate a separate cache for it and reduce the hash size
from 128 to 64 chains the packaging becomes *much* better - the
struct is 1072 bytes and the hole between is 98 bytes.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.h
index 8178156..faf4679 100644
--- a/include/linux/user_namespace.h
+++ b/include/linux/user_namespace.h
@@ -6,7 +6,7 @@
 #include <linux/sched.h>
 #include <linux/err.h>
 
-#define UIDHASH_BITS	(CONFIG_BASE_SMALL ? 3 : 8)
+#define UIDHASH_BITS	(CONFIG_BASE_SMALL ? 3 : 7)
 #define UIDHASH_SZ	(1 << UIDHASH_BITS)
 
 struct user_namespace {
diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
index 2591583..8aafa80 100644
--- a/kernel/user_namespace.c
+++ b/kernel/user_namespace.c
@@ -12,6 +12,8 @@
 #include <linux/highuid.h>
 #include <linux/cred.h>
 
+static struct kmem_cache *user_ns_cachep __read_mostly;
+
 /*
  * Create a new user namespace, deriving the creator from the user in the
  * passed credentials, and replacing that user with the new root user for the
@@ -26,7 +28,7 @@ int create_user_ns(struct cred *new)
 	struct user_struct *root_user;
 	int n;
 
-	ns = kmalloc(sizeof(struct user_namespace), GFP_KERNEL);
+	ns = kmem_cache_alloc(user_ns_cachep, GFP_KERNEL);
 	if (!ns)
 		return -ENOMEM;
 
@@ -38,7 +40,7 @@ int create_user_ns(struct cred *new)
 	/* Alloc new root user.  */
 	root_user = alloc_uid(ns, 0);
 	if (!root_user) {
-		kfree(ns);
+		kmem_cache_free(user_ns_cachep, ns);
 		return -ENOMEM;
 	}
 
@@ -71,7 +73,7 @@ static void free_user_ns_work(struct work_struct *work)
 	struct user_namespace *ns =
 		container_of(work, struct user_namespace, destroyer);
 	free_uid(ns->creator);
-	kfree(ns);
+	kmem_cache_free(user_ns_cachep, ns);
 }
 
 void free_user_ns(struct kref *kref)
@@ -126,3 +128,11 @@ gid_t user_ns_map_gid(struct user_namespace *to, const struct cred *cred, gid_t
 	/* No useful relationship so no mapping */
 	return overflowgid;
 }
+
+static __init int user_namespaces_init(void)
+{
+	user_ns_cachep = KMEM_CACHE(user_namespace, SLAB_PANIC);
+	return 0;
+}
+
+__initcall(user_namespaces_init);
