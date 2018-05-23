From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [REVIEW][PATCH 1/6] vfs: Don't allow changing the link count of an
	inode with an invalid uid or gid
Date: Wed, 23 May 2018 18:25:33 -0500
Message-ID: <20180523232538.4880-1-ebiederm__26587.8941784196$1527117882$gmane$org@xmission.com>
References: <87o9h6554f.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87o9h6554f.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Christian Brauner <christian-STijNZzMWpgWenYVfaLwtA@public.gmane.org>
List-Id: containers.vger.kernel.org

Changing the link count of an inode via unlink or link will cause a
write back of that inode.  If the uids or gids are invalid (aka not known
to the kernel) writing the inode back may change the uid or gid in the
filesystem.   To prevent possible filesystem and to avoid the need for
filesystem maintainers to worry about it don't allow operations on
inodes with an invalid uid or gid.

Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/namei.c | 13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index 186bd2464fd5..942c1f096f6b 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -984,13 +984,15 @@ static bool safe_hardlink_source(struct inode *inode)
  */
 static int may_linkat(struct path *link)
 {
-	struct inode *inode;
+	struct inode *inode = link->dentry->d_inode;
+
+	/* Inode writeback is not safe when the uid or gid are invalid. */
+	if (!uid_valid(inode->i_uid) || !gid_valid(inode->i_gid))
+		return -EOVERFLOW;
 
 	if (!sysctl_protected_hardlinks)
 		return 0;
 
-	inode = link->dentry->d_inode;
-
 	/* Source inode owner (or CAP_FOWNER) can hardlink all they like,
 	 * otherwise, it must be a safe source.
 	 */
@@ -2749,6 +2751,11 @@ static int may_delete(struct inode *dir, struct dentry *victim, bool isdir)
 	BUG_ON(!inode);
 
 	BUG_ON(victim->d_parent->d_inode != dir);
+
+	/* Inode writeback is not safe when the uid or gid are invalid. */
+	if (!uid_valid(inode->i_uid) || !gid_valid(inode->i_gid))
+		return -EOVERFLOW;
+
 	audit_inode_child(dir, victim, AUDIT_TYPE_CHILD_DELETE);
 
 	error = inode_permission(dir, MAY_WRITE | MAY_EXEC);
-- 
2.14.1
