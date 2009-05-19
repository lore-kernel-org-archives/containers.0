From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 4/6] cr: checkpoint and restore task credentials
Date: Mon, 18 May 2009 20:45:38 -0500
Message-ID: <20090519014538.GD28312@us.ibm.com>
References: <20090519014446.GA28277@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090519014446.GA28277-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, alexey-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

This patch adds the checkpointing and restart of credentials
(uids, gids, and capabilities) to Oren's c/r patchset (on top
of v14).  It goes to great pains to re-use (and define when
needed) common helpers, in order to make sure that as security
code is modified, the cr code will be updated.  Some of the
helpers should still be moved (i.e. _creds() functions should
be in kernel/cred.c).

When building the credentials for the restarted process, I
1. create a new struct cred as a copy of the running task's
cred (using prepare_cred())
2. always authorize any changes to the new struct cred
based on the permissions of current_cred() (not the current
transient state of the new cred).

While this may mean that certain transient_cred1->transient_cred2
states are allowed which otherwise wouldn't be allowed, the
fact remains that current_cred() is allowed to transition to
transient_cred2.

The reconstructed creds are applied to the task at the very
end of the sys_restart call.  This ensures that any objects which
need to be re-created (file, socket, etc) are re-created using
the creds of the task calling sys_restart - preventing an unpriv
user from creating a privileged object, and ensuring that a
root task can restart a process which had started out privileged,
created some privileged objects, then dropped its privilege.

With these patches, the root user can restart checkpoint images
(created by either hallyn or root) of user hallyn's tasks,
resulting in a program owned by hallyn.

Plenty of bugs to be found, no doubt.

Changelog:
	May 18: fix more refcounting: if (userns 5, uid 0) had
		no active tasks or child user_namespaces, then
		it shouldn't exist at restart or it, its namespace,
		and its whole chain of creators will be leaked.
	May 14: fix some refcounting:
		1. a new user_ns needs a ref to remain pinned
		   by its root user
		2. current_user_ns needs an extra ref bc objhash
		   drops two on restart
		3. cred needs a ref for the real credentials bc
		   commit_creds eats one ref.
	May 13: folded in fix to userns refcounting.

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/objhash.c             |  119 ++++++++++-
 checkpoint/process.c             |  457 +++++++++++++++++++++++++++++++++++++-
 include/linux/checkpoint.h       |   11 +
 include/linux/checkpoint_hdr.h   |   57 +++++
 include/linux/checkpoint_types.h |    1 +
 5 files changed, 642 insertions(+), 3 deletions(-)

diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
index 5618fff..d2268c2 100644
--- a/checkpoint/objhash.c
+++ b/checkpoint/objhash.c
@@ -16,6 +16,7 @@
 #include <linux/file.h>
 #include <linux/sched.h>
 #include <linux/ipc_namespace.h>
+#include <linux/user_namespace.h>
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
 
@@ -155,6 +156,71 @@ static int obj_ipc_ns_users(void *ptr)
 	return atomic_read(&((struct ipc_namespace *) ptr)->count);
 }
 
