From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [RESEND PATCH] pid_ns: Fix proc_flush_task() accessing freed
	proc_mnt
Date: Thu, 24 Jun 2010 21:18:43 +0200
Message-ID: <20100624191843.GA14205@redhat.com>
References: <20100623203652.GA25298@redhat.com> <1277399329-18087-1-git-send-email-louis.rilling@kerlabs.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="J2SCkAp4GZ/dPZZf"
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1277399329-18087-1-git-send-email-louis.rilling@kerlabs.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Louis Rilling <louis.rilling@kerlabs.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, Pavel Emelyanov <xemul@openvz.org>, Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org


--J2SCkAp4GZ/dPZZf
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On 06/24, Louis Rilling wrote:
>
> [ Resending because of buggy quotes in Eric's address. Sorry for the noise. ]
>
> On 06/19, Oleg Nesterov wrote:
> > And the last one on top of this series, before I go away from this
> > thread ;)
> >
> > Since my further fixes were not approved, I think at least it makes
> > sense to cleanup pid_ns_release_proc() logic a bit.
>
> It's completely untested and could be split into three patches. But I think that
> it solves the issues found so far, and that it will work with Eric's
> unshare(CLONE_NEWPID) too.
>
> What do you think about this approach?

Oh. I shouldn't continue to participate in this discussion... I don't have
the time and my previous patch proves that my patches should be ignored ;)

But, looking at this patch,

> - defer pid_ns_release_proc()->mntput() to a worqueue context, so that
>   pid_ns_release_proc() can be called in atomic context;

OK, not good but this is what I did too,

> - introduce pid_ns->nr_pids, so that we can count the number of pids
>   allocated by alloc_pidmap();

and this adds the extra code to alloc/free pidmap.

> - move the call to pid_ns_prepare_proc() to alloc_pid(), where we know
>   when the first pid of a namespace is allocated;

This is what I personally dislike. I do not think pid_ns_prepare_proc()
should depend on the fact that the first pid was already allocated.

And, this subjective, yes, but it looks a bit strange that upid->nr
has a reference to proc_mnt.

And of course, imho it would nice to not create the circular reference
we currently have.


Louis, Eric.

I am attaching my 2 patches (on top of cleanups) again. Could you take
a look?

Changes:

	- pid_ns_release_proc() nullifies sb->s_fs_info

	- proc_pid_lookup() and proc_self_readlink() check ns != NULL
	  (this is sb->s_fs_info)

I even tried to test this finally, seems to work.

I am not going to argue if you prefer Louis's approach. But I will appreciate
if you explain why my fix is wrong. I am curious because I spent 3 hours doing
grep fs/proc ;)

Oleg.

--J2SCkAp4GZ/dPZZf
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="PNS_5_DESTROY_FROM_WQ.patch"

[PATCH 1/2] pid_ns: move destroy_pid_namespace() into workqueue context

A separate patch to simplify the review of the next change.

Move destroy_pid_namespace() into workqueue context. This allows us to do
mntput() from free_pid_ns() paths, see the next patch.

Add the new member, "struct work_struct destroy" into struct pid_namespace
and change free_pid_ns() to call destroy_pid_namespace() via schedule_work().

The patch looks a bit complicated because it also moves copy_pid_ns() up.

Signed-off-by: Oleg Nesterov <oleg@redhat.com>
---

 include/linux/pid_namespace.h |    1 +
 kernel/pid_namespace.c        |   25 +++++++++++++++++--------
 2 files changed, 18 insertions(+), 8 deletions(-)

--- 35-rc3/include/linux/pid_namespace.h~PNS_5_DESTROY_FROM_WQ	2010-06-23 22:06:07.000000000 +0200
+++ 35-rc3/include/linux/pid_namespace.h	2010-06-24 15:17:46.000000000 +0200
@@ -24,6 +24,7 @@ struct pid_namespace {
 	struct kmem_cache *pid_cachep;
 	unsigned int level;
 	struct pid_namespace *parent;
+	struct work_struct destroy;
 #ifdef CONFIG_PROC_FS
 	struct vfsmount *proc_mnt;
 #endif
--- 35-rc3/kernel/pid_namespace.c~PNS_5_DESTROY_FROM_WQ	2010-06-24 15:16:22.000000000 +0200
+++ 35-rc3/kernel/pid_namespace.c	2010-06-24 15:17:46.000000000 +0200
@@ -114,6 +114,16 @@ out:
 	return ERR_PTR(err);
 }
 
