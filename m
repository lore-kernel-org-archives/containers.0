From: "\"Eric W. Beiderman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 17/43] userns: Rework the user_namespace adding uid/gid
	mapping support
Date: Sat,  7 Apr 2012 22:15:13 -0700
Message-ID: <1333862139-31737-17-git-send-email-ebiederm@xmission.com>
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

- Convert the old uid mapping functions into compatibility wrappers
- Add a uid/gid mapping layer from user space uid and gids to kernel
  internal uids and gids that is extent based for simplicty and speed.
  * Working with number space after mapping uids/gids into their kernel
    internal version adds only mapping complexity over what we have today,
    leaving the kernel code easy to understand and test.
- Add proc files /proc/self/uid_map /proc/self/gid_map
  These files display the mapping and allow a mapping to be added
  if a mapping does not exist.
- Allow entering the user namespace without a uid or gid mapping.
  Since we are starting with an existing user our uids and gids
  still have global mappings so are still valid and useful they just don't
  have local mappings.  The requirement for things to work are global uid
  and gid so it is odd but perfectly fine not to have a local uid
  and gid mapping.
  Not requiring global uid and gid mappings greatly simplifies
  the logic of setting up the uid and gid mappings by allowing
  the mappings to be set after the namespace is created which makes the
  slight weirdness worth it.
- Make the mappings in the initial user namespace to the global
  uid/gid space explicit.  Today it is an identity mapping
  but in the future we may want to twist this for debugging, similar
  to what we do with jiffies.
- Document the memory ordering requirements of setting the uid and
  gid mappings.  We only allow the mappings to be set once
  and there are no pointers involved so the requirments are
  trivial but a little atypical.

Performance:

In this scheme for the permission checks the performance is expected to
stay the same as the actuall machine instructions should remain the same.

The worst case I could think of is ls -l on a large directory where
all of the stat results need to be translated with from kuids and
kgids to uids and gids.  So I benchmarked that case on my laptop
with a dual core hyperthread Intel i5-2520M cpu with 3M of cpu cache.

My benchmark consisted of going to single user mode where nothing else
was running. On an ext4 filesystem opening 1,000,000 files and looping
through all of the files 1000 times and calling fstat on the
individuals files.  This was to ensure I was benchmarking stat times
where the inodes were in the kernels cache, but the inode values were
not in the processors cache.  My results:

v3.4-rc1:         ~= 156ns (unmodified v3.4-rc1 with user namespace support disabled)
v3.4-rc1-userns-: ~= 155ns (v3.4-rc1 with my user namespace patches and user namespace support disabled)
v3.4-rc1-userns+: ~= 164ns (v3.4-rc1 with my user namespace patches and user namespace support enabled)

All of the configurations ran in roughly 120ns when I performed tests
that ran in the cpu cache.

So in summary the performance impact is:
1ns improvement in the worst case with user namespace support compiled out.
8ns aka 5% slowdown in the worst case with user namespace support compiled in.

Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/proc/base.c                 |   77 ++++++
 include/linux/uidgid.h         |   24 ++
 include/linux/user_namespace.h |   30 ++-
 kernel/user.c                  |   16 ++
 kernel/user_namespace.c        |  545 +++++++++++++++++++++++++++++++++++++---
 5 files changed, 644 insertions(+), 48 deletions(-)

diff --git a/fs/proc/base.c b/fs/proc/base.c
index 1c8b280..2ee514c 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -81,6 +81,7 @@
 #include <linux/oom.h>
 #include <linux/elf.h>
 #include <linux/pid_namespace.h>
+#include <linux/user_namespace.h>
 #include <linux/fs_struct.h>
 #include <linux/slab.h>
 #include <linux/flex_array.h>
@@ -2943,6 +2944,74 @@ static int proc_tgid_io_accounting(struct task_struct *task, char *buffer)
 }
 #endif /* CONFIG_TASK_IO_ACCOUNTING */
 