+static int obj_cred_grab(void *ptr)
+{
+	get_cred((struct cred *) ptr);
+	return 0;
+}
+
+static void obj_cred_drop(void *ptr)
+{
+	put_cred((struct cred *) ptr);
+}
+
+static int obj_cred_users(void *ptr)
+{
+	return atomic_read(&((struct cred *) ptr)->usage);
+}
+
+static int obj_user_grab(void *ptr)
+{
+	struct user_struct *u = ptr;
+	(void) get_uid(u);
+	return 0;
+}
+
+static void obj_user_drop(void *ptr)
+{
+	free_uid((struct user_struct *) ptr);
+}
+
+static int obj_user_users(void *ptr)
+{
+	return atomic_read(&((struct user_struct *) ptr)->__count);
+}
+
+static int obj_userns_grab(void *ptr)
+{
+	get_user_ns((struct user_namespace *) ptr);
+	return 0;
+}
+
+static void obj_userns_drop(void *ptr)
+{
+	put_user_ns((struct user_namespace *) ptr);
+}
+
+static int obj_user_ns_users(void *ptr)
+{
+	return atomic_read(&((struct user_namespace *) ptr)->kref.refcount);
+}
+
+static int obj_groupinfo_grab(void *ptr)
+{
+	get_group_info((struct group_info *) ptr);
+	return 0;
+}
+
+static void obj_groupinfo_drop(void *ptr)
+{
+	put_group_info((struct group_info *) ptr);
+}
+
+static int obj_groupinfo_users(void *ptr)
+{
+	return atomic_read(&((struct group_info *) ptr)->usage);
+}
+
 static struct ckpt_obj_ops ckpt_obj_ops[] = {
 	/* ignored object */
 	{
@@ -221,6 +287,46 @@ static struct ckpt_obj_ops ckpt_obj_ops[] = {
 		.checkpoint = checkpoint_bad,
 		.restore = restore_bad,
 	},
+	/* user_ns object */
+	{
+		.obj_name = "USER_NS",
+		.obj_type = CKPT_OBJ_USER_NS,
+		.ref_drop = obj_userns_drop,
+		.ref_grab = obj_userns_grab,
+		.ref_users = obj_user_ns_users,
+		.checkpoint = checkpoint_userns,
+		.restore = restore_userns,
+	},
+	/* struct cred */
+	{
+		.obj_name = "CRED",
+		.obj_type = CKPT_OBJ_CRED,
+		.ref_drop = obj_cred_drop,
+		.ref_grab = obj_cred_grab,
+		.ref_users = obj_cred_users,
+		.checkpoint = checkpoint_cred,
+		.restore = restore_cred,
+	},
+	/* user object */
+	{
+		.obj_name = "USER",
+		.obj_type = CKPT_OBJ_USER,
+		.ref_drop = obj_user_drop,
+		.ref_grab = obj_user_grab,
+		.ref_users = obj_user_users,
+		.checkpoint = checkpoint_user,
+		.restore = restore_user,
+	},
+	/* struct groupinfo */
+	{
+		.obj_name = "GROUPINFO",
+		.obj_type = CKPT_OBJ_GROUPINFO,
+		.ref_drop = obj_groupinfo_drop,
+		.ref_grab = obj_groupinfo_grab,
+		.ref_users = obj_groupinfo_users,
+		.checkpoint = checkpoint_groupinfo,
+		.restore = restore_groupinfo,
+	},
 };
 
 
@@ -290,6 +396,18 @@ static struct ckpt_obj *obj_find_by_ptr(struct ckpt_ctx *ctx, void *ptr)
 	return NULL;
 }
 
+/*
+ * look up an obj and return objref if in hash, else
+ * return 0.  Used during checkpoint.
+ */
+int obj_lookup_dontadd(struct ckpt_ctx *ctx, void *ptr)
+{
+	struct ckpt_obj *obj = obj_find_by_ptr(ctx, ptr);
+	if (obj)
+		return obj->objref;
+	return 0;
+}
+
 static struct ckpt_obj *obj_find_by_objref(struct ckpt_ctx *ctx, int objref)
 {
 	struct hlist_head *h;
@@ -389,7 +507,6 @@ int ckpt_obj_lookup_add(struct ckpt_ctx *ctx, void *ptr,
 		*first = 0;
 	}
 
-	ckpt_debug("%s objref %d first %d\n", ops->obj_name, objref, *first);
 	return objref;
 }
 
diff --git a/checkpoint/process.c b/checkpoint/process.c
index d8d346b..74b411a 100644
--- a/checkpoint/process.c
+++ b/checkpoint/process.c
@@ -17,6 +17,7 @@
 #include <linux/poll.h>
 #include <linux/nsproxy.h>
 #include <linux/utsname.h>
+#include <linux/user_namespace.h>
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
 #include <linux/syscalls.h>
@@ -27,16 +28,210 @@
  * Checkpoint
  */
 
