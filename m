From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 12/85] 9p: Modify v9fs_get_fsgid_for_create to return a
	kgid
Date: Wed, 13 Feb 2013 09:51:01 -0800
Message-ID: <1360777934-5663-12-git-send-email-ebiederm__6055.94586018032$1360778624$gmane$org@xmission.com>
References: <87621w14vs.fsf@xmission.com>
	<1360777934-5663-1-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1360777934-5663-1-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Latchesar Ionkov <lucho-OnYtXJJ0/fesTnJN9+BGXg@public.gmane.org>, Eric Van Hensbergen <ericvh-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Ron Minnich <rminnich-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Modify v9fs_get_fsgid_for_create to return a kgid and modify all of
the variables that hold the result of v9fs_get_fsgid_for_create to be
of type kgid_t.

Cc: Eric Van Hensbergen <ericvh-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Ron Minnich <rminnich-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Latchesar Ionkov <lucho-OnYtXJJ0/fesTnJN9+BGXg@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/9p/vfs_inode_dotl.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/9p/vfs_inode_dotl.c b/fs/9p/vfs_inode_dotl.c
index 4089554..e278865 100644
--- a/fs/9p/vfs_inode_dotl.c
+++ b/fs/9p/vfs_inode_dotl.c
@@ -57,7 +57,7 @@ v9fs_vfs_mknod_dotl(struct inode *dir, struct dentry *dentry, umode_t omode,
  * group of the new file system object.
  */
 
-static gid_t v9fs_get_fsgid_for_create(struct inode *dir_inode)
+static kgid_t v9fs_get_fsgid_for_create(struct inode *dir_inode)
 {
 	BUG_ON(dir_inode == NULL);
 
@@ -246,7 +246,7 @@ v9fs_vfs_atomic_open_dotl(struct inode *dir, struct dentry *dentry,
 			  int *opened)
 {
 	int err = 0;
-	gid_t gid;
+	kgid_t gid;
 	umode_t mode;
 	char *name = NULL;
 	struct p9_qid qid;
@@ -391,7 +391,7 @@ static int v9fs_vfs_mkdir_dotl(struct inode *dir,
 	int err;
 	struct v9fs_session_info *v9ses;
 	struct p9_fid *fid = NULL, *dfid = NULL;
-	gid_t gid;
+	kgid_t gid;
 	char *name;
 	umode_t mode;
 	struct inode *inode;
@@ -692,7 +692,7 @@ v9fs_vfs_symlink_dotl(struct inode *dir, struct dentry *dentry,
 		const char *symname)
 {
 	int err;
-	gid_t gid;
+	kgid_t gid;
 	char *name;
 	struct p9_qid qid;
 	struct inode *inode;
@@ -832,7 +832,7 @@ v9fs_vfs_mknod_dotl(struct inode *dir, struct dentry *dentry, umode_t omode,
 		dev_t rdev)
 {
 	int err;
-	gid_t gid;
+	kgid_t gid;
 	char *name;
 	umode_t mode;
 	struct v9fs_session_info *v9ses;
-- 
1.7.5.4
