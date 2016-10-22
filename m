From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [RFC][PATCH v2] mount: In propagate_umount handle overlapping mount
	propagation trees
Date: Sat, 22 Oct 2016 14:42:03 -0500
Message-ID: <877f90b27o.fsf_-_@xmission.com>
References: <1476141965-21429-1-git-send-email-avagin@openvz.org>
	<877f9c6ui8.fsf@x220.int.ebiederm.org>
	<87pon458l1.fsf_-_@x220.int.ebiederm.org>
	<20161013214650.GB19836@outlook.office365.com>
	<CANaxB-xPkgdyeg0z6TvExMfyy4uOC+Nu4Q99WpCscNKMWz8VPg@mail.gmail.com>
	<87wphb4pjn.fsf@x220.int.ebiederm.org>
	<8737jy3htt.fsf_-_@x220.int.ebiederm.org>
	<20161018024000.GA4901@outlook.office365.com>
	<87r37e9mnj.fsf@xmission.com> <877f95ngpr.fsf_-_@xmission.com>
	<20161020213052.GA25226@outlook.office365.com>
	<87pomtec6c.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87pomtec6c.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> (Eric W. Biederman's message of
	"Fri, 21 Oct 2016 14:26:19 -0500")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrei Vagin <avagin-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>
Cc: linux-fsdevel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Id: containers.vger.kernel.org


Andrei,

This fixes the issue you have reported and through a refactoring
makes the code simpler and easier to verify.  That said I find your
last test case very interesting.   While looking at it in detail
I have realized I don't fully understand why we have both lookup_mnt and
lookup_mnt_last, so I can't say that this change is fully correct.

Outside of propogate_umount I am don't have concerns but I am not 100%
convinced that my change to lookup_mnt_last does the right thing
in the case of propagate_umount.

I do see why your last test case scales badly.  Long chains of shared
mounts that we can't skip.  At the same time I don't really understand
that case.  Part of it has to do with multiple child mounts of the same
mount on the same mountpoint.

So I am working through my concerns.  In the mean time I figured it
would be useful to post this version.  As this version is clearly better
than the version of this change that have come before it.

Eric

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Date: Thu, 13 Oct 2016 13:27:19 -0500

Adrei Vagin pointed out that time to executue propagate_umount can go
non-linear (and take a ludicrious amount of time) when the mount
propogation trees of the mounts to be unmunted by a lazy unmount
overlap.

While investigating the horrible performance I realized that in
the case overlapping mount trees since the addition of locked
mount support the code has been failing to unmount all of the
mounts it should have been unmounting.

Make the walk of the mount propagation trees nearly linear by using
MNT_MARK to mark pieces of the mount propagation trees that have
already been visited, allowing subsequent walks to skip over
subtrees.

Make the processing of mounts order independent by adding a list of
mount entries that need to be unmounted, and simply adding a mount to
that list when it becomes apparent the mount can safely be unmounted.
For mounts that are locked on other mounts but otherwise could be
unmounted move them from their parnets mnt_mounts to mnt_umounts so
that if and when their parent becomes unmounted these mounts can be
added to the list of mounts to unmount.

Add a final pass to clear MNT_MARK and to restore mnt_mounts
from mnt_umounts for anything that did not get unmounted.

Add the functions propagation_visit_next and propagation_revisit_next
to coordinate walking of the mount tree and setting and clearing the
mount mark.

The skipping of already unmounted mounts has been moved from
__lookup_mnt_last to mark_umount_candidates, so that the new
propagation functions can notice when the propagation tree passes
through the initial set of unmounted mounts.  Except in umount_tree as
part of the unmounting process the only place where unmounted mounts
should be found are in unmounted subtrees.  All of the other callers
of __lookup_mnt_last are from mounted subtrees so the not checking for
unmounted mounts should not affect them.

A script to generate overlapping mount propagation trees:
$ cat run.sh
mount -t tmpfs test-mount /mnt
mount --make-shared /mnt
for i in `seq $1`; do
        mkdir /mnt/test.$i
        mount --bind /mnt /mnt/test.$i
done
cat /proc/mounts | grep test-mount | wc -l
time umount -l /mnt
$ for i in `seq 10 16`; do echo $i; unshare -Urm bash ./run.sh $i; done

Here are the performance numbers with and without the patch:

