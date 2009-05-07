From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/1] cr: restore credentials: first real stab
Date: Thu, 7 May 2009 16:45:29 -0500
Message-ID: <20090507214529.GA25100@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
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

Several functions like kernel/sys.c:setresuid() had their core
function moved into a common fn, like cred_setresuid(), which
operates on a passed-in credential.  set_user() now allocates
the uid in the new->user_user_ns instead of current_user_ns().
For legacy callers, new was copied from current->cred using
prepare_cred(), so this should be fine (right?).

With these patches, users root and hallyn can each checkpoint
and restart their own programs, and root can restart a checkpoint
created by hallyn, resulting in a restart program owned by and
constrained as user hallyn.  (When root creates a checkpoint
of hallyn's program, restarting from that checkpoint appears
to succeed (return 0), but the program immediately terminates - don't
know why yet).

NOTE - this patch is for task credentials only.  It doesn't
address credentials on open file descriptors.

Plenty of bugs to be found, no doubt.

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/objhash.c             |  119 ++++++++++-
 checkpoint/process.c             |  455 +++++++++++++++++++++++++++++++++++++-
 include/linux/capability.h       |    5 +
 include/linux/checkpoint.h       |   11 +
 include/linux/checkpoint_hdr.h   |   56 +++++
 include/linux/checkpoint_types.h |    1 +
 include/linux/cred.h             |    9 +
 include/linux/user_namespace.h   |    8 +
 kernel/capability.c              |   94 +++++++-
 kernel/cred.c                    |  143 ++++++++++++
 kernel/sys.c                     |  163 ++------------
 kernel/user_namespace.c          |   53 +++--
 12 files changed, 946 insertions(+), 171 deletions(-)

diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
index 87bc5e8..9206957 100644
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
index b731891..f37fb8b 100644
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
@@ -27,16 +28,209 @@
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
@@ -320,8 +514,229 @@ int checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
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
+		return current_user_ns();
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
+	/* we need a way to keep track of the new_root just
+	 * until we alloc the  uid inthe userns which we
+	 * actually want.  Then we can do:
+	 *   if (uid == 0)
+	 *      new_user = new_root;
+	 *   else
+	 *      new_user = alloc_uid(ns, uid);
+	 *      free_uid(new_root);
+	 *      cred->user = new_user;
+	 * This is because new_root is right now the only
+	 * thing pinning the user_ns.
+	 * BUT I don't think I can just add it to the
+	 * objhash, bc then we use up an objref which we'll
+	 * need for the next real objhash object, right?
+	 * I suppose I could just add them to the top of
+	 * the objref space :)  (MAX_INT-1)
+	 *
+	 * For now, this code is just plain wrong bc it will
+	 * leak the user_ns and its root_user when the task
+	 * exits.  But, a leak is better than an OOPS...
+	 */
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
@@ -337,8 +752,21 @@ static int restore_task_struct(struct ckpt_ctx *ctx)
 
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
@@ -594,12 +1022,31 @@ static int restore_task_objs(struct ckpt_ctx *ctx)
 	return ret;
 }
 