+#define CKPT_MAXGROUPS 15
+#define MAX_GROUPINFO_SIZE (sizeof(*h)+CKPT_MAXGROUPS*sizeof(gid_t))
+/* move this fn into kernel/sys.c next to group functions? */
+static int checkpoint_write_groupinfo(struct ckpt_ctx *ctx,
+					struct group_info *g)
+{
+	int ret, i, size;
+	struct ckpt_hdr_groupinfo *h;
+
+	if (g->ngroups > CKPT_MAXGROUPS) {
+		ckpt_debug("Too many groups: %d  (max is %d)\n",
+			g->ngroups, CKPT_MAXGROUPS);
+		return -E2BIG;
+	}
+	size = sizeof(*h) + g->ngroups * sizeof(__u32);
+	h = ckpt_hdr_get_type(ctx, size, CKPT_HDR_GROUPINFO);
+	if (!h)
+		return -ENOMEM;
+
+	h->ngroups = g->ngroups;
+	for (i = 0; i < g->ngroups; i++)
+		h->groups[i] = GROUP_AT(g, i);
+
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
+	ckpt_hdr_put(ctx, h);
+
+	return ret;
+}
+
+int checkpoint_groupinfo(struct ckpt_ctx *ctx, void *ptr)
+{
+	return checkpoint_write_groupinfo(ctx, (struct group_info *)ptr);
+}
+
+static int checkpoint_write_userns(struct ckpt_ctx *ctx,
+				   struct user_namespace *ns)
+{
+	struct ckpt_hdr_user_ns *h;
+	int creator_ref = 0;
+	unsigned int flags = 0;
+	struct user_namespace *root_ns;
+	int ret;
+
+	root_ns = task_cred_xxx(ctx->root_task, user)->user_ns;
+	if (ns == root_ns)
+		flags = CKPT_USERNS_INIT;
+	else
+		creator_ref = obj_lookup_dontadd(ctx, ns->creator);
+	if (!flags && !creator_ref)
+		return -EINVAL;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_USER_NS);
+	if (!h)
+		return -ENOMEM;
+	h->creator_ref = creator_ref;
+	h->flags = flags;
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
+	ckpt_hdr_put(ctx, h);
+
+	return ret;
+}
+
+int checkpoint_userns(struct ckpt_ctx *ctx, void *ptr)
+{
+	return checkpoint_write_userns(ctx, (struct user_namespace *) ptr);
+}
+
+/*
+ * write the user struct
+ * TODO keyring will need to be dumped
+ */
+#define UNSAVED_NS_MAX 5
+static int checkpoint_write_user(struct ckpt_ctx *ctx, struct user_struct *u)
+{
+	struct user_namespace *ns, *root_ns;
+	struct ckpt_hdr_user_struct *h;
+	int ns_objref;
+	int ret, i, unsaved_ns_nr = 0;
+	struct user_struct *save_u;
+	struct user_struct *unsaved_creators[UNSAVED_NS_MAX+1];
+
+	/* if we've already saved the userns, then life is good */
+	ns_objref = obj_lookup_dontadd(ctx, u->user_ns);
+	if (ns_objref)
+		goto write_user;
+
+	root_ns = task_cred_xxx(ctx->root_task, user)->user_ns;
+
+	if (u->user_ns == root_ns)
+		goto save_last_ns;
+
+	save_u = u;
+	do {
+		ns = save_u->user_ns;
+		save_u = ns->creator;
+		if (obj_lookup_dontadd(ctx, save_u))
+			goto found;
+		unsaved_creators[unsaved_ns_nr++] = save_u;
+	} while (ns != root_ns && unsaved_ns_nr < UNSAVED_NS_MAX);
+
+	if (unsaved_ns_nr == UNSAVED_NS_MAX)
+		return -E2BIG;
+found:
+	for (i = unsaved_ns_nr-1; i >= 0; i--) {
+		ret = checkpoint_obj(ctx, unsaved_creators[i], CKPT_OBJ_USER);
+		if (ret < 0)
+			return ret;
+	}
+
+save_last_ns:
+	ns_objref = checkpoint_obj(ctx, u->user_ns, CKPT_OBJ_USER_NS);
+	if (ns_objref < 0)
+		return ns_objref;
+
+write_user:
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_USER);
+	if (!h)
+		return -ENOMEM;
+
+	h->uid = u->uid;
+	h->userns_ref = ns_objref;
+
+	/* write out the user_struct */
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
+	ckpt_hdr_put(ctx, h);
+
+	return ret;
+}
+
+int checkpoint_user(struct ckpt_ctx *ctx, void *ptr)
+{
+	return checkpoint_write_user(ctx, (struct user_struct *)ptr);
+}
+
+/* This probably should go into kernel/cred.c */
+static int checkpoint_write_cred(struct ckpt_ctx *ctx, const struct cred *cred)
+{
+	int ret;
+	int groupinfo_ref, user_ref;
+	struct ckpt_hdr_cred *h;
+
+	groupinfo_ref = checkpoint_obj(ctx, cred->group_info,
+					CKPT_OBJ_GROUPINFO);
+	if (groupinfo_ref < 0)
+		return groupinfo_ref;
+	user_ref = checkpoint_obj(ctx, cred->user, CKPT_OBJ_USER);
+	if (user_ref < 0)
+		return user_ref;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_CRED);
+	if (!h)
+		return -ENOMEM;
+
+	h->version = 1;
+	h->uid = cred->uid;
+	h->suid = cred->suid;
+	h->euid = cred->euid;
+	h->fsuid = cred->fsuid;
+
+	h->gid = cred->gid;
+	h->sgid = cred->sgid;
+	h->egid = cred->egid;
+	h->fsgid = cred->fsgid;
+
+	checkpoint_save_cap(&h->cap_i, cred->cap_inheritable);
+	checkpoint_save_cap(&h->cap_p, cred->cap_permitted);
+	checkpoint_save_cap(&h->cap_e, cred->cap_effective);
+	checkpoint_save_cap(&h->cap_x, cred->cap_bset);
+
+	h->user_ref = user_ref;
+	h->groupinfo_ref = groupinfo_ref;
+
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
+	ckpt_hdr_put(ctx, h);
+
+	return ret;
+}
+
+int checkpoint_cred(struct ckpt_ctx *ctx, void *ptr)
+{
+	return checkpoint_write_cred(ctx, (struct cred *) ptr);
+}
+
 /* dump the task_struct of a given task */
 static int checkpoint_task_struct(struct ckpt_ctx *ctx, struct task_struct *t)
 {
 	struct ckpt_hdr_task *h;
 	int ret;
+	int realcred_ref, ecred_ref;
+
+	realcred_ref = checkpoint_obj(ctx, t->real_cred, CKPT_OBJ_CRED);
+	if (realcred_ref < 0)
+		return realcred_ref;
+
+	ecred_ref = checkpoint_obj(ctx, t->cred, CKPT_OBJ_CRED);
+	if (ecred_ref < 0)
+		return ecred_ref;
 
 	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_TASK);
 	if (!h)
 		return -ENOMEM;
 
