From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [RFC][PATCH v2] mount: In mark_umount_candidates and
	__propogate_umount visit each mount once
Date: Fri, 14 Oct 2016 13:29:18 -0500
Message-ID: <8737jy3htt.fsf_-_@x220.int.ebiederm.org>
References: <1476141965-21429-1-git-send-email-avagin@openvz.org>
	<877f9c6ui8.fsf@x220.int.ebiederm.org>
	<87pon458l1.fsf_-_@x220.int.ebiederm.org>
	<20161013214650.GB19836@outlook.office365.com>
	<CANaxB-xPkgdyeg0z6TvExMfyy4uOC+Nu4Q99WpCscNKMWz8VPg@mail.gmail.com>
	<87wphb4pjn.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87wphb4pjn.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org> (Eric W. Biederman's
	message of "Thu, 13 Oct 2016 21:45:00 -0500")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: linux-fsdevel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andrei Vagin <avagin-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Id: containers.vger.kernel.org


Adrei Vagin pointed out that time to executue propagate_umount can go
non-linear (and take a ludicrious amount of time) when the mount
propogation trees of the mounts to be unmunted by a lazy unmount
overlap.

Solve this in the most straight forward way possible, by adding a new
mount flag to mark parts of the mount propagation tree that have been
visited, and use that mark to skip parts of the mount propagation tree
that have already been visited during an unmount.  This guarantees
that each mountpoint in the possibly overlapping mount propagation
trees will be visited exactly once.

Add the functions propagation_visit_next and propagation_revisit_next
to coordinate setting and clearling the visited mount mark.

The skipping of already unmounted mounts has been moved from
__lookup_mnt_last to mark_umount_candidates, so that the new
propagation functions can notice record when the propagation tree
passes through the initial set of unmounted mounts.  Except in
umount_tree as part of the unmounting process the only place where
unmounted mounts should be found are in unmounted subtrees.  All of
the other callers of __lookup_mnt_last are from mounted subtrees so
the not checking for unmounted mounts should not affect them.

Here is a script to generate such mount tree:
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
  1024 |  0.071s | 0.023s | 0.008s      | 0.026s | 0.000s      | 0.024s | 0.008s
  2048 |  0.184s | 0.030s | 0.012s      | 0.035s | 0.008s      | 0.030s | 0.012s
  4096 |  0.604s | 0.047s | 0.012s      | 0.042s | 0.016s      | 0.032s | 0.016s
  8912 |  4.471s | 0.085s | 0.020s      | 0.059s | 0.059s      | 0.050s | 0.036s
 16384 | 34.826s | 0.105s | 0.092s      | 0.109s | 0.060s      | 0.087s | 0.068s
 32768 |         | 0.245s | 0.168s      | 0.192s | 0.144s      | 0.167s | 0.156s
 65536 |         | 0.833s | 0.716s      | 0.485s | 0.276s      | 0.468s | 0.316s
131072 |         | 4.628s | 4.108s      | 0.758s | 0.632s      | 0.736s | 0.612s

Andrei Vagin reports fixing this performance problem is part of the
work to fix CVE-2016-6213.

Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Reported-by: Andrei Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---

I think this version is very close.  I had to modify __lookup_mnt_last
to not skip MOUNT_UMOUNT or we would never see when the mount
propagation trees intersected.

This doesn't look as good as the previous buggy version but it looks
good.  When the hash table isn't getting full the times look pretty
linear.  So it may be necessary to do some hash table resizing.

That said there remains one issue I need to think about some more.

In mark_umount_candidates I don't mark mounts that are locked to their
parent and their parent is not marked as a umount candidate.  Given that
we skip processing mounts multiple times this might result in a mount
whose parent gets marked as unmountable after the first time we see a
mount not getting marked as unmountable later.

Anyway Andrei if you could check this out and see if you can see
anything I missed please let me know.

Eric

 fs/namespace.c        |   6 +--
 fs/pnode.c            | 147 ++++++++++++++++++++++++++++++++++++++++++++------
 fs/pnode.h            |   4 ++
 include/linux/mount.h |   2 +
 4 files changed, 138 insertions(+), 21 deletions(-)