+#ifdef CONFIG_USER_NS
+static int proc_id_map_open(struct inode *inode, struct file *file,
+	struct seq_operations *seq_ops)
+{
+	struct user_namespace *ns = NULL;
+	struct task_struct *task;
+	struct seq_file *seq;
+	int ret = -EINVAL;
+
+	task = get_proc_task(inode);
+	if (task) {
+		rcu_read_lock();
+		ns = get_user_ns(task_cred_xxx(task, user_ns));
+		rcu_read_unlock();
+		put_task_struct(task);
+	}
+	if (!ns)
+		goto err;
+
+	ret = seq_open(file, seq_ops);
+	if (ret)
+		goto err_put_ns;
+
+	seq = file->private_data;
+	seq->private = ns;
+
+	return 0;
+err_put_ns:
+	put_user_ns(ns);
+err:
+	return ret;
+}
+
+static int proc_id_map_release(struct inode *inode, struct file *file)
+{
+	struct seq_file *seq = file->private_data;
+	struct user_namespace *ns = seq->private;
+	put_user_ns(ns);
+	return seq_release(inode, file);
+}
+
+static int proc_uid_map_open(struct inode *inode, struct file *file)
+{
+	return proc_id_map_open(inode, file, &proc_uid_seq_operations);
+}
+
+static int proc_gid_map_open(struct inode *inode, struct file *file)
+{
+	return proc_id_map_open(inode, file, &proc_gid_seq_operations);
+}
+
+static const struct file_operations proc_uid_map_operations = {
+	.open		= proc_uid_map_open,
+	.write		= proc_uid_map_write,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= proc_id_map_release,
+};
+
+static const struct file_operations proc_gid_map_operations = {
+	.open		= proc_gid_map_open,
+	.write		= proc_gid_map_write,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= proc_id_map_release,
+};
+#endif /* CONFIG_USER_NS */
+
 static int proc_pid_personality(struct seq_file *m, struct pid_namespace *ns,
 				struct pid *pid, struct task_struct *task)
 {
@@ -3045,6 +3114,10 @@ static const struct pid_entry tgid_base_stuff[] = {
 #ifdef CONFIG_HARDWALL
 	INF("hardwall",   S_IRUGO, proc_pid_hardwall),
 #endif
+#ifdef CONFIG_USER_NS
+	REG("uid_map",    S_IRUGO|S_IWUSR, proc_uid_map_operations),
+	REG("gid_map",    S_IRUGO|S_IWUSR, proc_gid_map_operations),
+#endif
 };
 
 static int proc_tgid_base_readdir(struct file * filp,
@@ -3400,6 +3473,10 @@ static const struct pid_entry tid_base_stuff[] = {
 #ifdef CONFIG_HARDWALL
 	INF("hardwall",   S_IRUGO, proc_pid_hardwall),
 #endif
+#ifdef CONFIG_USER_NS
+	REG("uid_map",    S_IRUGO|S_IWUSR, proc_uid_map_operations),
+	REG("gid_map",    S_IRUGO|S_IWUSR, proc_gid_map_operations),
+#endif
 };
 
 static int proc_tid_base_readdir(struct file * filp,
diff --git a/include/linux/uidgid.h b/include/linux/uidgid.h
index 5398568..8e522cbc 100644
--- a/include/linux/uidgid.h
+++ b/include/linux/uidgid.h
@@ -127,6 +127,28 @@ static inline bool gid_valid(kgid_t gid)
 	return !gid_eq(gid, INVALID_GID);
 }
 
+#ifdef CONFIG_USER_NS
+
+extern kuid_t make_kuid(struct user_namespace *from, uid_t uid);
+extern kgid_t make_kgid(struct user_namespace *from, gid_t gid);
+
+extern uid_t from_kuid(struct user_namespace *to, kuid_t uid);
+extern gid_t from_kgid(struct user_namespace *to, kgid_t gid);
+extern uid_t from_kuid_munged(struct user_namespace *to, kuid_t uid);
+extern gid_t from_kgid_munged(struct user_namespace *to, kgid_t gid);
+
+static inline bool kuid_has_mapping(struct user_namespace *ns, kuid_t uid)
+{
+	return from_kuid(ns, uid) != (uid_t) -1;
+}
+
+static inline bool kgid_has_mapping(struct user_namespace *ns, kgid_t gid)
+{
+	return from_kgid(ns, gid) != (gid_t) -1;
+}
+
+#else
+
 static inline kuid_t make_kuid(struct user_namespace *from, uid_t uid)
 {
 	return KUIDT_INIT(uid);
@@ -173,4 +195,6 @@ static inline bool kgid_has_mapping(struct user_namespace *ns, kgid_t gid)
 	return true;
 }
 
+#endif /* CONFIG_USER_NS */
+
 #endif /* _LINUX_UIDGID_H */
diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.h
index 8a391bd..4c9846d 100644
--- a/include/linux/user_namespace.h
+++ b/include/linux/user_namespace.h
@@ -6,7 +6,20 @@
 #include <linux/sched.h>
 #include <linux/err.h>
 
+#define UID_GID_MAP_MAX_EXTENTS 5
+
+struct uid_gid_map {	/* 64 bytes -- 1 cache line */
+	u32 nr_extents;
+	struct uid_gid_extent {
+		u32 first;
+		u32 lower_first;
+		u32 count;
+	} extent[UID_GID_MAP_MAX_EXTENTS];
+};
+
 struct user_namespace {
+	struct uid_gid_map	uid_map;
+	struct uid_gid_map	gid_map;
 	struct kref		kref;
 	struct user_namespace	*parent;
 	kuid_t			owner;
@@ -33,9 +46,11 @@ static inline void put_user_ns(struct user_namespace *ns)
 		kref_put(&ns->kref, free_user_ns);
 }
 
-uid_t user_ns_map_uid(struct user_namespace *to, const struct cred *cred, uid_t uid);
-gid_t user_ns_map_gid(struct user_namespace *to, const struct cred *cred, gid_t gid);
-
+struct seq_operations;
+extern struct seq_operations proc_uid_seq_operations;
+extern struct seq_operations proc_gid_seq_operations;
+extern ssize_t proc_uid_map_write(struct file *, const char __user *, size_t, loff_t *);
+extern ssize_t proc_gid_map_write(struct file *, const char __user *, size_t, loff_t *);
 #else
 
 static inline struct user_namespace *get_user_ns(struct user_namespace *ns)
@@ -52,17 +67,18 @@ static inline void put_user_ns(struct user_namespace *ns)
 {
 }
 
+#endif
+
 static inline uid_t user_ns_map_uid(struct user_namespace *to,
 	const struct cred *cred, uid_t uid)
 {
-	return uid;
+	return from_kuid_munged(to, make_kuid(cred->user_ns, uid));
 }
+
 static inline gid_t user_ns_map_gid(struct user_namespace *to,
 	const struct cred *cred, gid_t gid)
 {
-	return gid;
+	return from_kgid_munged(to, make_kgid(cred->user_ns, gid));
 }
 
-#endif
-
 #endif /* _LINUX_USER_H */
diff --git a/kernel/user.c b/kernel/user.c
index cff3856..f9e420e 100644
--- a/kernel/user.c
+++ b/kernel/user.c
@@ -22,6 +22,22 @@
  * and 1 for... ?
  */
 struct user_namespace init_user_ns = {
+	.uid_map = {
+		.nr_extents = 1,
+		.extent[0] = {
+			.first = 0,
+			.lower_first = 0,
+			.count = 4294967295,
+		},
+	},
+	.gid_map = {
+		.nr_extents = 1,
+		.extent[0] = {
+			.first = 0,
+			.lower_first = 0,
+			.count = 4294967295,
+		},
+	},
 	.kref = {
 		.refcount	= ATOMIC_INIT(3),
 	},
diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
index f69741a..9991bac 100644
--- a/kernel/user_namespace.c
+++ b/kernel/user_namespace.c
@@ -12,9 +12,19 @@
 #include <linux/highuid.h>
 #include <linux/cred.h>
 #include <linux/securebits.h>
+#include <linux/keyctl.h>
+#include <linux/key-type.h>
+#include <keys/user-type.h>
+#include <linux/seq_file.h>
+#include <linux/fs.h>
+#include <linux/uaccess.h>
+#include <linux/ctype.h>
 
 static struct kmem_cache *user_ns_cachep __read_mostly;
 
+static bool new_idmap_permitted(struct user_namespace *ns, int cap_setid,
+				struct uid_gid_map *map);
+
 /*
  * Create a new user namespace, deriving the creator from the user in the
  * passed credentials, and replacing that user with the new root user for the
@@ -26,7 +36,6 @@ static struct kmem_cache *user_ns_cachep __read_mostly;
 int create_user_ns(struct cred *new)
 {
 	struct user_namespace *ns, *parent_ns = new->user_ns;
-	struct user_struct *root_user;
 	kuid_t owner = make_kuid(new->user_ns, new->euid);
 	kgid_t group = make_kgid(new->user_ns, new->egid);
 
@@ -38,29 +47,15 @@ int create_user_ns(struct cred *new)
 	    !kgid_has_mapping(parent_ns, group))
 		return -EPERM;
 
-	ns = kmem_cache_alloc(user_ns_cachep, GFP_KERNEL);
+	ns = kmem_cache_zalloc(user_ns_cachep, GFP_KERNEL);
 	if (!ns)
 		return -ENOMEM;
 
 	kref_init(&ns->kref);
-
-	/* Alloc new root user.  */
-	root_user = alloc_uid(make_kuid(ns, 0));
-	if (!root_user) {
-		kmem_cache_free(user_ns_cachep, ns);
-		return -ENOMEM;
-	}
-
-	/* set the new root user in the credentials under preparation */
 	ns->parent = parent_ns;
 	ns->owner = owner;
 	ns->group = group;
-	free_uid(new->user);
-	new->user = root_user;
-	new->uid = new->euid = new->suid = new->fsuid = 0;
-	new->gid = new->egid = new->sgid = new->fsgid = 0;
-	put_group_info(new->group_info);
-	new->group_info = get_group_info(&init_groups);
+
 	/* Start with the same capabilities as init but useless for doing
 	 * anything as the capabilities are bound to the new user namespace.
 	 */
@@ -92,44 +87,512 @@ void free_user_ns(struct kref *kref)
 }
 EXPORT_SYMBOL(free_user_ns);
 
-uid_t user_ns_map_uid(struct user_namespace *to, const struct cred *cred, uid_t uid)
+static u32 map_id_range_down(struct uid_gid_map *map, u32 id, u32 count)
 {
-	struct user_namespace *tmp;
+	unsigned idx, extents;
+	u32 first, last, id2;
 
-	if (likely(to == cred->user_ns))
-		return uid;
+	id2 = id + count - 1;
 
-	/* Is cred->user the creator of the target user_ns
-	 * or the creator of one of it's parents?
-	 */
-	for ( tmp = to; tmp != &init_user_ns; tmp = tmp->parent ) {
-		if (uid_eq(cred->user->uid, tmp->owner)) {
-			return (uid_t)0;
-		}
+	/* Find the matching extent */
+	extents = map->nr_extents;
+	smp_read_barrier_depends();
+	for (idx = 0; idx < extents; idx++) {
+		first = map->extent[idx].first;
+		last = first + map->extent[idx].count - 1;
+		if (id >= first && id <= last &&
+		    (id2 >= first && id2 <= last))
+			break;
+	}
+	/* Map the id or note failure */
+	if (idx < extents)
+		id = (id - first) + map->extent[idx].lower_first;
+	else
+		id = (u32) -1;
+
+	return id;
+}
+
+static u32 map_id_down(struct uid_gid_map *map, u32 id)
+{
+	unsigned idx, extents;
+	u32 first, last;
+
+	/* Find the matching extent */
+	extents = map->nr_extents;
+	smp_read_barrier_depends();
+	for (idx = 0; idx < extents; idx++) {
+		first = map->extent[idx].first;
+		last = first + map->extent[idx].count - 1;
+		if (id >= first && id <= last)
+			break;
+	}
+	/* Map the id or note failure */
+	if (idx < extents)
+		id = (id - first) + map->extent[idx].lower_first;
+	else
+		id = (u32) -1;
+
+	return id;
+}
+
+static u32 map_id_up(struct uid_gid_map *map, u32 id)
+{
+	unsigned idx, extents;
+	u32 first, last;
+
+	/* Find the matching extent */
+	extents = map->nr_extents;
+	smp_read_barrier_depends();
+	for (idx = 0; idx < extents; idx++) {
+		first = map->extent[idx].lower_first;
+		last = first + map->extent[idx].count - 1;
+		if (id >= first && id <= last)
+			break;
 	}
+	/* Map the id or note failure */
+	if (idx < extents)
+		id = (id - first) + map->extent[idx].first;
+	else
+		id = (u32) -1;
+
+	return id;
+}
+
+/**
+ *	make_kuid - Map a user-namespace uid pair into a kuid.
+ *	@ns:  User namespace that the uid is in
+ *	@uid: User identifier
+ *
+ *	Maps a user-namespace uid pair into a kernel internal kuid,
+ *	and returns that kuid.
+ *
+ *	When there is no mapping defined for the user-namespace uid
+ *	pair INVALID_UID is returned.  Callers are expected to test
+ *	for and handle handle INVALID_UID being returned.  INVALID_UID
+ *	may be tested for using uid_valid().
+ */
+kuid_t make_kuid(struct user_namespace *ns, uid_t uid)
+{
+	/* Map the uid to a global kernel uid */
+	return KUIDT_INIT(map_id_down(&ns->uid_map, uid));
+}
+EXPORT_SYMBOL(make_kuid);
+
+/**
+ *	from_kuid - Create a uid from a kuid user-namespace pair.
+ *	@targ: The user namespace we want a uid in.
+ *	@kuid: The kernel internal uid to start with.
+ *
+ *	Map @kuid into the user-namespace specified by @targ and
+ *	return the resulting uid.
+ *
+ *	There is always a mapping into the initial user_namespace.
+ *
+ *	If @kuid has no mapping in @targ (uid_t)-1 is returned.
+ */
+uid_t from_kuid(struct user_namespace *targ, kuid_t kuid)
+{
+	/* Map the uid from a global kernel uid */
+	return map_id_up(&targ->uid_map, __kuid_val(kuid));
+}
+EXPORT_SYMBOL(from_kuid);
+
+/**
+ *	from_kuid_munged - Create a uid from a kuid user-namespace pair.
+ *	@targ: The user namespace we want a uid in.
+ *	@kuid: The kernel internal uid to start with.
+ *
+ *	Map @kuid into the user-namespace specified by @targ and
+ *	return the resulting uid.
+ *
+ *	There is always a mapping into the initial user_namespace.
+ *
+ *	Unlike from_kuid from_kuid_munged never fails and always
+ *	returns a valid uid.  This makes from_kuid_munged appropriate
+ *	for use in syscalls like stat and getuid where failing the
+ *	system call and failing to provide a valid uid are not an
+ *	options.
+ *
+ *	If @kuid has no mapping in @targ overflowuid is returned.
+ */
+uid_t from_kuid_munged(struct user_namespace *targ, kuid_t kuid)
+{
+	uid_t uid;
+	uid = from_kuid(targ, kuid);
+
+	if (uid == (uid_t) -1)
+		uid = overflowuid;
+	return uid;
+}
+EXPORT_SYMBOL(from_kuid_munged);
+
+/**
+ *	make_kgid - Map a user-namespace gid pair into a kgid.
+ *	@ns:  User namespace that the gid is in
+ *	@uid: group identifier
+ *
+ *	Maps a user-namespace gid pair into a kernel internal kgid,
+ *	and returns that kgid.
+ *
+ *	When there is no mapping defined for the user-namespace gid
+ *	pair INVALID_GID is returned.  Callers are expected to test
+ *	for and handle INVALID_GID being returned.  INVALID_GID may be
+ *	tested for using gid_valid().
+ */
+kgid_t make_kgid(struct user_namespace *ns, gid_t gid)
+{
+	/* Map the gid to a global kernel gid */
+	return KGIDT_INIT(map_id_down(&ns->gid_map, gid));
+}
+EXPORT_SYMBOL(make_kgid);
+
+/**
+ *	from_kgid - Create a gid from a kgid user-namespace pair.
+ *	@targ: The user namespace we want a gid in.
+ *	@kgid: The kernel internal gid to start with.
+ *
+ *	Map @kgid into the user-namespace specified by @targ and
+ *	return the resulting gid.
+ *
+ *	There is always a mapping into the initial user_namespace.
+ *
+ *	If @kgid has no mapping in @targ (gid_t)-1 is returned.
+ */
+gid_t from_kgid(struct user_namespace *targ, kgid_t kgid)
+{
+	/* Map the gid from a global kernel gid */
+	return map_id_up(&targ->gid_map, __kgid_val(kgid));
+}
+EXPORT_SYMBOL(from_kgid);
+
+/**
+ *	from_kgid_munged - Create a gid from a kgid user-namespace pair.
+ *	@targ: The user namespace we want a gid in.
+ *	@kgid: The kernel internal gid to start with.
+ *
+ *	Map @kgid into the user-namespace specified by @targ and
+ *	return the resulting gid.
+ *
+ *	There is always a mapping into the initial user_namespace.
+ *
+ *	Unlike from_kgid from_kgid_munged never fails and always
+ *	returns a valid gid.  This makes from_kgid_munged appropriate
+ *	for use in syscalls like stat and getgid where failing the
+ *	system call and failing to provide a valid gid are not options.
+ *
+ *	If @kgid has no mapping in @targ overflowgid is returned.
+ */
+gid_t from_kgid_munged(struct user_namespace *targ, kgid_t kgid)
+{
+	gid_t gid;
+	gid = from_kgid(targ, kgid);
+
+	if (gid == (gid_t) -1)
+		gid = overflowgid;
+	return gid;
+}
+EXPORT_SYMBOL(from_kgid_munged);
+
+static int uid_m_show(struct seq_file *seq, void *v)
+{
+	struct user_namespace *ns = seq->private;
+	struct uid_gid_extent *extent = v;
+	struct user_namespace *lower_ns;
+	uid_t lower;
 
-	/* No useful relationship so no mapping */
-	return overflowuid;
+	lower_ns = current_user_ns();
+	if ((lower_ns == ns) && lower_ns->parent)
+		lower_ns = lower_ns->parent;
+
+	lower = from_kuid(lower_ns, KUIDT_INIT(extent->lower_first));
+
+	seq_printf(seq, "%10u %10u %10u\n",
+		extent->first,
+		lower,
+		extent->count);
+
+	return 0;
 }
 
-gid_t user_ns_map_gid(struct user_namespace *to, const struct cred *cred, gid_t gid)
+static int gid_m_show(struct seq_file *seq, void *v)
 {
-	struct user_namespace *tmp;
+	struct user_namespace *ns = seq->private;
+	struct uid_gid_extent *extent = v;
+	struct user_namespace *lower_ns;
+	gid_t lower;
 
-	if (likely(to == cred->user_ns))
-		return gid;
+	lower_ns = current_user_ns();
+	if ((lower_ns == ns) && lower_ns->parent)
+		lower_ns = lower_ns->parent;
 
-	/* Is cred->user the creator of the target user_ns
-	 * or the creator of one of it's parents?
+	lower = from_kgid(lower_ns, KGIDT_INIT(extent->lower_first));
+
+	seq_printf(seq, "%10u %10u %10u\n",
+		extent->first,
+		lower,
+		extent->count);
+
+	return 0;
+}
+
+static void *m_start(struct seq_file *seq, loff_t *ppos, struct uid_gid_map *map)
+{
+	struct uid_gid_extent *extent = NULL;
+	loff_t pos = *ppos;
+
+	if (pos < map->nr_extents)
+		extent = &map->extent[pos];
+
+	return extent;
+}
+
+static void *uid_m_start(struct seq_file *seq, loff_t *ppos)
+{
+	struct user_namespace *ns = seq->private;
+
+	return m_start(seq, ppos, &ns->uid_map);
+}
+
+static void *gid_m_start(struct seq_file *seq, loff_t *ppos)
+{
+	struct user_namespace *ns = seq->private;
+
+	return m_start(seq, ppos, &ns->gid_map);
+}
+
+static void *m_next(struct seq_file *seq, void *v, loff_t *pos)
+{
+	(*pos)++;
+	return seq->op->start(seq, pos);
+}
+
+static void m_stop(struct seq_file *seq, void *v)
+{
+	return;
+}
+
+struct seq_operations proc_uid_seq_operations = {
+	.start = uid_m_start,
+	.stop = m_stop,
+	.next = m_next,
+	.show = uid_m_show,
+};
+
+struct seq_operations proc_gid_seq_operations = {
+	.start = gid_m_start,
+	.stop = m_stop,
+	.next = m_next,
+	.show = gid_m_show,
+};
+
+static DEFINE_MUTEX(id_map_mutex);
+
+static ssize_t map_write(struct file *file, const char __user *buf,
+			 size_t count, loff_t *ppos,
+			 int cap_setid,
+			 struct uid_gid_map *map,
+			 struct uid_gid_map *parent_map)
+{
+	struct seq_file *seq = file->private_data;
+	struct user_namespace *ns = seq->private;
+	struct uid_gid_map new_map;
+	unsigned idx;
+	struct uid_gid_extent *extent, *last = NULL;
+	unsigned long page = 0;
+	char *kbuf, *pos, *next_line;
+	ssize_t ret = -EINVAL;
+
+	/*
+	 * The id_map_mutex serializes all writes to any given map.
+	 *
+	 * Any map is only ever written once.
+	 *
+	 * An id map fits within 1 cache line on most architectures.
+	 *
+	 * On read nothing needs to be done unless you are on an
+	 * architecture with a crazy cache coherency model like alpha.
+	 *
+	 * There is a one time data dependency between reading the
+	 * count of the extents and the values of the extents.  The
+	 * desired behavior is to see the values of the extents that
+	 * were written before the count of the extents.
+	 *
+	 * To achieve this smp_wmb() is used on guarantee the write
+	 * order and smp_read_barrier_depends() is guaranteed that we
+	 * don't have crazy architectures returning stale data.
+	 *
+	 */
+	mutex_lock(&id_map_mutex);
+
+	ret = -EPERM;
+	/* Only allow one successful write to the map */
+	if (map->nr_extents != 0)
+		goto out;
+
+	/* Require the appropriate privilege CAP_SETUID or CAP_SETGID
+	 * over the user namespace in order to set the id mapping.
 	 */
-	for ( tmp = to; tmp != &init_user_ns; tmp = tmp->parent ) {
-		if (uid_eq(cred->user->uid, tmp->owner)) {
-			return (gid_t)0;
+	if (!ns_capable(ns, cap_setid))
+		goto out;
+
+	/* Get a buffer */
+	ret = -ENOMEM;
+	page = __get_free_page(GFP_TEMPORARY);
+	kbuf = (char *) page;
+	if (!page)
+		goto out;
+
+	/* Only allow <= page size writes at the beginning of the file */
+	ret = -EINVAL;
+	if ((*ppos != 0) || (count >= PAGE_SIZE))
+		goto out;
+
+	/* Slurp in the user data */
+	ret = -EFAULT;
+	if (copy_from_user(kbuf, buf, count))
+		goto out;
+	kbuf[count] = '\0';
+
+	/* Parse the user data */
+	ret = -EINVAL;
+	pos = kbuf;
+	new_map.nr_extents = 0;
+	for (;pos; pos = next_line) {
+		extent = &new_map.extent[new_map.nr_extents];
+
+		/* Find the end of line and ensure I don't look past it */
+		next_line = strchr(pos, '\n');
+		if (next_line) {
+			*next_line = '\0';
+			next_line++;
+			if (*next_line == '\0')
+				next_line = NULL;
 		}
+
+		pos = skip_spaces(pos);
+		extent->first = simple_strtoul(pos, &pos, 10);
+		if (!isspace(*pos))
+			goto out;
+
+		pos = skip_spaces(pos);
+		extent->lower_first = simple_strtoul(pos, &pos, 10);
+		if (!isspace(*pos))
+			goto out;
+
+		pos = skip_spaces(pos);
+		extent->count = simple_strtoul(pos, &pos, 10);
+		if (*pos && !isspace(*pos))
+			goto out;
+
+		/* Verify there is not trailing junk on the line */
+		pos = skip_spaces(pos);
+		if (*pos != '\0')
+			goto out;
+
+		/* Verify we have been given valid starting values */
+		if ((extent->first == (u32) -1) ||
+		    (extent->lower_first == (u32) -1 ))
+			goto out;
+
+		/* Verify count is not zero and does not cause the extent to wrap */
+		if ((extent->first + extent->count) <= extent->first)
+			goto out;
+		if ((extent->lower_first + extent->count) <= extent->lower_first)
+			goto out;
+
+		/* For now only accept extents that are strictly in order */
+		if (last &&
+		    (((last->first + last->count) > extent->first) ||
+		     ((last->lower_first + last->count) > extent->lower_first)))
+			goto out;
+
+		new_map.nr_extents++;
+		last = extent;
+
+		/* Fail if the file contains too many extents */
+		if ((new_map.nr_extents == UID_GID_MAP_MAX_EXTENTS) &&
+		    (next_line != NULL))
+			goto out;
 	}
+	/* Be very certaint the new map actually exists */
+	if (new_map.nr_extents == 0)
+		goto out;
+
+	ret = -EPERM;
+	/* Validate the user is allowed to use user id's mapped to. */
+	if (!new_idmap_permitted(ns, cap_setid, &new_map))
+		goto out;
+
+	/* Map the lower ids from the parent user namespace to the
+	 * kernel global id space.
+	 */
+	for (idx = 0; idx < new_map.nr_extents; idx++) {
+		u32 lower_first;
+		extent = &new_map.extent[idx];
+
+		lower_first = map_id_range_down(parent_map,
+						extent->lower_first,
+						extent->count);
+
+		/* Fail if we can not map the specified extent to
+		 * the kernel global id space.
+		 */
+		if (lower_first == (u32) -1)
+			goto out;
+
+		extent->lower_first = lower_first;
+	}
+
+	/* Install the map */
+	memcpy(map->extent, new_map.extent,
+		new_map.nr_extents*sizeof(new_map.extent[0]));
+	smp_wmb();
+	map->nr_extents = new_map.nr_extents;
+
+	*ppos = count;
+	ret = count;
+out:
+	mutex_unlock(&id_map_mutex);
+	if (page)
+		free_page(page);
+	return ret;
+}
+
+ssize_t proc_uid_map_write(struct file *file, const char __user *buf, size_t size, loff_t *ppos)
+{
+	struct seq_file *seq = file->private_data;
+	struct user_namespace *ns = seq->private;
+
+	if (!ns->parent)
+		return -EPERM;
+
+	return map_write(file, buf, size, ppos, CAP_SETUID,
+			 &ns->uid_map, &ns->parent->uid_map);
+}
+
+ssize_t proc_gid_map_write(struct file *file, const char __user *buf, size_t size, loff_t *ppos)
+{
+	struct seq_file *seq = file->private_data;
+	struct user_namespace *ns = seq->private;
+
+	if (!ns->parent)
+		return -EPERM;
+
+	return map_write(file, buf, size, ppos, CAP_SETGID,
+			 &ns->gid_map, &ns->parent->gid_map);
+}
+
+static bool new_idmap_permitted(struct user_namespace *ns, int cap_setid,
+				struct uid_gid_map *new_map)
+{
+	/* Allow the specified ids if we have the appropriate capability
+	 * (CAP_SETUID or CAP_SETGID) over the parent user namespace.
+	 */
+	if (ns_capable(ns->parent, cap_setid))
+		return true;
 
-	/* No useful relationship so no mapping */
-	return overflowgid;
+	return false;
 }
 
 static __init int user_namespaces_init(void)
-- 
1.7.2.5
