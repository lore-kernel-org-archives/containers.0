From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 09/19] mnt: Fail collect_mounts when applied to
	unmounted mounts
Date: Thu,  2 Apr 2015 20:56:13 -0500
Message-ID: <1428026183-14879-9-git-send-email-ebiederm__47856.169861234$1428026501$gmane$org@xmission.com>
References: <87a8yqou41.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87a8yqou41.fsf_-_-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
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
Cc: Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>, Omar Sandoval <osandov-nWWhXC5lh1RBDgjK7y7TUQ@public.gmane.org>, Willy Tarreau <w@1wt.eu>
List-Id: containers.vger.kernel.org

The only users of collect_mounts are in audit_tree.c

In audit_tree_trees and audit_add_tree rule the path passed into
collect_mounts is generated from kern_path passed an audit_tree
pathname which is guaranteed to be an absolute path.   In those cases
collect_mounts is obviously intended to work on mounted paths and
if a race results in paths that are unmounted when collect_mounts
it is reasonable to fail early.

The paths passed into audit_tag_tree don't have the absolute path
check.  But are used to play with fsnotify and otherwise interact with
the audit_trees, so again operating only on mounted paths appears
reasonable.

Avoid having to worry about what happens when we try and audit
unmounted filesystems by restricting collect_mounts to mounts
that appear in the mount tree.

Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/namespace.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/fs/namespace.c b/fs/namespace.c
index 2b12b7a9455d..acc5583764dc 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -1669,8 +1669,11 @@ struct vfsmount *collect_mounts(struct path *path)
 {
 	struct mount *tree;
 	namespace_lock();
-	tree = copy_tree(real_mount(path->mnt), path->dentry,
-			 CL_COPY_ALL | CL_PRIVATE);
+	if (!check_mnt(real_mount(path->mnt)))
+		tree = ERR_PTR(-EINVAL);
+	else
+		tree = copy_tree(real_mount(path->mnt), path->dentry,
+				 CL_COPY_ALL | CL_PRIVATE);
 	namespace_unlock();
 	if (IS_ERR(tree))
 		return ERR_CAST(tree);
-- 
2.2.1
