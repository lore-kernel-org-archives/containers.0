From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH] [v3] mount: dont execute propagate_umount() many times
	for same mounts
Date: Thu, 13 Oct 2016 12:14:55 -0500
Message-ID: <877f9c6ui8.fsf__19428.090847987$1476391307$gmane$org@x220.int.ebiederm.org>
References: <1476141965-21429-1-git-send-email-avagin@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1476141965-21429-1-git-send-email-avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org> (Andrei
	Vagin's message of "Mon, 10 Oct 2016 16:26:05 -0700")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrei Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Andrei Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org> writes:

> The reason of this optimization is that umount() can hold namespace_sem
> for a long time, this semaphore is global, so it affects all users.
> Recently Eric W. Biederman added a per mount namespace limit on the
> number of mounts. The default number of mounts allowed per mount
> namespace at 100,000. Currently this value is allowed to construct a tree
> which requires hours to be umounted.
>
> In a worse case the current complexity of umount_tree() is O(n^3).
> * Enumirate all mounts in a target tree (propagate_umount)
> * Enumirate mounts to find where these changes have to
>   be propagated (mark_umount_candidates)
> * Enumirate mounts to find a requered mount by parent and dentry
>   (__lookup_mnt_lat)
>
> The worse case is when all mounts from the tree live in the same shared
> group. In this case we have to enumirate all mounts on each step.
>
> Here we can optimize the second step. We don't need to make it for
> mounts which we already met when we did this step for previous mounts.
> It reduces the complexity of umount_tree() to O(n^2).

To O(n) not O(n^2).

A hash table lookup (aka __lookup_mnt() and friends) is O(1) or the hash
table is malfunctioning.  Please don't call 

Arguably we are getting into sizes where
the mount hash table fills up and is on the edge of malfunctioning, but
that is not particularly relevant to this case.

What your patch is aiming to do is to take a O(n^2) algorithm and
make it O(n).  That is very much worth doing.

However your patch confuses two separate issues.  Marking mounts that
may be unmounted.  Marking pieces of the propagation tree that have
already been traversed.

I do not see anything requiring propagation trees to intersect at the
set of mounts that are unmounted in umount_tree before propagate_umount
is called.  Which means there are topologies where we can and should do
better than your patch.

I am also bothered that your patch changes how we look up the mount
mounted on a mount point  (aka playing with __lookup_mnt_last).  There
is no reason to do that to solve the problem, and I think it obscures
what is actually going on.

I am going to see if I can rework your basic concept with explicit
marking of the propagation tree.  In the meantime for people
who are want to see what your patch is doing the version below
essentially does the same thing, without the extra essentially
meaningless loop.

Eric


diff --git a/fs/namespace.c b/fs/namespace.c
index 8183fba9ab4d..33a76ee1b76b 100644
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
index 234a9ac49958..ade5e7d8308c 100644
--- a/fs/pnode.c
+++ b/fs/pnode.c
@@ -399,11 +399,18 @@ static void mark_umount_candidates(struct mount *mnt)
 
 	BUG_ON(parent == mnt);
 
+	if (IS_MNT_MARKED(mnt))
+		return;
+
+	SET_MNT_MARK(mnt);
+
 	for (m = propagation_next(parent, parent); m;
 			m = propagation_next(m, parent)) {
 		struct mount *child = __lookup_mnt_last(&m->mnt,
 						mnt->mnt_mountpoint);
-		if (child && (!IS_MNT_LOCKED(child) || IS_MNT_MARKED(m))) {
+		if (child && ((child->mnt.mnt_flags & MNT_UMOUNT) ||
+			      !IS_MNT_LOCKED(child) ||
+			      IS_MNT_MARKED(m))) {
 			SET_MNT_MARK(child);
 		}
 	}
@@ -420,6 +427,11 @@ static void __propagate_umount(struct mount *mnt)
 
 	BUG_ON(parent == mnt);
 
+	if (!IS_MNT_MARKED(mnt))
+		return;
+
+	CLEAR_MNT_MARK(mnt);
+
 	for (m = propagation_next(parent, parent); m;
 			m = propagation_next(m, parent)) {
 
@@ -432,7 +444,8 @@ static void __propagate_umount(struct mount *mnt)
 		if (!child || !IS_MNT_MARKED(child))
 			continue;
 		CLEAR_MNT_MARK(child);
-		if (list_empty(&child->mnt_mounts)) {
+		if (!(child->mnt.mnt_flags & MNT_UMOUNT) &&
+		    list_empty(&child->mnt_mounts)) {
 			list_del_init(&child->mnt_child);
 			child->mnt.mnt_flags |= MNT_UMOUNT;
 			list_move_tail(&child->mnt_list, &mnt->mnt_list);
