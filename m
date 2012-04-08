From: "\"Eric W. Beiderman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 08/43] userns: Add an explicit reference to the parent user
	namespace
Date: Sat,  7 Apr 2012 22:15:04 -0700
Message-ID: <1333862139-31737-8-git-send-email-ebiederm@xmission.com>
References: <m11unyn70b.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m11unyn70b.fsf-+imSwln9KH6u2/kzUuoCbdi2O/JbrIOy@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Cyrill Gorcunov <gorcunov-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

From: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

I am about to remove the struct user_namespace reference from struct user_struct.
So keep an explicit track of the parent user namespace.

Take advantage of this new reference and replace instances of user_ns->creator->user_ns
with user_ns->parent.

Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 include/linux/user_namespace.h |    1 +
 kernel/user_namespace.c        |   13 ++++++-------
 security/commoncap.c           |    2 +-
 3 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.h
index faf4679..dc2d85a 100644
--- a/include/linux/user_namespace.h
+++ b/include/linux/user_namespace.h
@@ -12,6 +12,7 @@
 struct user_namespace {
 	struct kref		kref;
 	struct hlist_head	uidhash_table[UIDHASH_SZ];
+	struct user_namespace	*parent;
 	struct user_struct	*creator;
 	struct work_struct	destroyer;
 };
diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
index 58bb878..c15e533 100644
--- a/kernel/user_namespace.c
+++ b/kernel/user_namespace.c
@@ -45,6 +45,7 @@ int create_user_ns(struct cred *new)
 	}
 
 	/* set the new root user in the credentials under preparation */
+	ns->parent = parent_ns;
 	ns->creator = new->user;
 	new->user = root_user;
 	new->uid = new->euid = new->suid = new->fsuid = 0;
@@ -60,8 +61,6 @@ int create_user_ns(struct cred *new)
 	/* Leave the reference to our user_ns with the new cred */
 	new->user_ns = ns;
 
-	put_user_ns(parent_ns);
-
 	return 0;
 }
 
@@ -72,10 +71,12 @@ int create_user_ns(struct cred *new)
  */
 static void free_user_ns_work(struct work_struct *work)
 {
-	struct user_namespace *ns =
+	struct user_namespace *parent, *ns =
 		container_of(work, struct user_namespace, destroyer);
+	parent = ns->parent;
 	free_uid(ns->creator);
 	kmem_cache_free(user_ns_cachep, ns);
+	put_user_ns(parent);
 }
 
 void free_user_ns(struct kref *kref)
@@ -99,8 +100,7 @@ uid_t user_ns_map_uid(struct user_namespace *to, const struct cred *cred, uid_t
 	/* Is cred->user the creator of the target user_ns
 	 * or the creator of one of it's parents?
 	 */
-	for ( tmp = to; tmp != &init_user_ns;
-	      tmp = tmp->creator->user_ns ) {
+	for ( tmp = to; tmp != &init_user_ns; tmp = tmp->parent ) {
 		if (cred->user == tmp->creator) {
 			return (uid_t)0;
 		}
@@ -120,8 +120,7 @@ gid_t user_ns_map_gid(struct user_namespace *to, const struct cred *cred, gid_t
 	/* Is cred->user the creator of the target user_ns
 	 * or the creator of one of it's parents?
 	 */
-	for ( tmp = to; tmp != &init_user_ns;
-	      tmp = tmp->creator->user_ns ) {
+	for ( tmp = to; tmp != &init_user_ns; tmp = tmp->parent ) {
 		if (cred->user == tmp->creator) {
 			return (gid_t)0;
 		}
diff --git a/security/commoncap.c b/security/commoncap.c
index 8b3e10e..435d074 100644
--- a/security/commoncap.c
+++ b/security/commoncap.c
@@ -92,7 +92,7 @@ int cap_capable(const struct cred *cred, struct user_namespace *targ_ns,
 		 *If you have a capability in a parent user ns, then you have
 		 * it over all children user namespaces as well.
 		 */
-		targ_ns = targ_ns->creator->user_ns;
+		targ_ns = targ_ns->parent;
 	}
 
 	/* We never get here */
-- 
1.7.2.5
