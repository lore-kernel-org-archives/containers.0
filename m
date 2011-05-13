From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: acl_permission_check: disgusting performance
Date: Fri, 13 May 2011 08:19:04 -0500
Message-ID: <20110513131904.GA2519__20039.3584011637$1305292808$gmane$org@mail.hallyn.com>
References: <BANLkTi=nc3WGaASQm1Pc9byshLOmLf2bXQ@mail.gmail.com>
	<20110513025013.GA13209@mail.hallyn.com>
	<20110513040214.GA25270@mail.hallyn.com>
	<BANLkTim3cy8Jf3URYTW+cbr3nrdWVbsmGw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <BANLkTim3cy8Jf3URYTW+cbr3nrdWVbsmGw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Linus Torvalds (torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org):
> On Thu, May 12, 2011 at 9:02 PM, Serge E. Hallyn <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> wrote:
> >
> > I wonder how much this would help: =A0(only compile-tested)
> =

> So it should help a lot, but it breaks when CONFIG_USER_NS isn't even
> set (the case that Eric fixed.
> =

> So instead, do this:
> =

>  (a) get rid of the "_current_user_ns()" thing. There is no reason to
> have it, if it's directly off "current->cred", then it's cheaper to
> inline it than have a function just for two pointer indirections.

Unfortunately that was not there as an optimization but because it
gets around a circular dependency between cred.h and capability.h.
Ideally we would keep capability.h from having to know about struct
cred.

The two simplest solutions are to uninline nsown_capable() into
capability.c, and to move it from capability.h to cred.h, with the
expectation that all callers of nsown_capable() #include cred.h
(which they do).  I'm uninlining it here, hoping that the compiler
will inline it for us.

From: Serge E. Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Date: Fri, 13 May 2011 04:27:54 +0100
Subject: [PATCH 1/1] Cache user_ns in struct cred (v2)

If !CONFIG_USERNS, have current_user_ns() defined to (&init_user_ns).

Get rid of _current_user_ns.  This requires nsown_capable() to be
defined in capability.c rather than as static inline in capability.h,
so do that.

Request_key needs init_user_ns defined at current_user_ns if
!CONFIG_USERNS, so forward-declare that in cred.h if !CONFIG_USERNS
at current_user_ns() define.

Compile-tested with and without CONFIG_USERNS.

Signed-off-by: Serge E. Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
---
 include/linux/capability.h |   13 +------------
 include/linux/cred.h       |   10 ++++++++--
 kernel/capability.c        |   12 ++++++++++++
 kernel/cred.c              |   12 ++++++------
 4 files changed, 27 insertions(+), 20 deletions(-)

diff --git a/include/linux/capability.h b/include/linux/capability.h
index 16ee8b4..d4675af 100644
--- a/include/linux/capability.h
+++ b/include/linux/capability.h
@@ -546,18 +546,7 @@ extern bool has_capability_noaudit(struct task_struct =
*t, int cap);
 extern bool capable(int cap);
 extern bool ns_capable(struct user_namespace *ns, int cap);
 extern bool task_ns_capable(struct task_struct *t, int cap);
-
-/**
- * nsown_capable - Check superior capability to one's own user_ns
- * @cap: The capability in question
- *
- * Return true if the current task has the given superior capability
- * targeted at its own user namespace.
- */
-static inline bool nsown_capable(int cap)
-{
-	return ns_capable(current_user_ns(), cap);
-}
+extern bool nsown_capable(int cap);
 =

 /* audit system wants to get cap info from files as well */
 extern int get_vfs_caps_from_disk(const struct dentry *dentry, struct cpu_=
vfs_cap_data *cpu_caps);
diff --git a/include/linux/cred.h b/include/linux/cred.h
index 9aeeb0b..be16b61 100644
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
@@ -354,10 +355,15 @@ static inline void put_cred(const struct cred *_cred)
 #define current_fsgid() 	(current_cred_xxx(fsgid))
 #define current_cap()		(current_cred_xxx(cap_effective))
 #define current_user()		(current_cred_xxx(user))
-#define _current_user_ns()	(current_cred_xxx(user)->user_ns)
 #define current_security()	(current_cred_xxx(security))
 =

-extern struct user_namespace *current_user_ns(void);
+#ifdef CONFIG_USER_NS
+#define current_user_ns() (current_cred_xxx(user_ns))
+#else
+extern struct user_namespace init_user_ns;
+#define current_user_ns() (&init_user_ns)
+#endif
+
 =

 #define current_uid_gid(_uid, _gid)		\
 do {						\
diff --git a/kernel/capability.c b/kernel/capability.c
index bf0c734..32a80e0 100644
--- a/kernel/capability.c
+++ b/kernel/capability.c
@@ -399,3 +399,15 @@ bool task_ns_capable(struct task_struct *t, int cap)
 	return ns_capable(task_cred_xxx(t, user)->user_ns, cap);
 }
 EXPORT_SYMBOL(task_ns_capable);
+
+/**
+ * nsown_capable - Check superior capability to one's own user_ns
+ * @cap: The capability in question
+ *
+ * Return true if the current task has the given superior capability
+ * targeted at its own user namespace.
+ */
+bool nsown_capable(int cap)
+{
+	return ns_capable(current_user_ns(), cap);
+}
diff --git a/kernel/cred.c b/kernel/cred.c
index 5557b55..8093c16 100644
--- a/kernel/cred.c
+++ b/kernel/cred.c
@@ -54,6 +54,7 @@ struct cred init_cred =3D {
 	.cap_effective		=3D CAP_INIT_EFF_SET,
 	.cap_bset		=3D CAP_INIT_BSET,
 	.user			=3D INIT_USER,
+	.user_ns		=3D &init_user_ns,
 	.group_info		=3D &init_groups,
 #ifdef CONFIG_KEYS
 	.tgcred			=3D &init_tgcred,
@@ -410,6 +411,11 @@ int copy_creds(struct task_struct *p, unsigned long cl=
one_flags)
 			goto error_put;
 	}
 =

+	/* cache user_ns in cred.  Doesn't need a refcount because it will
+	 * stay pinned by cred->user
+	 */
+	new->user_ns =3D new->user->user_ns;
+
 #ifdef CONFIG_KEYS
 	/* new threads get their own thread keyrings if their parent already
 	 * had one */
@@ -741,12 +747,6 @@ int set_create_files_as(struct cred *new, struct inode=
 *inode)
 }
 EXPORT_SYMBOL(set_create_files_as);
 =

-struct user_namespace *current_user_ns(void)
-{
-	return _current_user_ns();
-}
-EXPORT_SYMBOL(current_user_ns);
-
 #ifdef CONFIG_DEBUG_CREDENTIALS
 =

 bool creds_are_invalid(const struct cred *cred)
-- =

1.7.0.4