+static int restore_creds(struct ckpt_ctx *ctx, struct cred *rcred,
+			struct cred *ecred)
+{
+	int ret;
+	const struct cred *old;
+
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
@@ -617,6 +1064,10 @@ int restore_task(struct ckpt_ctx *ctx)
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
diff --git a/include/linux/capability.h b/include/linux/capability.h
index c302110..572b5a0 100644
--- a/include/linux/capability.h
+++ b/include/linux/capability.h
@@ -536,6 +536,11 @@ extern const kernel_cap_t __cap_empty_set;
 extern const kernel_cap_t __cap_full_set;
 extern const kernel_cap_t __cap_init_eff_set;
 
+extern void checkpoint_save_cap(__u64 *dest, kernel_cap_t src);
+struct cred;
+extern int checkpoint_restore_cap(__u64 e, __u64 i, __u64 p, __u64 x,
+				struct cred *cred);
+
 /**
  * has_capability - Determine if a task has a superior capability available
  * @t: The task in question
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 2a09244..f41e581 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -53,6 +53,7 @@ extern void *ckpt_obj_fetch(struct ckpt_ctx *ctx, int objref,
 			    enum obj_type type);
 extern int ckpt_obj_lookup_add(struct ckpt_ctx *ctx, void *ptr,
 			       enum obj_type type, int *first);
+extern int obj_lookup_dontadd(struct ckpt_ctx *ctx, void *ptr);
 extern void ckpt_obj_users_inc(struct ckpt_ctx *ctx, void *ptr, int increment);
 extern int ckpt_obj_insert(struct ckpt_ctx *ctx, void *ptr, int objref,
 			   enum obj_type type);
@@ -91,6 +92,16 @@ static inline int restore_ipc_ns(struct ckpt_ctx *ctx)
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
index 058412c..4d6c163 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -56,6 +56,10 @@ enum {
 	CKPT_HDR_NS,
 	CKPT_HDR_UTS_NS,
 	CKPT_HDR_IPC_NS,
+	CKPT_HDR_USER_NS,
+	CKPT_HDR_CRED,
+	CKPT_HDR_USER,
+	CKPT_HDR_GROUPINFO,
 
 	CKPT_HDR_MM = 201,
 	CKPT_HDR_VMA,
@@ -100,6 +104,10 @@ enum obj_type {
 	CKPT_OBJ_NS,
 	CKPT_OBJ_UTS_NS,
 	CKPT_OBJ_IPC_NS,
+	CKPT_OBJ_USER_NS,
+	CKPT_OBJ_CRED,
+	CKPT_OBJ_USER,
+	CKPT_OBJ_GROUPINFO,
 	CKPT_OBJ_MAX
 };
 
@@ -157,10 +165,58 @@ struct ckpt_hdr_task {
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
 struct ckpt_hdr_task_objs {
 	struct ckpt_hdr h;
 	__s32 mm_objref;
diff --git a/include/linux/checkpoint_types.h b/include/linux/checkpoint_types.h
index 85ee304..2c4a9f0 100644
--- a/include/linux/checkpoint_types.h
+++ b/include/linux/checkpoint_types.h
@@ -13,6 +13,7 @@
 #define CKPT_VERSION  1
 
 #define CHECKPOINT_SUBTREE	0x4
+#define RESTORE_CREATE_USERNS	0x8
 
 
 #ifdef __KERNEL__
diff --git a/include/linux/cred.h b/include/linux/cred.h
index 3282ee4..4d83bdb 100644
--- a/include/linux/cred.h
+++ b/include/linux/cred.h
@@ -20,6 +20,9 @@ struct user_struct;
 struct cred;
 struct inode;
 
+/* defined in sys.c, used in cred_setresuid */
+extern int set_user(struct cred *new);
+
 /*
  * COW Supplementary groups list
  */
@@ -343,4 +346,10 @@ do {						\
 	*(_fsgid) = __cred->fsgid;		\
 } while(0)
 
+int cred_setresuid(struct cred *new, uid_t ruid, uid_t euid, uid_t suid);
+int cred_setresgid(struct cred *new, gid_t rgid, gid_t egid, gid_t sgid);
+int cred_setfsuid(struct cred *new, uid_t uid, uid_t *old_fsuid);
+int cred_setfsgid(struct cred *new, gid_t gid, gid_t *old_fsgid);
+int cred_setuid(struct cred *new, uid_t uid);
+
 #endif /* _LINUX_CRED_H */
diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.h
index cc4f453..a2b82d5 100644
--- a/include/linux/user_namespace.h
+++ b/include/linux/user_namespace.h
@@ -20,6 +20,8 @@ extern struct user_namespace init_user_ns;
 
 #ifdef CONFIG_USER_NS
 
+struct user_namespace *new_user_ns(struct user_struct *creator,
+				   struct user_struct **newroot);
 static inline struct user_namespace *get_user_ns(struct user_namespace *ns)
 {
 	if (ns)
@@ -38,6 +40,12 @@ static inline void put_user_ns(struct user_namespace *ns)
 
 #else
 
+static inline struct user_namespace *new_user_ns(struct user_struct *creator,
+				   struct user_struct **newroot)
+{
+	return -EINVAL;
+}
+
 static inline struct user_namespace *get_user_ns(struct user_namespace *ns)
 {
 	return &init_user_ns;
diff --git a/kernel/capability.c b/kernel/capability.c
index 4e17041..d2c9bb3 100644
--- a/kernel/capability.c
+++ b/kernel/capability.c
@@ -217,6 +217,45 @@ SYSCALL_DEFINE2(capget, cap_user_header_t, header, cap_user_data_t, dataptr)
 	return ret;
 }
 
+static int do_capset_tocred(kernel_cap_t *effective, kernel_cap_t *inheritable,
+			kernel_cap_t *permitted, struct cred *new)
+{
+	int ret;
+
+	ret = security_capset(new, current_cred(),
+			      effective, inheritable, permitted);
+	if (ret < 0)
+		return ret;
+
+	/*
+	 * for checkpoint-restart, do we want to wait until end of restart?
+	 * not sure we care */
+	audit_log_capset(current->pid, new, current_cred());
+
+	return 0;
+}
+
+static int do_capset(kernel_cap_t *effective, kernel_cap_t *inheritable,
+			kernel_cap_t *permitted)
+{
+	struct cred *new;
+	int ret;
+
+	new = prepare_creds();
+	if (!new)
+		return -ENOMEM;
+
+	ret = do_capset_tocred(effective, inheritable, permitted, new);
+	if (ret < 0)
+		goto error;
+
+	return commit_creds(new);
+
+error:
+	abort_creds(new);
+	return ret;
+}
+
 /**
  * sys_capset - set capabilities for a process or (*) a group of processes
  * @header: pointer to struct that contains capability version and
@@ -240,7 +279,6 @@ SYSCALL_DEFINE2(capset, cap_user_header_t, header, const cap_user_data_t, data)
 	struct __user_cap_data_struct kdata[_KERNEL_CAPABILITY_U32S];
 	unsigned i, tocopy;
 	kernel_cap_t inheritable, permitted, effective;
-	struct cred *new;
 	int ret;
 	pid_t pid;
 
@@ -271,22 +309,52 @@ SYSCALL_DEFINE2(capset, cap_user_header_t, header, const cap_user_data_t, data)
 		i++;
 	}
 
-	new = prepare_creds();
-	if (!new)
-		return -ENOMEM;
+	return do_capset(&effective, &inheritable, &permitted);
 
-	ret = security_capset(new, current_cred(),
-			      &effective, &inheritable, &permitted);
-	if (ret < 0)
-		goto error;
+}
 
-	audit_log_capset(pid, new, current_cred());
 
-	return commit_creds(new);
+void checkpoint_save_cap(__u64 *dest, kernel_cap_t src)
+{
+	*dest = src.cap[0] | (src.cap[1] << sizeof(__u32));
+}
 
-error:
-	abort_creds(new);
-	return ret;
+static void do_capbset_drop(struct cred *cred, int cap)
+{
+	cap_lower(cred->cap_bset, cap);
+}
+
+int checkpoint_restore_cap(__u64 newe, __u64 newi, __u64 newp, __u64 newx,
+			struct cred *cred)
+{
+	kernel_cap_t effective, inheritable, permitted, bset;
+	int may_dropbcap = capable(CAP_SETPCAP);
+	int ret, i;
+
+	effective.cap[0] = newe;
+	effective.cap[1] = (newe >> sizeof(__u32));
+	inheritable.cap[0] = newi;
+	inheritable.cap[1] = (newi >> sizeof(__u32));
+	permitted.cap[0] = newp;
+	permitted.cap[1] = (newp >> sizeof(__u32));
+	bset.cap[0] = newx;
+	bset.cap[1] = (newx >> sizeof(__u32));
+
+	ret = do_capset_tocred(&effective, &inheritable, &permitted, cred);
+	if (ret < 0)
+		return ret;
+
+	for (i = 0; i < CAP_LAST_CAP; i++) {
+		if (cap_raised(bset, i))
+			continue;
+		if (!cap_raised(current_cred()->cap_bset, i))
+			continue;
+		if (!may_dropbcap)
+			return -EPERM;
+		do_capbset_drop(cred, i);
+	}
+
+	return 0;
 }
 
 /**
diff --git a/kernel/cred.c b/kernel/cred.c
index 3a03918..4692028 100644
--- a/kernel/cred.c
+++ b/kernel/cred.c
@@ -589,3 +589,146 @@ int set_create_files_as(struct cred *new, struct inode *inode)
 	return security_kernel_create_files_as(new, inode);
 }
 EXPORT_SYMBOL(set_create_files_as);
+
+int cred_setresuid(struct cred *new, uid_t ruid, uid_t euid, uid_t suid)
+{
+	int retval;
+	const struct cred *old;
+
+	retval = security_task_setuid(ruid, euid, suid, LSM_SETID_RES);
+	if (retval)
+		return retval;
+	old = current_cred();
+
+	if (!capable(CAP_SETUID)) {
+		if (ruid != (uid_t) -1 && ruid != old->uid &&
+		    ruid != old->euid  && ruid != old->suid)
+			return -EPERM;
+		if (euid != (uid_t) -1 && euid != old->uid &&
+		    euid != old->euid  && euid != old->suid)
+			return -EPERM;
+		if (suid != (uid_t) -1 && suid != old->uid &&
+		    suid != old->euid  && suid != old->suid)
+			return -EPERM;
+	}
+
+	if (ruid != (uid_t) -1) {
+		new->uid = ruid;
+		if (ruid != old->uid) {
+			retval = set_user(new);
+			if (retval < 0)
+				return retval;
+		}
+	}
+	if (euid != (uid_t) -1)
+		new->euid = euid;
+	if (suid != (uid_t) -1)
+		new->suid = suid;
+	new->fsuid = new->euid;
+
+	return security_task_fix_setuid(new, old, LSM_SETID_RES);
+}
+
+int cred_setresgid(struct cred *new, gid_t rgid, gid_t egid,
+			gid_t sgid)
+{
+	const struct cred *old = current_cred();
+	int retval;
+
+	retval = security_task_setgid(rgid, egid, sgid, LSM_SETID_RES);
+	if (retval)
+		return retval;
+
+	if (!capable(CAP_SETGID)) {
+		if (rgid != (gid_t) -1 && rgid != old->gid &&
+		    rgid != old->egid  && rgid != old->sgid)
+			return -EPERM;
+		if (egid != (gid_t) -1 && egid != old->gid &&
+		    egid != old->egid  && egid != old->sgid)
+			return -EPERM;
+		if (sgid != (gid_t) -1 && sgid != old->gid &&
+		    sgid != old->egid  && sgid != old->sgid)
+			return -EPERM;
+	}
+
+	if (rgid != (gid_t) -1)
+		new->gid = rgid;
+	if (egid != (gid_t) -1)
+		new->egid = egid;
+	if (sgid != (gid_t) -1)
+		new->sgid = sgid;
+	new->fsgid = new->egid;
+	return 0;
+}
+
+int cred_setfsuid(struct cred *new, uid_t uid, uid_t *old_fsuid)
+{
+	const struct cred *old;
+
+	old = current_cred();
+	*old_fsuid = old->fsuid;
+
+	if (security_task_setuid(uid, (uid_t)-1, (uid_t)-1, LSM_SETID_FS) < 0)
+		return -EPERM;
+
+	if (uid == old->uid  || uid == old->euid  ||
+	    uid == old->suid || uid == old->fsuid ||
+	    capable(CAP_SETUID)) {
+		if (uid != *old_fsuid) {
+			new->fsuid = uid;
+			if (security_task_fix_setuid(new, old, LSM_SETID_FS) == 0)
+				return 0;
+		}
+	}
+	return -EPERM;
+}
+
+int cred_setfsgid(struct cred *new, gid_t gid, gid_t *old_fsgid)
+{
+	const struct cred *old;
+
+	old = current_cred();
+	*old_fsgid = old->fsgid;
+
+	if (security_task_setgid(gid, (gid_t)-1, (gid_t)-1, LSM_SETID_FS))
+		return -EPERM;
+
+	if (gid == old->gid  || gid == old->egid  ||
+	    gid == old->sgid || gid == old->fsgid ||
+	    capable(CAP_SETGID)) {
+		if (gid != *old_fsgid) {
+			new->fsgid = gid;
+			return 0;
+		}
+	}
+	return -EPERM;
+}
+
+int cred_setuid(struct cred *new, uid_t uid)
+{
+	const struct cred *old = current_cred();
+	int retval;
+
+	retval = security_task_setuid(uid, (uid_t)-1, (uid_t)-1, LSM_SETID_ID);
+	if (retval)
+		return retval;
+
+	retval = -EPERM;
+	if (capable(CAP_SETUID)) {
+		new->suid = new->uid = uid;
+		if (uid != old->uid) {
+			retval = set_user(new);
+			if (retval < 0)
+				return retval;
+		}
+	} else if (uid != old->uid && uid != new->suid) {
+		return retval;
+	}
+
+	new->fsuid = new->euid = uid;
+
+	retval = security_task_fix_setuid(new, old, LSM_SETID_ID);
+	if (retval < 0)
+		return retval;
+	return 0;
+}
diff --git a/kernel/sys.c b/kernel/sys.c
index e7998cf..408729c 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -558,11 +558,12 @@ error:
 /*
  * change the user struct in a credentials set to match the new UID
  */
-static int set_user(struct cred *new)
+int set_user(struct cred *new)
 {
 	struct user_struct *new_user;
 
-	new_user = alloc_uid(current_user_ns(), new->uid);
+	/* is this ok? */
+	new_user = alloc_uid(new->user->user_ns, new->uid);
 	if (!new_user)
 		return -EAGAIN;
 
@@ -665,52 +666,27 @@ error:
  */
 SYSCALL_DEFINE1(setuid, uid_t, uid)
 {
-	const struct cred *old;
 	struct cred *new;
 	int retval;
 
 	new = prepare_creds();
 	if (!new)
 		return -ENOMEM;
-	old = current_cred();
 
-	retval = security_task_setuid(uid, (uid_t)-1, (uid_t)-1, LSM_SETID_ID);
-	if (retval)
-		goto error;
+	retval = cred_setuid(new, uid);
+	if (retval == 0)
+		return commit_creds(new);
 
-	retval = -EPERM;
-	if (capable(CAP_SETUID)) {
-		new->suid = new->uid = uid;
-		if (uid != old->uid) {
-			retval = set_user(new);
-			if (retval < 0)
-				goto error;
-		}
-	} else if (uid != old->uid && uid != new->suid) {
-		goto error;
-	}
-
-	new->fsuid = new->euid = uid;
-
-	retval = security_task_fix_setuid(new, old, LSM_SETID_ID);
-	if (retval < 0)
-		goto error;
-
-	return commit_creds(new);
-
-error:
 	abort_creds(new);
 	return retval;
 }
 
-
 /*
  * This function implements a generic ability to update ruid, euid,
  * and suid.  This allows you to implement the 4.4 compatible seteuid().
  */
 SYSCALL_DEFINE3(setresuid, uid_t, ruid, uid_t, euid, uid_t, suid)
 {
-	const struct cred *old;
 	struct cred *new;
 	int retval;
 
@@ -718,45 +694,10 @@ SYSCALL_DEFINE3(setresuid, uid_t, ruid, uid_t, euid, uid_t, suid)
 	if (!new)
 		return -ENOMEM;
 
-	retval = security_task_setuid(ruid, euid, suid, LSM_SETID_RES);
-	if (retval)
-		goto error;
-	old = current_cred();
+	retval = cred_setresuid(new, ruid, euid, suid);
+	if (retval == 0)
+		return commit_creds(new);
 
-	retval = -EPERM;
-	if (!capable(CAP_SETUID)) {
-		if (ruid != (uid_t) -1 && ruid != old->uid &&
-		    ruid != old->euid  && ruid != old->suid)
-			goto error;
-		if (euid != (uid_t) -1 && euid != old->uid &&
-		    euid != old->euid  && euid != old->suid)
-			goto error;
-		if (suid != (uid_t) -1 && suid != old->uid &&
-		    suid != old->euid  && suid != old->suid)
-			goto error;
-	}
-
-	if (ruid != (uid_t) -1) {
-		new->uid = ruid;
-		if (ruid != old->uid) {
-			retval = set_user(new);
-			if (retval < 0)
-				goto error;
-		}
-	}
-	if (euid != (uid_t) -1)
-		new->euid = euid;
-	if (suid != (uid_t) -1)
-		new->suid = suid;
-	new->fsuid = new->euid;
-
-	retval = security_task_fix_setuid(new, old, LSM_SETID_RES);
-	if (retval < 0)
-		goto error;
-
-	return commit_creds(new);
-
-error:
 	abort_creds(new);
 	return retval;
 }
@@ -778,43 +719,17 @@ SYSCALL_DEFINE3(getresuid, uid_t __user *, ruid, uid_t __user *, euid, uid_t __u
  */
 SYSCALL_DEFINE3(setresgid, gid_t, rgid, gid_t, egid, gid_t, sgid)
 {
-	const struct cred *old;
 	struct cred *new;
 	int retval;
 
 	new = prepare_creds();
 	if (!new)
 		return -ENOMEM;
-	old = current_cred();
-
-	retval = security_task_setgid(rgid, egid, sgid, LSM_SETID_RES);
-	if (retval)
-		goto error;
 
-	retval = -EPERM;
-	if (!capable(CAP_SETGID)) {
-		if (rgid != (gid_t) -1 && rgid != old->gid &&
-		    rgid != old->egid  && rgid != old->sgid)
-			goto error;
-		if (egid != (gid_t) -1 && egid != old->gid &&
-		    egid != old->egid  && egid != old->sgid)
-			goto error;
-		if (sgid != (gid_t) -1 && sgid != old->gid &&
-		    sgid != old->egid  && sgid != old->sgid)
-			goto error;
-	}
-
-	if (rgid != (gid_t) -1)
-		new->gid = rgid;
-	if (egid != (gid_t) -1)
-		new->egid = egid;
-	if (sgid != (gid_t) -1)
-		new->sgid = sgid;
-	new->fsgid = new->egid;
+	retval = cred_setresgid(new, rgid, egid, sgid);
+	if (retval == 0)
+		return commit_creds(new);
 
-	return commit_creds(new);
-
-error:
 	abort_creds(new);
 	return retval;
 }
@@ -831,7 +746,6 @@ SYSCALL_DEFINE3(getresgid, gid_t __user *, rgid, gid_t __user *, egid, gid_t __u
 	return retval;
 }
 
-
 /*
  * "setfsuid()" sets the fsuid - the uid used for filesystem checks. This
  * is used for "access()" and for the NFS daemon (letting nfsd stay at
@@ -840,35 +754,20 @@ SYSCALL_DEFINE3(getresgid, gid_t __user *, rgid, gid_t __user *, egid, gid_t __u
  */
 SYSCALL_DEFINE1(setfsuid, uid_t, uid)
 {
-	const struct cred *old;
 	struct cred *new;
 	uid_t old_fsuid;
+	int retval;
 
 	new = prepare_creds();
 	if (!new)
 		return current_fsuid();
-	old = current_cred();
-	old_fsuid = old->fsuid;
 
-	if (security_task_setuid(uid, (uid_t)-1, (uid_t)-1, LSM_SETID_FS) < 0)
-		goto error;
-
-	if (uid == old->uid  || uid == old->euid  ||
-	    uid == old->suid || uid == old->fsuid ||
-	    capable(CAP_SETUID)) {
-		if (uid != old_fsuid) {
-			new->fsuid = uid;
-			if (security_task_fix_setuid(new, old, LSM_SETID_FS) == 0)
-				goto change_okay;
-		}
-	}
-
-error:
-	abort_creds(new);
-	return old_fsuid;
+	retval = cred_setfsuid(new, uid, &old_fsuid);
+	if (retval == 0)
+		commit_creds(new);
+	else
+		abort_creds(new);
 
-change_okay:
-	commit_creds(new);
 	return old_fsuid;
 }
 
@@ -877,34 +776,20 @@ change_okay:
  */
 SYSCALL_DEFINE1(setfsgid, gid_t, gid)
 {
-	const struct cred *old;
 	struct cred *new;
 	gid_t old_fsgid;
+	int retval;
 
 	new = prepare_creds();
 	if (!new)
 		return current_fsgid();
-	old = current_cred();
-	old_fsgid = old->fsgid;
 
-	if (security_task_setgid(gid, (gid_t)-1, (gid_t)-1, LSM_SETID_FS))
-		goto error;
-
-	if (gid == old->gid  || gid == old->egid  ||
-	    gid == old->sgid || gid == old->fsgid ||
-	    capable(CAP_SETGID)) {
-		if (gid != old_fsgid) {
-			new->fsgid = gid;
-			goto change_okay;
-		}
-	}
-
-error:
-	abort_creds(new);
-	return old_fsgid;
+	retval = cred_setfsgid(new, gid, &old_fsgid);
+	if (retval == 0)
+		commit_creds(new);
+	else
+		abort_creds(new);
 
-change_okay:
-	commit_creds(new);
 	return old_fsgid;
 }
 
diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
index 076c7c8..e624b0f 100644
--- a/kernel/user_namespace.c
+++ b/kernel/user_namespace.c
@@ -11,15 +11,8 @@
 #include <linux/user_namespace.h>
 #include <linux/cred.h>
 
-/*
- * Create a new user namespace, deriving the creator from the user in the
- * passed credentials, and replacing that user with the new root user for the
- * new namespace.
- *
- * This is called by copy_creds(), which will finish setting the target task's
- * credentials.
- */
-int create_user_ns(struct cred *new)
+static struct user_namespace *_new_user_ns(struct user_struct *creator,
+				   struct user_struct **newroot)
 {
 	struct user_namespace *ns;
 	struct user_struct *root_user;
@@ -27,7 +20,7 @@ int create_user_ns(struct cred *new)
 
 	ns = kmalloc(sizeof(struct user_namespace), GFP_KERNEL);
 	if (!ns)
-		return -ENOMEM;
+		return ERR_PTR(-ENOMEM);
 
 	kref_init(&ns->kref);
 
@@ -38,12 +31,43 @@ int create_user_ns(struct cred *new)
 	root_user = alloc_uid(ns, 0);
 	if (!root_user) {
 		kfree(ns);
-		return -ENOMEM;
+		return ERR_PTR(-ENOMEM);
 	}
 
 	/* set the new root user in the credentials under preparation */
-	ns->creator = new->user;
-	new->user = root_user;
+	ns->creator = creator;
+
+	/* alloc_uid() incremented the userns refcount.  Just set it to 1 */
+	kref_set(&ns->kref, 1);
+
+	*newroot = root_user;
+	return ns;
+}
+
+struct user_namespace *new_user_ns(struct user_struct *creator,
+				   struct user_struct **newroot)
+{
+	if (!capable(CAP_SYS_ADMIN))
+		return ERR_PTR(-EPERM);
+	return _new_user_ns(creator, newroot);
+}
+
+/*
+ * Create a new user namespace, deriving the creator from the user in the
+ * passed credentials, and replacing that user with the new root user for the
+ * new namespace.
+ *
+ * This is called by copy_creds(), which will finish setting the target task's
+ * credentials.
+ */
+int create_user_ns(struct cred *new)
+{
+	struct user_namespace *ns;
+
+	ns = new_user_ns(new->user, &new->user);
+	if (IS_ERR(ns))
+		return PTR_ERR(ns);
+
 	new->uid = new->euid = new->suid = new->fsuid = 0;
 	new->gid = new->egid = new->sgid = new->fsgid = 0;
 	put_group_info(new->group_info);
@@ -54,9 +78,6 @@ int create_user_ns(struct cred *new)
 #endif
 	/* tgcred will be cleared in our caller bc CLONE_THREAD won't be set */
 
-	/* alloc_uid() incremented the userns refcount.  Just set it to 1 */
-	kref_set(&ns->kref, 1);
-
 	return 0;
 }
 
-- 
1.6.1