+	h->cred_ref = realcred_ref;
+	h->ecred_ref = ecred_ref;
 	h->state = t->state;
 	h->exit_state = t->exit_state;
 	h->exit_code = t->exit_code;
@@ -348,8 +543,226 @@ int checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
  * Restart
  */
 
+static struct group_info *restore_read_groupinfo(struct ckpt_ctx *ctx)
+{
+	struct group_info *g;
+	struct ckpt_hdr_groupinfo *h;
+	int i;
+
+	h = ckpt_read_buf_type(ctx, MAX_GROUPINFO_SIZE, CKPT_HDR_GROUPINFO);
+	if (IS_ERR(h))
+		return ERR_PTR(PTR_ERR(h));
+	if (h->ngroups > CKPT_MAXGROUPS) {
+		g = ERR_PTR(-EINVAL);
+		goto out;
+	}
+	g = groups_alloc(h->ngroups);
+	if (!g) {
+		g = ERR_PTR(-ENOMEM);
+		goto out;
+	}
+	for (i = 0; i < h->ngroups; i++)
+		GROUP_AT(g, i) = h->groups[i];
+
+out:
+	ckpt_hdr_put(ctx, h);
+	return g;
+}
+
+void *restore_groupinfo(struct ckpt_ctx *ctx)
+{
+	return (void *) restore_read_groupinfo(ctx);
+}
+
+static struct user_namespace *restore_read_userns(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_user_ns *h;
+	struct user_namespace *ns;
+	struct user_struct *new_root, *creator;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_USER_NS);
+	if (IS_ERR(h))
+		return ERR_PTR(PTR_ERR(h));
+	if (h->flags & CKPT_USERNS_INIT) {
+		ckpt_hdr_put(ctx, h);
+		/* grab an extra ref bc objhash will drop an extra */
+		return get_user_ns(current_user_ns());
+	}
+	creator = ckpt_obj_fetch(ctx, h->creator_ref, CKPT_OBJ_USER);
+	ckpt_hdr_put(ctx, h);
+
+	if (IS_ERR(creator))
+		return ERR_PTR(-EINVAL);
+	ns = new_user_ns(creator, &new_root);
+
+	if (IS_ERR(ns))
+		return ns;
+
+	/* new_user_ns() doesn't bump creator's refcount */
+	get_uid(creator);
+
+	/* objhash will drop new_ns refcount, but new_root
+	 * should hold a ref */
+	get_user_ns(ns);
+
+	/*
+	 * Free the new root user.  If we actually needed it,
+	 * then it will show up later in the checkpoint image
+	 * The objhash will keep the userns pinned until then.
+	 */
+	free_uid(new_root);
+
+	return ns;
+}
+
+void *restore_userns(struct ckpt_ctx *ctx)
+{
+	return (void *) restore_read_userns(ctx);
+}
+
+static int may_setuid(struct user_namespace *ns, uid_t uid)
+{
+	/*
+	 * this next check will one day become
+	 * if capable(CAP_SETUID, ns) return 1;
+	 * followed by uid_equiv(current_userns, current_uid, ns, uid)
+	 * instead of just uids.
+	 */
+	if (capable(CAP_SETUID))
+		return 1;
+
+	/*
+	 * this may be overly strict, but since we might end up
+	 * restarting a privileged program here, we do not want
+	 * someone with only CAP_SYS_ADMIN but no CAP_SETUID to
+	 * be able to create random userids even in a userns he
+	 * created.
+	 */
+	if (current_user()->user_ns != ns)
+		return 0;
+	if (current_uid() == uid ||
+		current_euid() == uid ||
+		current_suid() == uid)
+		return 1;
+	return 0;
+}
+
+static struct user_struct *restore_read_user(struct ckpt_ctx *ctx)
+{
+	struct user_struct *u;
+	struct user_namespace *ns;
+	struct ckpt_hdr_user_struct *h;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_USER);
+	if (IS_ERR(h))
+		return ERR_PTR(PTR_ERR(h));
+
+	ns = ckpt_obj_fetch(ctx, h->userns_ref, CKPT_OBJ_USER_NS);
+	if (IS_ERR(ns)) {
+		u = ERR_PTR(PTR_ERR(ns));
+		goto out;
+	}
+
+	if (!may_setuid(ns, h->uid)) {
+		u = ERR_PTR(-EPERM);
+		goto out;
+	}
+	u = alloc_uid(ns, h->uid);
+	if (!u)
+		u = ERR_PTR(-EINVAL);
+
+out:
+	ckpt_hdr_put(ctx, h);
+	return u;
+}
+
+void *restore_user(struct ckpt_ctx *ctx)
+{
+	return (void *) restore_read_user(ctx);
+}
+
+/* move this code into kernel/cred.c and do proper perms checking of course */
+struct cred *restore_read_cred(struct ckpt_ctx *ctx)
+{
+	struct cred *cred;
+	struct ckpt_hdr_cred *h;
+	struct user_struct *user;
+	struct group_info *groupinfo;
+	int ret = -EINVAL;
+	uid_t olduid;
+	gid_t oldgid;
+	int i;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_CRED);
+	if (IS_ERR(h))
+		return ERR_PTR(PTR_ERR(h));
+	if (h->version != 1)
+		goto error;
+
+	cred = prepare_creds();
+	if (!cred)
+		goto error;
+
+
+	/* Do we care if the target user and target group were compatible?
+	 * Probably.  But then, we can't do any setuid without CAP_SETUID,
+	 * so we must have been privileged to abuse it... */
+	groupinfo = ckpt_obj_fetch(ctx, h->groupinfo_ref, CKPT_OBJ_GROUPINFO);
+	if (IS_ERR(groupinfo))
+		goto err_putcred;
+	user = ckpt_obj_fetch(ctx, h->user_ref, CKPT_OBJ_USER);
+	if (IS_ERR(user))
+		goto err_putcred;
+
+	/*
+	 * TODO: this check should  go into the common helper in
+	 * kernel/sys.c, and should account for user namespaces
+	 */
+	if (!capable(CAP_SETGID))
+		for (i = 0; i < groupinfo->ngroups; i++) {
+			if (!in_egroup_p(GROUP_AT(groupinfo, i)))
+				goto err_putcred;
+		}
+	ret = set_groups(cred, groupinfo);
+	if (ret < 0)
+		goto err_putcred;
+	free_uid(cred->user);
+	cred->user = get_uid(user);
+	ret = cred_setresuid(cred, h->uid, h->euid, h->suid);
+	if (ret < 0)
+		goto err_putcred;
+	ret = cred_setfsuid(cred, h->fsuid, &olduid);
+	if (olduid != h->fsuid && ret < 0)
+		goto err_putcred;
+	ret = cred_setresgid(cred, h->gid, h->egid, h->sgid);
+	if (ret < 0)
+		goto err_putcred;
+	ret = cred_setfsgid(cred, h->fsgid, &oldgid);
+	if (oldgid != h->fsgid && ret < 0)
+		goto err_putcred;
+	ret = checkpoint_restore_cap(h->cap_e, h->cap_i, h->cap_p, h->cap_x,
+				cred);
+	if (ret)
+		goto err_putcred;
+
+	ckpt_hdr_put(ctx, h);
+	return cred;
+
+err_putcred:
+	abort_creds(cred);
+error:
+	ckpt_hdr_put(ctx, h);
+	return ERR_PTR(ret);
+}
+
+void *restore_cred(struct ckpt_ctx *ctx)
+{
+	return (void *) restore_read_cred(ctx);
+}
+
 /* read the task_struct into the current task */
