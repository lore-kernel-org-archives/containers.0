From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 10/85] 9p: Modify struct 9p_fid to use a kuid_t not a
	uid_t
Date: Wed, 13 Feb 2013 09:50:59 -0800
Message-ID: <1360777934-5663-10-git-send-email-ebiederm@xmission.com>
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

Change struct 9p_fid and it's associated functions to
use kuid_t's instead of uid_t.

Cc: Eric Van Hensbergen <ericvh-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Ron Minnich <rminnich-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Latchesar Ionkov <lucho-OnYtXJJ0/fesTnJN9+BGXg@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/9p/fid.c             |   17 +++++++++--------
 fs/9p/v9fs.c            |    2 +-
 include/net/9p/client.h |    2 +-
 3 files changed, 11 insertions(+), 10 deletions(-)

diff --git a/fs/9p/fid.c b/fs/9p/fid.c
index da8eefb..afd4724 100644
--- a/fs/9p/fid.c
+++ b/fs/9p/fid.c
@@ -74,19 +74,20 @@ int v9fs_fid_add(struct dentry *dentry, struct p9_fid *fid)
  *
  */
 
-static struct p9_fid *v9fs_fid_find(struct dentry *dentry, u32 uid, int any)
+static struct p9_fid *v9fs_fid_find(struct dentry *dentry, kuid_t uid, int any)
 {
 	struct v9fs_dentry *dent;
 	struct p9_fid *fid, *ret;
 
 	p9_debug(P9_DEBUG_VFS, " dentry: %s (%p) uid %d any %d\n",
-		 dentry->d_name.name, dentry, uid, any);
+		 dentry->d_name.name, dentry, from_kuid(&init_user_ns, uid),
+		 any);
 	dent = (struct v9fs_dentry *) dentry->d_fsdata;
 	ret = NULL;
 	if (dent) {
 		spin_lock(&dent->lock);
 		list_for_each_entry(fid, &dent->fidlist, dlist) {
-			if (any || fid->uid == uid) {
+			if (any || uid_eq(fid->uid, uid)) {
 				ret = fid;
 				break;
 			}
@@ -126,7 +127,7 @@ err_out:
 }
 
 static struct p9_fid *v9fs_fid_lookup_with_uid(struct dentry *dentry,
-					       uid_t uid, int any)
+					       kuid_t uid, int any)
 {
 	struct dentry *ds;
 	char **wnames, *uname;
@@ -233,7 +234,7 @@ err_out:
 
 struct p9_fid *v9fs_fid_lookup(struct dentry *dentry)
 {
-	uid_t uid;
+	kuid_t uid;
 	int  any, access;
 	struct v9fs_session_info *v9ses;
 
@@ -253,7 +254,7 @@ struct p9_fid *v9fs_fid_lookup(struct dentry *dentry)
 		break;
 
 	default:
-		uid = ~0;
+		uid = INVALID_UID;
 		any = 0;
 		break;
 	}
@@ -272,7 +273,7 @@ struct p9_fid *v9fs_fid_clone(struct dentry *dentry)
 	return ret;
 }
 
-static struct p9_fid *v9fs_fid_clone_with_uid(struct dentry *dentry, uid_t uid)
+static struct p9_fid *v9fs_fid_clone_with_uid(struct dentry *dentry, kuid_t uid)
 {
 	struct p9_fid *fid, *ret;
 
@@ -289,7 +290,7 @@ struct p9_fid *v9fs_writeback_fid(struct dentry *dentry)
 	int err;
 	struct p9_fid *fid;
 
-	fid = v9fs_fid_clone_with_uid(dentry, 0);
+	fid = v9fs_fid_clone_with_uid(dentry, GLOBAL_ROOT_UID);
 	if (IS_ERR(fid))
 		goto error_out;
 	/*
diff --git a/fs/9p/v9fs.c b/fs/9p/v9fs.c
index 4e0bd9d..d64967c 100644
--- a/fs/9p/v9fs.c
+++ b/fs/9p/v9fs.c
@@ -387,7 +387,7 @@ struct p9_fid *v9fs_session_init(struct v9fs_session_info *v9ses,
 	if ((v9ses->flags & V9FS_ACCESS_MASK) == V9FS_ACCESS_SINGLE)
 		fid->uid = v9ses->uid;
 	else
-		fid->uid = ~0;
+		fid->uid = INVALID_UID;
 
 #ifdef CONFIG_9P_FSCACHE
 	/* register the session for caching */
diff --git a/include/net/9p/client.h b/include/net/9p/client.h
index 6b031ab..5ff70f4 100644
--- a/include/net/9p/client.h
+++ b/include/net/9p/client.h
@@ -187,7 +187,7 @@ struct p9_fid {
 	int mode;
 	struct p9_qid qid;
 	u32 iounit;
-	uid_t uid;
+	kuid_t uid;
 
 	void *rdir;
 
-- 
1.7.5.4