mhash  |  8192   |  8192  |  8192       | 131072 | 131072      | 104857 | 104857
mounts | before  | after  | after (sys) | after  | after (sys) |  after | after (sys)
-------------------------------------------------------------------------------------
  1024 |  0.071s | 0.020s | 0.000s      | 0.022s | 0.004s      | 0.020s | 0.004s
  2048 |  0.184s | 0.022s | 0.004s      | 0.023s | 0.004s      | 0.022s | 0.008s
  4096 |  0.604s | 0.025s | 0.020s      | 0.029s | 0.008s      | 0.026s | 0.004s
  8912 |  4.471s | 0.053s | 0.020s      | 0.051s | 0.024s      | 0.047s | 0.016s
 16384 | 34.826s | 0.088s | 0.060s      | 0.081s | 0.048s      | 0.082s | 0.052s
 32768 |         | 0.216s | 0.172s      | 0.160s | 0.124s      | 0.160s | 0.096s
 65536 |         | 0.819s | 0.726s      | 0.330s | 0.260s      | 0.338s | 0.256s
131072 |         | 4.502s | 4.168s      | 0.707s | 0.580s      | 0.709s | 0.592s

Andrei Vagin reports fixing the performance problem is part of the
work to fix CVE-2016-6213.

A script for a pathlogical set of mounts:

$ cat pathological.sh

mount -t tmpfs base /mnt
mount --make-shared /mnt
mkdir -p /mnt/b

mount -t tmpfs test1 /mnt/b
mount --make-shared /mnt/b
mkdir -p /mnt/b/10

mount -t tmpfs test2 /mnt/b/10
mount --make-shared /mnt/b/10
mkdir -p /mnt/b/10/20

mount --rbind /mnt/b /mnt/b/10/20

unshare -Urm sleep 2
umount -l /mnt/b
wait %%

$ unshare -Urm pathlogical.sh

Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Fixes: a05964f3917c ("[PATCH] shared mounts handling: umount")
Fixes: 0c56fe31420c ("mnt: Don't propagate unmounts to locked mounts")
Reported-by: Andrei Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/mount.h     |   1 +
 fs/namespace.c |   7 +--
 fs/pnode.c     | 179 +++++++++++++++++++++++++++++++++++++++++----------------
 fs/pnode.h     |   2 +-
 4 files changed, 133 insertions(+), 56 deletions(-)

diff --git a/fs/mount.h b/fs/mount.h
index d2e25d7b64b3..00fe0d1d6ba7 100644
--- a/fs/mount.h
+++ b/fs/mount.h
@@ -58,6 +58,7 @@ struct mount {
 	struct mnt_namespace *mnt_ns;	/* containing namespace */
 	struct mountpoint *mnt_mp;	/* where is it mounted */
 	struct hlist_node mnt_mp_list;	/* list mounts with the same mountpoint */
+	struct list_head mnt_umounts;	/* list of children that are being unmounted */
 #ifdef CONFIG_FSNOTIFY
 	struct hlist_head mnt_fsnotify_marks;
 	__u32 mnt_fsnotify_mask;
diff --git a/fs/namespace.c b/fs/namespace.c
index e6c234b1a645..73801391bb00 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -237,6 +237,7 @@ static struct mount *alloc_vfsmnt(const char *name)
 		INIT_LIST_HEAD(&mnt->mnt_slave_list);
 		INIT_LIST_HEAD(&mnt->mnt_slave);
 		INIT_HLIST_NODE(&mnt->mnt_mp_list);
+		INIT_LIST_HEAD(&mnt->mnt_umounts);
 #ifdef CONFIG_FSNOTIFY
 		INIT_HLIST_HEAD(&mnt->mnt_fsnotify_marks);
 #endif
@@ -650,13 +651,11 @@ struct mount *__lookup_mnt_last(struct vfsmount *mnt, struct dentry *dentry)
 	p = __lookup_mnt(mnt, dentry);
 	if (!p)
 		goto out;
-	if (!(p->mnt.mnt_flags & MNT_UMOUNT))
-		res = p;
+	res = p;
 	hlist_for_each_entry_continue(p, mnt_hash) {
 		if (&p->mnt_parent->mnt != mnt || p->mnt_mountpoint != dentry)
 			break;
-		if (!(p->mnt.mnt_flags & MNT_UMOUNT))
-			res = p;
+		res = p;
 	}
 out:
 	return res;
diff --git a/fs/pnode.c b/fs/pnode.c
index 234a9ac49958..8fd1a3fb420c 100644
--- a/fs/pnode.c
+++ b/fs/pnode.c
@@ -134,7 +134,8 @@ void change_mnt_propagation(struct mount *mnt, int type)
 }
 
 /*
- * get the next mount in the propagation tree.
+ * get the next mount that is not a slave of the current mount in the
+ * propagation tree.
  * @m: the mount seen last
  * @origin: the original mount from where the tree walk initiated
  *
@@ -143,13 +144,9 @@ void change_mnt_propagation(struct mount *mnt, int type)
  * vfsmount found while iterating with propagation_next() is
  * a peer of one we'd found earlier.
  */