-static int restore_task_struct(struct ckpt_ctx *ctx)
+static int restore_task_struct(struct ckpt_ctx *ctx, struct cred **realcredp,
+				struct cred **ecredp)
 {
 	struct ckpt_hdr_task *h;
 	struct task_struct *t = current;
@@ -365,8 +778,21 @@ static int restore_task_struct(struct ckpt_ctx *ctx)
 
 	memset(t->comm, 0, TASK_COMM_LEN);
 	ret = _ckpt_read_string(ctx, t->comm, h->task_comm_len);
+	if (ret < 0)
+		goto out;
 
 	/* FIXME: restore remaining relevant task_struct fields */
+
+	ret = 0;
+	*realcredp = ckpt_obj_fetch(ctx, h->cred_ref, CKPT_OBJ_CRED);
+	if (IS_ERR(*realcredp)) {
+		ret = PTR_ERR(*realcredp);
+		goto out;
+	}
+	*ecredp = ckpt_obj_fetch(ctx, h->ecred_ref, CKPT_OBJ_CRED);
+	if (IS_ERR(*ecredp))
+		ret = PTR_ERR(*ecredp);
+
  out:
 	ckpt_hdr_put(ctx, h);
 	return ret;
@@ -648,12 +1074,35 @@ static int restore_task_shared(struct ckpt_ctx *ctx)
 	return ret;
 }
 