+struct pid_namespace *copy_pid_ns(unsigned long flags,
+					struct pid_namespace *old_ns)
+{
+	if (!(flags & CLONE_NEWPID))
+		return get_pid_ns(old_ns);
+	if (flags & (CLONE_THREAD|CLONE_PARENT))
+		return ERR_PTR(-EINVAL);
+	return create_pid_namespace(old_ns);
+}
+
 static void destroy_pid_namespace(struct pid_namespace *ns)
 {
 	int i;
@@ -123,13 +133,11 @@ static void destroy_pid_namespace(struct
 	kmem_cache_free(pid_ns_cachep, ns);
 }
 
-struct pid_namespace *copy_pid_ns(unsigned long flags, struct pid_namespace *old_ns)
+static void destroy_pid_namespace_work(struct work_struct *work)
 {
-	if (!(flags & CLONE_NEWPID))
-		return get_pid_ns(old_ns);
-	if (flags & (CLONE_THREAD|CLONE_PARENT))
-		return ERR_PTR(-EINVAL);
-	return create_pid_namespace(old_ns);
+	struct pid_namespace *ns =
+			container_of(work, struct pid_namespace, destroy);
+	destroy_pid_namespace(ns);
 }
 
 void free_pid_ns(struct kref *kref)
@@ -137,9 +145,10 @@ void free_pid_ns(struct kref *kref)
 	struct pid_namespace *ns, *parent;
 
 	ns = container_of(kref, struct pid_namespace, kref);
-
 	parent = ns->parent;
-	destroy_pid_namespace(ns);
+
+	INIT_WORK(&ns->destroy, destroy_pid_namespace_work);
+	schedule_work(&ns->destroy);
 
 	if (parent != NULL)
 		put_pid_ns(parent);

--J2SCkAp4GZ/dPZZf
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="PNS_6_BREAK_CIRCLE.patch"

[PATCH 2/2] pid_ns: refactor the buggy pid_ns_release_proc() logic

pid_namespace holds ns->proc_mnt, while this vfsmount has a referene to
the namespace via PROC_I(sb->s_root->d_inode)->pid. To break this circle
/sbin/init does mntput() in pid_ns_release_proc(). See 6f4e6433.

But we have the following problems:

	- Nobody does mntput() if copy_process() fails after
	  pid_ns_prepare_proc().

	- proc_flush_task() checks upid->nr == 1 to verify we are init,
	  this is wrong if a multi-threaded init does exec.

	- As Louis pointed out, this namespace can have the detached
	  EXIT_DEAD tasks which can use ns->proc_mnt after this mntput().

With this patch only pid_namespace has a reference to ns->proc_mnt, and
mntput(ns->proc_mnt) is called by destroy_pid_namespace() paths when we
know that this ns must not have any references (in particular, there are
no pids in this namespace).

Changes:

	- kill proc_flush_task()->pid_ns_release_proc()

	- change fs/proc/root.c so that we don't create the "artificial"
	  references to the namespace or its pid==1.

	- change destroy_pid_namespace() to call pid_ns_release_proc().

	- change pid_ns_release_proc() to clear s_root->d_inode->pid and
	  sb->s_fs_info. The caller is destroy_pid_namespace(), both pid
	  and ns must not have any reference.

	- change proc_self_readlink() and proc_pid_lookup() to check
	  sb->s_fs_info != NULL to detect the case when the proc fs is
	  kept mounted after pid_ns_release_proc().

Reported-by:  Louis Rilling <louis.rilling@kerlabs.com>
Signed-off-by: Oleg Nesterov <oleg@redhat.com>
---

 kernel/pid_namespace.c |    2 ++
 fs/proc/base.c         |   20 ++++++++++++--------
 fs/proc/root.c         |   11 +++++++----
 3 files changed, 21 insertions(+), 12 deletions(-)

--- 35-rc3/kernel/pid_namespace.c~PNS_6_BREAK_CIRCLE	2010-06-24 15:17:46.000000000 +0200
+++ 35-rc3/kernel/pid_namespace.c	2010-06-24 20:48:18.000000000 +0200
@@ -128,6 +128,8 @@ static void destroy_pid_namespace(struct
 {
 	int i;
 
+	pid_ns_release_proc(ns);
+
 	for (i = 0; i < PIDMAP_ENTRIES; i++)
 		kfree(ns->pidmap[i].page);
 	kmem_cache_free(pid_ns_cachep, ns);
--- 35-rc3/fs/proc/base.c~PNS_6_BREAK_CIRCLE	2010-06-24 15:16:21.000000000 +0200
+++ 35-rc3/fs/proc/base.c	2010-06-24 20:48:18.000000000 +0200
@@ -2349,11 +2349,17 @@ static const struct file_operations proc
 /*
  * /proc/self:
  */
+
+static inline pid_t self_tgid(struct dentry *dentry)
+{
+	struct pid_namespace *ns = dentry->d_sb->s_fs_info;
+	return ns ? task_tgid_nr_ns(current, ns) : 0;
+}
+
 static int proc_self_readlink(struct dentry *dentry, char __user *buffer,
 			      int buflen)
 {
-	struct pid_namespace *ns = dentry->d_sb->s_fs_info;
-	pid_t tgid = task_tgid_nr_ns(current, ns);
+	pid_t tgid = self_tgid(dentry);
 	char tmp[PROC_NUMBUF];
 	if (!tgid)
 		return -ENOENT;
@@ -2363,8 +2369,7 @@ static int proc_self_readlink(struct den
 
 static void *proc_self_follow_link(struct dentry *dentry, struct nameidata *nd)
 {
-	struct pid_namespace *ns = dentry->d_sb->s_fs_info;
-	pid_t tgid = task_tgid_nr_ns(current, ns);
+	pid_t tgid = self_tgid(dentry);
 	char *name = ERR_PTR(-ENOENT);
 	if (tgid) {
 		name = __getname();
@@ -2745,10 +2750,6 @@ void proc_flush_task(struct task_struct 
 		proc_flush_task_mnt(upid->ns->proc_mnt, upid->nr,
 					tgid->numbers[i].nr);
 	}
-
-	upid = &pid->numbers[pid->level];
-	if (upid->nr == 1)
-		pid_ns_release_proc(upid->ns);
 }
 
 static struct dentry *proc_pid_instantiate(struct inode *dir,
@@ -2796,6 +2797,9 @@ struct dentry *proc_pid_lookup(struct in
 		goto out;
 
 	ns = dentry->d_sb->s_fs_info;
+	if (!ns)
+		goto out;
+
 	rcu_read_lock();
 	task = find_task_by_pid_ns(tgid, ns);
 	if (task)
--- 35-rc3/fs/proc/root.c~PNS_6_BREAK_CIRCLE	2010-06-23 22:06:01.000000000 +0200
+++ 35-rc3/fs/proc/root.c	2010-06-24 20:48:18.000000000 +0200
@@ -31,7 +31,7 @@ static int proc_set_super(struct super_b
 	struct pid_namespace *ns;
 
 	ns = (struct pid_namespace *)data;
-	sb->s_fs_info = get_pid_ns(ns);
+	sb->s_fs_info = ns;
 	return set_anon_super(sb, NULL);
 }
 
@@ -68,7 +68,7 @@ static int proc_get_sb(struct file_syste
 		struct proc_inode *ei = PROC_I(sb->s_root->d_inode);
 		if (!ei->pid) {
 			rcu_read_lock();
-			ei->pid = get_pid(find_pid_ns(1, ns));
+			ei->pid = find_pid_ns(1, ns);
 			rcu_read_unlock();
 		}
 	}
@@ -83,7 +83,6 @@ static void proc_kill_sb(struct super_bl
 
 	ns = (struct pid_namespace *)sb->s_fs_info;
 	kill_anon_super(sb);
-	put_pid_ns(ns);
 }
 
 static struct file_system_type proc_fs_type = {
@@ -209,5 +208,9 @@ int pid_ns_prepare_proc(struct pid_names
 
 void pid_ns_release_proc(struct pid_namespace *ns)
 {
-	mntput(ns->proc_mnt);
+	if (ns->proc_mnt) {
+		ns->proc_mnt->mnt_sb->s_fs_info = NULL;
+		PROC_I(ns->proc_mnt->mnt_sb->s_root->d_inode)->pid = NULL;
+		mntput(ns->proc_mnt);
+	}
 }

--J2SCkAp4GZ/dPZZf--
