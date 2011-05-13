From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: acl_permission_check: disgusting performance
Date: Thu, 12 May 2011 23:02:14 -0500
Message-ID: <20110513040214.GA25270__46775.3527722836$1305259454$gmane$org@mail.hallyn.com>
References: <BANLkTi=nc3WGaASQm1Pc9byshLOmLf2bXQ@mail.gmail.com>
	<20110513025013.GA13209@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110513025013.GA13209-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Id: containers.vger.kernel.org

I wonder how much this would help:  (only compile-tested)

I will look into how to do some profiling tomorrow.

From: Serge E. Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Date: Fri, 13 May 2011 04:27:54 +0100
Subject: [PATCH 1/1] Cache struct cred in acl_permission_check, and cache user_ns
 in struct cred.

Signed-off-by: Serge E. Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
---
 fs/namei.c           |    5 +++--
 include/linux/cred.h |    3 ++-
 kernel/cred.c        |    6 ++++++
 3 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index 54fc993..eb0f4ea 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -180,13 +180,14 @@ static int acl_permission_check(struct inode *inode, int mask, unsigned int flag
 		int (*check_acl)(struct inode *inode, int mask, unsigned int flags))
 {
 	umode_t			mode = inode->i_mode;
+	const struct cred	*cred = current_cred();
 
 	mask &= MAY_READ | MAY_WRITE | MAY_EXEC;
 
-	if (current_user_ns() != inode_userns(inode))
+	if (cred->user_ns != inode_userns(inode))
 		goto other_perms;
 
-	if (current_fsuid() == inode->i_uid)
+	if (cred->fsuid == inode->i_uid)
 		mode >>= 6;
 	else {
 		if (IS_POSIXACL(inode) && (mode & S_IRWXG) && check_acl) {
diff --git a/include/linux/cred.h b/include/linux/cred.h
index 9aeeb0b..a2a892c 100644
--- a/include/linux/cred.h
+++ b/include/linux/cred.h
@@ -146,6 +146,7 @@ struct cred {
 	void		*security;	/* subjective LSM security */
 #endif
 	struct user_struct *user;	/* real user ID subscription */
+	struct user_namespace *user_ns; /* cached user->user_ns */
 	struct group_info *group_info;	/* supplementary groups for euid/fsgid */
 	struct rcu_head	rcu;		/* RCU deletion hook */
 };
@@ -354,7 +355,7 @@ static inline void put_cred(const struct cred *_cred)
 #define current_fsgid() 	(current_cred_xxx(fsgid))
 #define current_cap()		(current_cred_xxx(cap_effective))
 #define current_user()		(current_cred_xxx(user))
-#define _current_user_ns()	(current_cred_xxx(user)->user_ns)
+#define _current_user_ns()	(current_cred_xxx(user_ns))
 #define current_security()	(current_cred_xxx(security))
 
 extern struct user_namespace *current_user_ns(void);
diff --git a/kernel/cred.c b/kernel/cred.c
index 5557b55..a3dcf28 100644
--- a/kernel/cred.c
+++ b/kernel/cred.c
@@ -54,6 +54,7 @@ struct cred init_cred = {
 	.cap_effective		= CAP_INIT_EFF_SET,
 	.cap_bset		= CAP_INIT_BSET,
 	.user			= INIT_USER,
+	.user_ns		= &init_user_ns,
 	.group_info		= &init_groups,
 #ifdef CONFIG_KEYS
 	.tgcred			= &init_tgcred,
@@ -410,6 +411,11 @@ int copy_creds(struct task_struct *p, unsigned long clone_flags)
 			goto error_put;
 	}
 
+	/* cache user_ns in cred.  Doesn't need a refcount because it will
+	 * stay pinned by cred->user
+	 */
+	new->user_ns = new->user->user_ns;
+
 #ifdef CONFIG_KEYS
 	/* new threads get their own thread keyrings if their parent already
 	 * had one */
-- 
1.7.0.4