+static int restore_creds(struct ckpt_ctx *ctx, struct cred *rcred,
+			struct cred *ecred)
+{
+	int ret;
+	const struct cred *old;
+
+	/* commit_creds will take one ref for the eff creds, but
+	 * expects us to hold a ref for the obj creds, so take a
+	 * ref here */
+	get_cred(rcred);
+	ret = commit_creds(rcred);
+	if (ret)
+		return ret;
+
+	if (ecred == rcred)
+		return 0;
+
+	old =  override_creds(ecred); /* override_creds otoh takes new ref */
+	put_cred(old);
+	return 0;
+}
+
 /* read the entire state of the current task */
 int restore_task(struct ckpt_ctx *ctx)
 {
 	int ret;
+	struct cred *realcred, *ecred;
 
-	ret = restore_task_struct(ctx);
+	ret = restore_task_struct(ctx, &realcred, &ecred);
 	ckpt_debug("ret %d\n", ret);
 	if (ret < 0)
 		goto out;
@@ -671,6 +1120,10 @@ int restore_task(struct ckpt_ctx *ctx)
 		goto out;
 	ret = restore_cpu(ctx);
 	ckpt_debug("cpu: ret %d\n", ret);
+	if (ret < 0)
+		goto out;
+	ret = restore_creds(ctx, realcred, ecred);
+	ckpt_debug("creds: ret %d\n", ret);
  out:
 	return ret;
 }
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index d966f19..1b1326d 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -53,6 +53,7 @@ extern void *ckpt_obj_fetch(struct ckpt_ctx *ctx, int objref,
 			    enum obj_type type);
 extern int ckpt_obj_lookup_add(struct ckpt_ctx *ctx, void *ptr,
 			       enum obj_type type, int *first);
+extern int obj_lookup_dontadd(struct ckpt_ctx *ctx, void *ptr);
 extern int ckpt_obj_insert(struct ckpt_ctx *ctx, void *ptr, int objref,
 			   enum obj_type type);
 