diff --git a/fs/namespace.c b/fs/namespace.c
index db1b5a38864e..1ca99fa2e0f4 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -650,13 +650,11 @@ struct mount *__lookup_mnt_last(struct vfsmount *mnt, struct dentry *dentry)
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
index 234a9ac49958..025e3d9339b0 100644
--- a/fs/pnode.c
+++ b/fs/pnode.c
@@ -390,20 +390,137 @@ void propagate_mount_unlock(struct mount *mnt)
 }
 
 /*
+ * get the next mount in the propagation tree (that has not been visited)
+ * @m: the mount seen last
+ * @origin: the original mount from where the tree walk initiated
+ *
+ * Note that peer groups form contiguous segments of slave lists.
+ * We rely on that in get_source() to be able to find out if
+ * vfsmount found while iterating with propagation_next() is
+ * a peer of one we'd found earlier.
+ */
+static struct mount *propagation_visit_child(struct mount *last_child,
+					    struct mount *origin_child)
+{
+	struct mount *m = last_child->mnt_parent;
+	struct mount *origin = origin_child->mnt_parent;
+	struct dentry *mountpoint = origin_child->mnt_mountpoint;
+	struct mount *child;
+
+	/* Has this part of the propgation tree already been visited? */
+	if (IS_MNT_VISITED(last_child))
+		return NULL;
+
+	SET_MNT_VISITED(last_child);
+
+	/* are there any slaves of this mount? */
+	if (!list_empty(&m->mnt_slave_list)) {
+		m = first_slave(m);
+		goto check_slave;
+	}
+	while (1) {
+		struct mount *master = m->mnt_master;
+
+		if (master == origin->mnt_master) {
+			struct mount *next = next_peer(m);
+			while (1) {
+				if (next == origin)
+					return NULL;
+				child = __lookup_mnt_last(&next->mnt, mountpoint);
+				if (child && !IS_MNT_VISITED(child))
+					return child;
+				next = next_peer(next);
+			}
+		} else {
+			while (1) {
+				if (m->mnt_slave.next == &master->mnt_slave_list)
+					break;
+				m = next_slave(m);
+			check_slave:
+				child = __lookup_mnt_last(&m->mnt, mountpoint);
+				if (child && !IS_MNT_VISITED(child))
+					return child;
+			}
+		}
+
+		/* back at master */
+		m = master;
+	}
+}
+
+/*
+ * get the next mount in the propagation tree (that has not been revisited)
+ * @m: the mount seen last
+ * @origin: the original mount from where the tree walk initiated
+ *
+ * Note that peer groups form contiguous segments of slave lists.
+ * We rely on that in get_source() to be able to find out if
+ * vfsmount found while iterating with propagation_next() is
+ * a peer of one we'd found earlier.
+ */
+static struct mount *propagation_revisit_child(struct mount *last_child,
+					       struct mount *origin_child)
+{
+	struct mount *m = last_child->mnt_parent;
+	struct mount *origin = origin_child->mnt_parent;
+	struct dentry *mountpoint = origin_child->mnt_mountpoint;
+	struct mount *child;
+
+	/* Has this part of the propgation tree already been revisited? */
+	if (!IS_MNT_VISITED(last_child))
+		return NULL;
+
+	CLEAR_MNT_VISITED(last_child);
+
+	/* are there any slaves of this mount? */
+	if (!list_empty(&m->mnt_slave_list)) {
+		m = first_slave(m);
+		goto check_slave;
+	}
+	while (1) {
+		struct mount *master = m->mnt_master;
+
+		if (master == origin->mnt_master) {
+			struct mount *next = next_peer(m);
+			while (1) {
+				if (next == origin)
+					return NULL;
+				child = __lookup_mnt_last(&next->mnt, mountpoint);
+				if (child && IS_MNT_VISITED(child))
+					return child;
+				next = next_peer(next);
+			}
+		} else {
+			while (1) {
+				if (m->mnt_slave.next == &master->mnt_slave_list)
+					break;
+				m = next_slave(m);
+			check_slave:
+				child = __lookup_mnt_last(&m->mnt, mountpoint);
+				if (child && IS_MNT_VISITED(child))
+					return child;
+			}
+		}
+
+		/* back at master */
+		m = master;
+	}
+}
+
+/*
  * Mark all mounts that the MNT_LOCKED logic will allow to be unmounted.
  */
 static void mark_umount_candidates(struct mount *mnt)
 {
-	struct mount *parent = mnt->mnt_parent;
-	struct mount *m;
+	struct mount *child;
 
-	BUG_ON(parent == mnt);
+	BUG_ON(mnt->mnt_parent == mnt);
 
-	for (m = propagation_next(parent, parent); m;
-			m = propagation_next(m, parent)) {
-		struct mount *child = __lookup_mnt_last(&m->mnt,
-						mnt->mnt_mountpoint);
-		if (child && (!IS_MNT_LOCKED(child) || IS_MNT_MARKED(m))) {
+	for (child = propagation_visit_child(mnt, mnt); child;
+	     child = propagation_visit_child(child, mnt)) {
+		if (child->mnt.mnt_flags & MNT_UMOUNT)
+			continue;
+		if (!IS_MNT_LOCKED(child) || IS_MNT_MARKED(child->mnt_parent)) {
 			SET_MNT_MARK(child);
 		}
 	}
@@ -415,21 +532,17 @@ static void mark_umount_candidates(struct mount *mnt)
  */
 static void __propagate_umount(struct mount *mnt)
 {
-	struct mount *parent = mnt->mnt_parent;
-	struct mount *m;
-
-	BUG_ON(parent == mnt);
+	struct mount *child;
 
-	for (m = propagation_next(parent, parent); m;
-			m = propagation_next(m, parent)) {
+	BUG_ON(mnt->mnt_parent == mnt);
 
-		struct mount *child = __lookup_mnt_last(&m->mnt,
-						mnt->mnt_mountpoint);
+	for (child = propagation_revisit_child(mnt, mnt); child;
+	     child = propagation_revisit_child(child, mnt)) {
 		/*
 		 * umount the child only if the child has no children
 		 * and the child is marked safe to unmount.
 		 */
-		if (!child || !IS_MNT_MARKED(child))
+		if (!IS_MNT_MARKED(child))
 			continue;
 		CLEAR_MNT_MARK(child);
 		if (list_empty(&child->mnt_mounts)) {
diff --git a/fs/pnode.h b/fs/pnode.h
index 550f5a8b4fcf..988ea4945764 100644
--- a/fs/pnode.h
+++ b/fs/pnode.h
@@ -21,6 +21,10 @@
 #define CLEAR_MNT_MARK(m) ((m)->mnt.mnt_flags &= ~MNT_MARKED)
 #define IS_MNT_LOCKED(m) ((m)->mnt.mnt_flags & MNT_LOCKED)
 
+#define IS_MNT_VISITED(m) ((m)->mnt.mnt_flags & MNT_VISITED)
+#define SET_MNT_VISITED(m) ((m)->mnt.mnt_flags |= MNT_VISITED)
+#define CLEAR_MNT_VISITED(m) ((m)->mnt.mnt_flags &= ~MNT_VISITED)
+
 #define CL_EXPIRE    		0x01
 #define CL_SLAVE     		0x02
 #define CL_COPY_UNBINDABLE	0x04
diff --git a/include/linux/mount.h b/include/linux/mount.h
index 1172cce949a4..773464f85f93 100644
--- a/include/linux/mount.h
+++ b/include/linux/mount.h
@@ -52,6 +52,8 @@ struct mnt_namespace;
 
 #define MNT_INTERNAL	0x4000
 
+#define MNT_VISITED		0x010000
+
 #define MNT_LOCK_ATIME		0x040000
 #define MNT_LOCK_NOEXEC		0x080000
 #define MNT_LOCK_NOSUID		0x100000
-- 
2.8.3
