From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 05/18] mnt: Move the clear of MNT_LOCKED from copy_tree
	to it's callers.
Date: Fri, 12 Dec 2014 16:48:16 -0600
Message-ID: <1418424509-22389-5-git-send-email-ebiederm__17931.9956027486$1418424714$gmane$org@xmission.com>
References: <87k31wzehb.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87k31wzehb.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Cc: Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Clear MNT_LOCKED in the callers of copy_tree except copy_mnt_ns, and
collect_mounts.  In copy_mnt_ns it is necessary to create an exact
copy of a mount tree, so not clearing MNT_LOCKED is important.
Similarly collect_mounts is used to take a snapshot of the mount tree
for audit logging purposes and auditing using a faithful copy of the
tree is important.

This becomes particularly significant when we start setting MNT_LOCKED
on rootfs to prevent it from being unmounted.

Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/namespace.c | 1 -
 fs/pnode.c     | 1 +
 2 files changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/namespace.c b/fs/namespace.c
index 15d0328bd035..e8d1ffa7f132 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -1613,7 +1613,6 @@ struct mount *copy_tree(struct mount *mnt, struct dentry *dentry,
 	if (IS_ERR(q))
 		return q;
 
-	q->mnt.mnt_flags &= ~MNT_LOCKED;
 	q->mnt_mountpoint = mnt->mnt_mountpoint;
 
 	p = mnt;
diff --git a/fs/pnode.c b/fs/pnode.c
index aae331a5d03b..260ac8f898a4 100644
--- a/fs/pnode.c
+++ b/fs/pnode.c
@@ -242,6 +242,7 @@ static int propagate_one(struct mount *m)
 	child = copy_tree(last_source, last_source->mnt.mnt_root, type);
 	if (IS_ERR(child))
 		return PTR_ERR(child);
+	child->mnt.mnt_flags &= ~MNT_LOCKED;
 	mnt_set_mountpoint(m, mp, child);
 	last_dest = m;
 	last_source = child;
-- 
1.9.1