@@ -90,6 +91,16 @@ static inline int restore_ipc_ns(struct ckpt_ctx *ctx)
 extern int checkpoint_ipcns(struct ckpt_ctx *ctx, struct ipc_namespace *ipc_ns);
 extern int restore_ipcns(struct ckpt_ctx *ctx);
 
+/* credentials */
+int checkpoint_groupinfo(struct ckpt_ctx *ctx, void *ptr);
+int checkpoint_userns(struct ckpt_ctx *ctx, void *ptr);
+int checkpoint_user(struct ckpt_ctx *ctx, void *ptr);
+int checkpoint_cred(struct ckpt_ctx *ctx, void *ptr);
+void *restore_groupinfo(struct ckpt_ctx *ctx);
+void *restore_userns(struct ckpt_ctx *ctx);
+void *restore_user(struct ckpt_ctx *ctx);
+void *restore_cred(struct ckpt_ctx *ctx);
+
 /* memory */
 extern void ckpt_pgarr_free(struct ckpt_ctx *ctx);
 
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 90e036d..98fc0f7 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -57,6 +57,10 @@ enum {
 	CKPT_HDR_NS,
 	CKPT_HDR_UTS_NS,
 	CKPT_HDR_IPC_NS,
+	CKPT_HDR_USER_NS,
+	CKPT_HDR_CRED,
+	CKPT_HDR_USER,
+	CKPT_HDR_GROUPINFO,
 
 	CKPT_HDR_MM = 201,
 	CKPT_HDR_VMA,
@@ -101,6 +105,10 @@ enum obj_type {
 	CKPT_OBJ_NS,
 	CKPT_OBJ_UTS_NS,
 	CKPT_OBJ_IPC_NS,
+	CKPT_OBJ_USER_NS,
+	CKPT_OBJ_CRED,
+	CKPT_OBJ_USER,
+	CKPT_OBJ_GROUPINFO,
 	CKPT_OBJ_MAX
 };
 
@@ -158,10 +166,59 @@ struct ckpt_hdr_task {
 	__u32 exit_state;
 	__u32 exit_code;
 	__u32 exit_signal;
+	__s32 cred_ref;
+	__s32 ecred_ref;
+
+#ifdef CONFIG_AUDITSYSCALL
+	/* would audit want to track the checkpointed ids,
+	   or (more likely) who actually restarted? */
+#endif
 
 	__u32 task_comm_len;
 } __attribute__((aligned(8)));
 
+struct ckpt_hdr_cred {
+	struct ckpt_hdr h;
+	__u32 version; /* especially since capability sets might grow */
+	__u32 uid, suid, euid, fsuid;
+	__u32 gid, sgid, egid, fsgid;
+	__u64 cap_i, cap_p, cap_e;
+	__u64 cap_x;  /* bounding set ('X') */
+	__s32 user_ref;
+	__s32 groupinfo_ref;
+} __attribute__((aligned(8)));
+
+struct ckpt_hdr_groupinfo {
+	struct ckpt_hdr h;
+	__u32 ngroups;
+	/*
+	 * This is followed by ngroups __u32s
+	 */
+	__u32 groups[0];
+} __attribute__((aligned(8)));
+
+/*
+ * todo - keyrings and LSM
+ * These may be better done with userspace help though
+ */
+struct ckpt_hdr_user_struct {
+	struct ckpt_hdr h;
+	__u32 uid;
+	__s32 userns_ref;
+} __attribute__((aligned(8)));
+
+/*
+ * The user-struct mostly tracks system resource usage.
+ * Most of it's contents therefore will simply be set
+ * correctly as restart opens resources
+ */
+#define CKPT_USERNS_INIT 1
+struct ckpt_hdr_user_ns {
+	struct ckpt_hdr h;
+	__u32 flags;
+	__s32 creator_ref;
+} __attribute__((aligned(8)));
+
 struct ckpt_hdr_task_ns {
 	struct ckpt_hdr h;
 	__s32 ns_objref;
diff --git a/include/linux/checkpoint_types.h b/include/linux/checkpoint_types.h
index 85ee304..2c4a9f0 100644
--- a/include/linux/checkpoint_types.h
+++ b/include/linux/checkpoint_types.h
@@ -13,6 +13,7 @@
 #define CKPT_VERSION  1
 
 #define CHECKPOINT_SUBTREE	0x4
+#define RESTORE_CREATE_USERNS	0x8
 
 
 #ifdef __KERNEL__
-- 
1.6.1