-static struct mount *propagation_next(struct mount *m,
-					 struct mount *origin)
+static struct mount *propagation_next_sib(struct mount *m,
+						struct mount *origin)
 {
-	/* are there any slaves of this mount? */
-	if (!IS_MNT_NEW(m) && !list_empty(&m->mnt_slave_list))
-		return first_slave(m);
-
 	while (1) {
 		struct mount *master = m->mnt_master;
 
@@ -164,6 +161,26 @@ static struct mount *propagation_next(struct mount *m,
 	}
 }
 
+/*
+ * get the next mount in the propagation tree.
+ * @m: the mount seen last
+ * @origin: the original mount from where the tree walk initiated
+ *
+ * Note that peer groups form contiguous segments of slave lists.
+ * We rely on that in get_source() to be able to find out if
+ * vfsmount found while iterating with propagation_next() is
+ * a peer of one we'd found earlier.
+ */
+static struct mount *propagation_next(struct mount *m,
+					 struct mount *origin)
+{
+	/* are there any slaves of this mount? */
+	if (!IS_MNT_NEW(m) && !list_empty(&m->mnt_slave_list))
+		return first_slave(m);
+
+	return propagation_next_sib(m, origin);
+}
+
 static struct mount *next_group(struct mount *m, struct mount *origin)
 {
 	while (1) {
@@ -389,57 +406,92 @@ void propagate_mount_unlock(struct mount *mnt)
 	}
 }
 
-/*
- * Mark all mounts that the MNT_LOCKED logic will allow to be unmounted.
- */
-static void mark_umount_candidates(struct mount *mnt)
+static struct mount *propagation_visit_child(struct mount *last_child,
+					    struct mount *origin_child)
 {
-	struct mount *parent = mnt->mnt_parent;
-	struct mount *m;
+	struct mount *m = last_child->mnt_parent;
+	struct mount *origin = origin_child->mnt_parent;
+	struct dentry *mountpoint = origin_child->mnt_mountpoint;
+	struct mount *child;
 
-	BUG_ON(parent == mnt);
+	/* Has this part of the propgation tree already been visited? */
+	if (IS_MNT_MARKED(last_child))
+		return NULL;
 
-	for (m = propagation_next(parent, parent); m;
-			m = propagation_next(m, parent)) {
-		struct mount *child = __lookup_mnt_last(&m->mnt,
-						mnt->mnt_mountpoint);
-		if (child && (!IS_MNT_LOCKED(child) || IS_MNT_MARKED(m))) {
-			SET_MNT_MARK(child);
-		}
+	SET_MNT_MARK(last_child);
+
+	m = propagation_next(m, origin);
+	while (m) {
+		child = __lookup_mnt_last(&m->mnt, mountpoint);
+		if (child && !IS_MNT_MARKED(child))
+			return child;
+
+		if (!child)
+			m = propagation_next(m, origin);
+		else
+			m = propagation_next_sib(m, origin);
 	}
+	return NULL;
 }
 
-/*
- * NOTE: unmounting 'mnt' naturally propagates to all other mounts its
- * parent propagates to.
- */
-static void __propagate_umount(struct mount *mnt)
+static struct mount *propagation_revisit_child(struct mount *last_child,
+					       struct mount *origin_child)
 {
-	struct mount *parent = mnt->mnt_parent;
-	struct mount *m;
+	struct mount *m = last_child->mnt_parent;
+	struct mount *origin = origin_child->mnt_parent;
+	struct dentry *mountpoint = origin_child->mnt_mountpoint;
+	struct mount *child;
 
-	BUG_ON(parent == mnt);
+	/* Has this part of the propgation tree already been revisited? */
+	if (!IS_MNT_MARKED(last_child))
+		return NULL;
 
-	for (m = propagation_next(parent, parent); m;
-			m = propagation_next(m, parent)) {
+	CLEAR_MNT_MARK(last_child);
 
-		struct mount *child = __lookup_mnt_last(&m->mnt,
-						mnt->mnt_mountpoint);
-		/*
-		 * umount the child only if the child has no children
-		 * and the child is marked safe to unmount.
-		 */
-		if (!child || !IS_MNT_MARKED(child))
-			continue;
-		CLEAR_MNT_MARK(child);
-		if (list_empty(&child->mnt_mounts)) {
-			list_del_init(&child->mnt_child);
-			child->mnt.mnt_flags |= MNT_UMOUNT;
-			list_move_tail(&child->mnt_list, &mnt->mnt_list);
-		}
+	m = propagation_next(m, origin);
+	while (m) {
+		child = __lookup_mnt_last(&m->mnt, mountpoint);
+		if (child && IS_MNT_MARKED(child))
+			return child;
+
+		if (!child)
+			m = propagation_next(m, origin);
+		else
+			m = propagation_next_sib(m, origin);
 	}
+	return NULL;
 }
 
+static void start_umount_propagation(struct mount *child,
+				     struct list_head *to_umount)
+{
+	do {
+		struct mount *parent = child->mnt_parent;
+
+		if ((child->mnt.mnt_flags & MNT_UMOUNT) ||
+		    !list_empty(&child->mnt_mounts))
+			return;
+
+		if (!IS_MNT_LOCKED(child))
+			list_move_tail(&child->mnt_child, to_umount);
+		else
+			list_move_tail(&child->mnt_child, &parent->mnt_umounts);
+
+		child = NULL;
+		if (IS_MNT_MARKED(parent))
+			child = parent;
+	} while (child);
+}
+
+static void end_umount_propagation(struct mount *child)
+{
+	struct mount *parent = child->mnt_parent;
+
+	if (!list_empty(&parent->mnt_umounts))
+		list_splice_tail_init(&parent->mnt_umounts, &parent->mnt_mounts);
+}
+
+
 /*
  * collect all mounts that receive propagation from the mount in @list,
  * and return these additional mounts in the same list.
@@ -447,14 +499,39 @@ static void __propagate_umount(struct mount *mnt)
  *
  * vfsmount lock must be held for write
  */
-int propagate_umount(struct list_head *list)
+void propagate_umount(struct list_head *list)
 {
 	struct mount *mnt;
+	LIST_HEAD(to_umount);
+	LIST_HEAD(tmp_list);
+
+	/* Find candidates for unmounting */
+	list_for_each_entry(mnt, list, mnt_list) {
+		struct mount *child;
+		for (child = propagation_visit_child(mnt, mnt); child;
+		     child = propagation_visit_child(child, mnt))
+			start_umount_propagation(child, &to_umount);
+	}
 
-	list_for_each_entry_reverse(mnt, list, mnt_list)
-		mark_umount_candidates(mnt);
+	/* Begin unmounting */
+	while (!list_empty(&to_umount)) {
+		mnt = list_first_entry(&to_umount, struct mount, mnt_child);
 
-	list_for_each_entry(mnt, list, mnt_list)
-		__propagate_umount(mnt);
-	return 0;
+		list_del_init(&mnt->mnt_child);
+		mnt->mnt.mnt_flags |= MNT_UMOUNT;
+		list_move_tail(&mnt->mnt_list, &tmp_list);
+
+		if (!list_empty(&mnt->mnt_umounts))
+			list_splice_tail_init(&mnt->mnt_umounts, &to_umount);
+	}
+
+	/* Cleanup the mount propagation tree */
+	list_for_each_entry(mnt, list, mnt_list) {
+		struct mount *child;
+		for (child = propagation_revisit_child(mnt, mnt); child;
+		     child = propagation_revisit_child(child, mnt))
+			end_umount_propagation(child);
+	}
+
+	list_splice_tail(&tmp_list, list);
 }
diff --git a/fs/pnode.h b/fs/pnode.h
index 550f5a8b4fcf..38c6cdb96b34 100644
--- a/fs/pnode.h
+++ b/fs/pnode.h
@@ -41,7 +41,7 @@ static inline void set_mnt_shared(struct mount *mnt)
 void change_mnt_propagation(struct mount *, int);
 int propagate_mnt(struct mount *, struct mountpoint *, struct mount *,
 		struct hlist_head *);
-int propagate_umount(struct list_head *);
+void propagate_umount(struct list_head *);
 int propagate_mount_busy(struct mount *, int);
 void propagate_mount_unlock(struct mount *);
 void mnt_release_group_id(struct mount *);
-- 
2.10.1
