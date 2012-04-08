From: "\"Eric W. Beiderman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 07/43] cred: Refcount the user_ns pointed to by the cred.
Date: Sat,  7 Apr 2012 22:15:03 -0700
Message-ID: <1333862139-31737-7-git-send-email-ebiederm@xmission.com>
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

struct user_struct will shortly loose it's user_ns reference
so make the cred user_ns reference a proper reference complete
with reference counting.

Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 include/linux/cred.h         |    2 +-
 kernel/cred.c                |    8 +++-----
 kernel/user_namespace.c      |    8 +++++---
 security/keys/process_keys.c |    2 +-
 4 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/include/linux/cred.h b/include/linux/cred.h
index d12c4e4..2c60ec8 100644
--- a/include/linux/cred.h
+++ b/include/linux/cred.h
@@ -146,7 +146,7 @@ struct cred {
 	void		*security;	/* subjective LSM security */
 #endif
 	struct user_struct *user;	/* real user ID subscription */
-	struct user_namespace *user_ns; /* cached user->user_ns */
+	struct user_namespace *user_ns; /* user_ns the caps and keyrings are relative to. */
 	struct group_info *group_info;	/* supplementary groups for euid/fsgid */
 	struct rcu_head	rcu;		/* RCU deletion hook */
 };
diff --git a/kernel/cred.c b/kernel/cred.c
index 97b36ee..7a0d806 100644
--- a/kernel/cred.c
+++ b/kernel/cred.c
@@ -148,6 +148,7 @@ static void put_cred_rcu(struct rcu_head *rcu)
 	if (cred->group_info)
 		put_group_info(cred->group_info);
 	free_uid(cred->user);
+	put_user_ns(cred->user_ns);
 	kmem_cache_free(cred_jar, cred);
 }
 
@@ -303,6 +304,7 @@ struct cred *prepare_creds(void)
 	set_cred_subscribers(new, 0);
 	get_group_info(new->group_info);
 	get_uid(new->user);
+	get_user_ns(new->user_ns);
 
 #ifdef CONFIG_KEYS
 	key_get(new->thread_keyring);
@@ -412,11 +414,6 @@ int copy_creds(struct task_struct *p, unsigned long clone_flags)
 			goto error_put;
 	}
 
-	/* cache user_ns in cred.  Doesn't need a refcount because it will
-	 * stay pinned by cred->user
-	 */
-	new->user_ns = new->user->user_ns;
-
 #ifdef CONFIG_KEYS
 	/* new threads get their own thread keyrings if their parent already
 	 * had one */
@@ -676,6 +673,7 @@ struct cred *prepare_kernel_cred(struct task_struct *daemon)
 	atomic_set(&new->usage, 1);
 	set_cred_subscribers(new, 0);
 	get_uid(new->user);
+	get_user_ns(new->user_ns);
 	get_group_info(new->group_info);
 
 #ifdef CONFIG_KEYS
diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
index f084083..58bb878 100644
--- a/kernel/user_namespace.c
+++ b/kernel/user_namespace.c
@@ -24,7 +24,7 @@ static struct kmem_cache *user_ns_cachep __read_mostly;
  */
 int create_user_ns(struct cred *new)
 {
-	struct user_namespace *ns;
+	struct user_namespace *ns, *parent_ns = new->user_ns;
 	struct user_struct *root_user;
 	int n;
 
@@ -57,8 +57,10 @@ int create_user_ns(struct cred *new)
 #endif
 	/* tgcred will be cleared in our caller bc CLONE_THREAD won't be set */
 
-	/* root_user holds a reference to ns, our reference can be dropped */
-	put_user_ns(ns);
+	/* Leave the reference to our user_ns with the new cred */
+	new->user_ns = ns;
+
+	put_user_ns(parent_ns);
 
 	return 0;
 }
diff --git a/security/keys/process_keys.c b/security/keys/process_keys.c
index 70febff..447fb76 100644
--- a/security/keys/process_keys.c
+++ b/security/keys/process_keys.c
@@ -858,7 +858,7 @@ void key_replace_session_keyring(void)
 	new-> sgid	= old-> sgid;
 	new->fsgid	= old->fsgid;
 	new->user	= get_uid(old->user);
-	new->user_ns	= new->user_ns;
+	new->user_ns	= get_user_ns(new->user_ns);
 	new->group_info	= get_group_info(old->group_info);
 
 	new->securebits	= old->securebits;
-- 
1.7.2.5
