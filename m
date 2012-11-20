From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH RFC 01/12] userns: Support 9p interacting with multiple user
	namespaces
Date: Tue, 20 Nov 2012 04:43:29 -0800
Message-ID: <1353415420-5457-1-git-send-email-ebiederm@xmission.com>
References: <87pq38wimv.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87pq38wimv.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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

Use kuid_t and kgid_t in struct v9fs_session_info and struct 9p_fid.

Cc: Eric Van Hensbergen <ericvh-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Ron Minnich <rminnich-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Latchesar Ionkov <lucho-OnYtXJJ0/fesTnJN9+BGXg@public.gmane.org>
Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/9p/fid.c             |   17 +++++++++--------
 fs/9p/v9fs.c            |   34 +++++++++++++++++++++++++++-------
 fs/9p/v9fs.h            |   10 +++++-----
 fs/9p/vfs_inode.c       |    8 ++++----
 fs/9p/vfs_inode_dotl.c  |   22 +++++++++++-----------
 include/net/9p/client.h |   12 ++++++------
 init/Kconfig            |    4 ----
 net/9p/client.c         |   28 ++++++++++++++++------------
 8 files changed, 78 insertions(+), 57 deletions(-)

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
index d934f04..1c750ab 100644
--- a/fs/9p/v9fs.c
+++ b/fs/9p/v9fs.c
@@ -161,7 +161,13 @@ static int v9fs_parse_options(struct v9fs_session_info *v9ses, char *opts)
 				ret = r;
 				continue;
 			}
-			v9ses->dfltuid = option;
+			v9ses->dfltuid = make_kuid(&init_user_ns, option);
+			if (!uid_valid(v9ses->dfltuid)) {
+				p9_debug(P9_DEBUG_ERROR,
+					 "uid field, but not a uid?\n");
+				ret = -EINVAL;
+				continue;
+			}
 			break;
 		case Opt_dfltgid:
 			r = match_int(&args[0], &option);
@@ -171,7 +177,13 @@ static int v9fs_parse_options(struct v9fs_session_info *v9ses, char *opts)
 				ret = r;
 				continue;
 			}
-			v9ses->dfltgid = option;
+			v9ses->dfltgid = make_kgid(&init_user_ns, option);
+			if (!gid_valid(v9ses->dfltgid)) {
+				p9_debug(P9_DEBUG_ERROR,
+					 "gid field, but not a gid?\n");
+				ret = -EINVAL;
+				continue;
+			}
 			break;
 		case Opt_afid:
 			r = match_int(&args[0], &option);
@@ -248,8 +260,9 @@ static int v9fs_parse_options(struct v9fs_session_info *v9ses, char *opts)
 			else if (strcmp(s, "client") == 0) {
 				v9ses->flags |= V9FS_ACCESS_CLIENT;
 			} else {
+				uid_t uid;
 				v9ses->flags |= V9FS_ACCESS_SINGLE;
-				v9ses->uid = simple_strtoul(s, &e, 10);
+				uid = simple_strtoul(s, &e, 10);
 				if (*e != '\0') {
 					ret = -EINVAL;
 					pr_info("Unknown access argument %s\n",
@@ -257,6 +270,13 @@ static int v9fs_parse_options(struct v9fs_session_info *v9ses, char *opts)
 					kfree(s);
 					goto free_and_return;
 				}
+				v9ses->uid = make_kuid(&init_user_ns, uid);
+				if (!uid_valid(v9ses->uid)) {
+					ret = -EINVAL;
+					pr_info("Uknown uid %s\n", s);
+					kfree(s);
+					goto free_and_return;
+				}
 			}
 
 			kfree(s);
@@ -319,7 +339,7 @@ struct p9_fid *v9fs_session_init(struct v9fs_session_info *v9ses,
 	list_add(&v9ses->slist, &v9fs_sessionlist);
 	spin_unlock(&v9fs_sessionlist_lock);
 
-	v9ses->uid = ~0;
+	v9ses->uid = INVALID_UID;
 	v9ses->dfltuid = V9FS_DEFUID;
 	v9ses->dfltgid = V9FS_DEFGID;
 
@@ -364,7 +384,7 @@ struct p9_fid *v9fs_session_init(struct v9fs_session_info *v9ses,
 
 		v9ses->flags &= ~V9FS_ACCESS_MASK;
 		v9ses->flags |= V9FS_ACCESS_ANY;
-		v9ses->uid = ~0;
+		v9ses->uid = INVALID_UID;
 	}
 	if (!v9fs_proto_dotl(v9ses) ||
 		!((v9ses->flags & V9FS_ACCESS_MASK) == V9FS_ACCESS_CLIENT)) {
@@ -375,7 +395,7 @@ struct p9_fid *v9fs_session_init(struct v9fs_session_info *v9ses,
 		v9ses->flags &= ~V9FS_ACL_MASK;
 	}
 
-	fid = p9_client_attach(v9ses->clnt, NULL, v9ses->uname, ~0,
+	fid = p9_client_attach(v9ses->clnt, NULL, v9ses->uname, INVALID_UID,
 							v9ses->aname);
 	if (IS_ERR(fid)) {
 		retval = PTR_ERR(fid);
@@ -387,7 +407,7 @@ struct p9_fid *v9fs_session_init(struct v9fs_session_info *v9ses,
 	if ((v9ses->flags & V9FS_ACCESS_MASK) == V9FS_ACCESS_SINGLE)
 		fid->uid = v9ses->uid;
 	else
-		fid->uid = ~0;
+		fid->uid = INVALID_UID;
 
 #ifdef CONFIG_9P_FSCACHE
 	/* register the session for caching */
diff --git a/fs/9p/v9fs.h b/fs/9p/v9fs.h
index 34c59f1..a8e127c 100644
--- a/fs/9p/v9fs.h
+++ b/fs/9p/v9fs.h
@@ -109,9 +109,9 @@ struct v9fs_session_info {
 	char *uname;		/* user name to mount as */
 	char *aname;		/* name of remote hierarchy being mounted */
 	unsigned int maxdata;	/* max data for client interface */
-	unsigned int dfltuid;	/* default uid/muid for legacy support */
-	unsigned int dfltgid;	/* default gid for legacy support */
-	u32 uid;		/* if ACCESS_SINGLE, the uid that has access */
+	kuid_t dfltuid;		/* default uid/muid for legacy support */
+	kgid_t dfltgid;		/* default gid for legacy support */
+	kuid_t uid;		/* if ACCESS_SINGLE, the uid that has access */
 	struct p9_client *clnt;	/* 9p client */
 	struct list_head slist; /* list of sessions registered with v9fs */
 	struct backing_dev_info bdi;
@@ -165,8 +165,8 @@ extern struct inode *v9fs_inode_from_fid_dotl(struct v9fs_session_info *v9ses,
 #define V9FS_PORT	564
 #define V9FS_DEFUSER	"nobody"
 #define V9FS_DEFANAME	""
-#define V9FS_DEFUID	(-2)
-#define V9FS_DEFGID	(-2)
+#define V9FS_DEFUID	KUIDT_INIT(-2)
+#define V9FS_DEFGID	KGIDT_INIT(-2)
 
 static inline struct v9fs_session_info *v9fs_inode2v9ses(struct inode *inode)
 {
diff --git a/fs/9p/vfs_inode.c b/fs/9p/vfs_inode.c
index 890bed5..2c0f777 100644
--- a/fs/9p/vfs_inode.c
+++ b/fs/9p/vfs_inode.c
@@ -1137,10 +1137,10 @@ static int v9fs_vfs_setattr(struct dentry *dentry, struct iattr *iattr)
 
 	if (v9fs_proto_dotu(v9ses)) {
 		if (iattr->ia_valid & ATTR_UID)
-			wstat.n_uid = iattr->ia_uid;
+			wstat.n_uid = from_kuid(&init_user_ns, iattr->ia_uid);
 
 		if (iattr->ia_valid & ATTR_GID)
-			wstat.n_gid = iattr->ia_gid;
+			wstat.n_gid = from_kgid(&init_user_ns, iattr->ia_gid);
 	}
 
 	/* Write all dirty data */
@@ -1191,8 +1191,8 @@ v9fs_stat2inode(struct p9_wstat *stat, struct inode *inode,
 	inode->i_gid = v9ses->dfltgid;
 
 	if (v9fs_proto_dotu(v9ses)) {
-		inode->i_uid = stat->n_uid;
-		inode->i_gid = stat->n_gid;
+		i_uid_write(inode, stat->n_uid);
+		i_gid_write(inode, stat->n_gid);
 	}
 	if ((S_ISREG(inode->i_mode)) || (S_ISDIR(inode->i_mode))) {
 		if (v9fs_proto_dotu(v9ses) && (stat->extension[0] != '\0')) {
diff --git a/fs/9p/vfs_inode_dotl.c b/fs/9p/vfs_inode_dotl.c
index 4089554..e8695df 100644
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
@@ -576,8 +576,8 @@ int v9fs_vfs_setattr_dotl(struct dentry *dentry, struct iattr *iattr)
 
 	p9attr.valid = v9fs_mapped_iattr_valid(iattr->ia_valid);
 	p9attr.mode = iattr->ia_mode;
-	p9attr.uid = iattr->ia_uid;
-	p9attr.gid = iattr->ia_gid;
+	p9attr.uid = from_kuid(&init_user_ns, iattr->ia_uid);
+	p9attr.gid = from_kgid(&init_user_ns, iattr->ia_gid);
 	p9attr.size = iattr->ia_size;
 	p9attr.atime_sec = iattr->ia_atime.tv_sec;
 	p9attr.atime_nsec = iattr->ia_atime.tv_nsec;
@@ -635,8 +635,8 @@ v9fs_stat2inode_dotl(struct p9_stat_dotl *stat, struct inode *inode)
 		inode->i_mtime.tv_nsec = stat->st_mtime_nsec;
 		inode->i_ctime.tv_sec = stat->st_ctime_sec;
 		inode->i_ctime.tv_nsec = stat->st_ctime_nsec;
-		inode->i_uid = stat->st_uid;
-		inode->i_gid = stat->st_gid;
+		i_uid_write(inode, stat->st_uid);
+		i_gid_write(inode, stat->st_gid);
 		set_nlink(inode, stat->st_nlink);
 
 		mode = stat->st_mode & S_IALLUGO;
@@ -659,9 +659,9 @@ v9fs_stat2inode_dotl(struct p9_stat_dotl *stat, struct inode *inode)
 			inode->i_ctime.tv_nsec = stat->st_ctime_nsec;
 		}
 		if (stat->st_result_mask & P9_STATS_UID)
-			inode->i_uid = stat->st_uid;
+			i_uid_write(inode, stat->st_uid);
 		if (stat->st_result_mask & P9_STATS_GID)
-			inode->i_gid = stat->st_gid;
+			i_gid_write(inode, stat->st_gid);
 		if (stat->st_result_mask & P9_STATS_NLINK)
 			set_nlink(inode, stat->st_nlink);
 		if (stat->st_result_mask & P9_STATS_MODE) {
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
diff --git a/include/net/9p/client.h b/include/net/9p/client.h
index fc9b90b..4d05d94 100644
--- a/include/net/9p/client.h
+++ b/include/net/9p/client.h
@@ -187,7 +187,7 @@ struct p9_fid {
 	int mode;
 	struct p9_qid qid;
 	u32 iounit;
-	uid_t uid;
+	kuid_t uid;
 
 	void *rdir;
 
@@ -220,17 +220,17 @@ void p9_client_destroy(struct p9_client *clnt);
 void p9_client_disconnect(struct p9_client *clnt);
 void p9_client_begin_disconnect(struct p9_client *clnt);
 struct p9_fid *p9_client_attach(struct p9_client *clnt, struct p9_fid *afid,
-					char *uname, u32 n_uname, char *aname);
+					char *uname, kuid_t n_uname, char *aname);
 struct p9_fid *p9_client_walk(struct p9_fid *oldfid, uint16_t nwname,
 		char **wnames, int clone);
 int p9_client_open(struct p9_fid *fid, int mode);
 int p9_client_fcreate(struct p9_fid *fid, char *name, u32 perm, int mode,
 							char *extension);
 int p9_client_link(struct p9_fid *fid, struct p9_fid *oldfid, char *newname);
-int p9_client_symlink(struct p9_fid *fid, char *name, char *symname, gid_t gid,
+int p9_client_symlink(struct p9_fid *fid, char *name, char *symname, kgid_t gid,
 							struct p9_qid *qid);
 int p9_client_create_dotl(struct p9_fid *ofid, char *name, u32 flags, u32 mode,
-		gid_t gid, struct p9_qid *qid);
+		kgid_t gid, struct p9_qid *qid);
 int p9_client_clunk(struct p9_fid *fid);
 int p9_client_fsync(struct p9_fid *fid, int datasync);
 int p9_client_remove(struct p9_fid *fid);
@@ -250,9 +250,9 @@ struct p9_stat_dotl *p9_client_getattr_dotl(struct p9_fid *fid,
 							u64 request_mask);
 
 int p9_client_mknod_dotl(struct p9_fid *oldfid, char *name, int mode,
-			dev_t rdev, gid_t gid, struct p9_qid *);
+			dev_t rdev, kgid_t gid, struct p9_qid *);
 int p9_client_mkdir_dotl(struct p9_fid *fid, char *name, int mode,
-				gid_t gid, struct p9_qid *);
+				kgid_t gid, struct p9_qid *);
 int p9_client_lock_dotl(struct p9_fid *fid, struct p9_flock *flock, u8 *status);
 int p9_client_getlock_dotl(struct p9_fid *fid, struct p9_getlock *fl);
 struct p9_req_t *p9_tag_lookup(struct p9_client *, u16);
diff --git a/init/Kconfig b/init/Kconfig
index 38c1a1d..35c1b89 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -998,11 +998,7 @@ config UIDGID_CONVERTED
 	bool
 	default y
 
-	# Networking
-	depends on NET_9P = n
-
 	# Filesystems
-	depends on 9P_FS = n
 	depends on AFS_FS = n
 	depends on CEPH_FS = n
 	depends on CIFS = n
diff --git a/net/9p/client.c b/net/9p/client.c
index 34d4176..25d58f4 100644
--- a/net/9p/client.c
+++ b/net/9p/client.c
@@ -1100,7 +1100,7 @@ void p9_client_begin_disconnect(struct p9_client *clnt)
 EXPORT_SYMBOL(p9_client_begin_disconnect);
 
 struct p9_fid *p9_client_attach(struct p9_client *clnt, struct p9_fid *afid,
-	char *uname, u32 n_uname, char *aname)
+	char *uname, kuid_t n_uname, char *aname)
 {
 	int err = 0;
 	struct p9_req_t *req;
@@ -1118,7 +1118,8 @@ struct p9_fid *p9_client_attach(struct p9_client *clnt, struct p9_fid *afid,
 	}
 
 	req = p9_client_rpc(clnt, P9_TATTACH, "ddss?d", fid->fid,
-			afid ? afid->fid : P9_NOFID, uname, aname, n_uname);
+			afid ? afid->fid : P9_NOFID, uname, aname,
+			from_kuid(&init_user_ns, n_uname));
 	if (IS_ERR(req)) {
 		err = PTR_ERR(req);
 		goto error;
@@ -1270,7 +1271,7 @@ error:
 EXPORT_SYMBOL(p9_client_open);
 
 int p9_client_create_dotl(struct p9_fid *ofid, char *name, u32 flags, u32 mode,
-		gid_t gid, struct p9_qid *qid)
+		kgid_t gid, struct p9_qid *qid)
 {
 	int err = 0;
 	struct p9_client *clnt;
@@ -1279,14 +1280,16 @@ int p9_client_create_dotl(struct p9_fid *ofid, char *name, u32 flags, u32 mode,
 
 	p9_debug(P9_DEBUG_9P,
 			">>> TLCREATE fid %d name %s flags %d mode %d gid %d\n",
-			ofid->fid, name, flags, mode, gid);
+			ofid->fid, name, flags, mode,
+			from_kgid(&init_user_ns, gid));
 	clnt = ofid->clnt;
 
 	if (ofid->mode != -1)
 		return -EINVAL;
 
 	req = p9_client_rpc(clnt, P9_TLCREATE, "dsddd", ofid->fid, name, flags,
-			mode, gid);
+			mode,
+			from_kgid(&init_user_ns, gid));
 	if (IS_ERR(req)) {
 		err = PTR_ERR(req);
 		goto error;
@@ -1358,7 +1361,7 @@ error:
 }
 EXPORT_SYMBOL(p9_client_fcreate);
 
-int p9_client_symlink(struct p9_fid *dfid, char *name, char *symtgt, gid_t gid,
+int p9_client_symlink(struct p9_fid *dfid, char *name, char *symtgt, kgid_t gid,
 		struct p9_qid *qid)
 {
 	int err = 0;
@@ -1370,7 +1373,7 @@ int p9_client_symlink(struct p9_fid *dfid, char *name, char *symtgt, gid_t gid,
 	clnt = dfid->clnt;
 
 	req = p9_client_rpc(clnt, P9_TSYMLINK, "dssd", dfid->fid, name, symtgt,
-			gid);
+			from_kgid(&init_user_ns, gid));
 	if (IS_ERR(req)) {
 		err = PTR_ERR(req);
 		goto error;
@@ -2106,7 +2109,7 @@ error:
 EXPORT_SYMBOL(p9_client_readdir);
 
 int p9_client_mknod_dotl(struct p9_fid *fid, char *name, int mode,
-			dev_t rdev, gid_t gid, struct p9_qid *qid)
+			dev_t rdev, kgid_t gid, struct p9_qid *qid)
 {
 	int err;
 	struct p9_client *clnt;
@@ -2117,7 +2120,8 @@ int p9_client_mknod_dotl(struct p9_fid *fid, char *name, int mode,
 	p9_debug(P9_DEBUG_9P, ">>> TMKNOD fid %d name %s mode %d major %d "
 		"minor %d\n", fid->fid, name, mode, MAJOR(rdev), MINOR(rdev));
 	req = p9_client_rpc(clnt, P9_TMKNOD, "dsdddd", fid->fid, name, mode,
-		MAJOR(rdev), MINOR(rdev), gid);
+			MAJOR(rdev), MINOR(rdev),
+			from_kgid(&init_user_ns, gid));
 	if (IS_ERR(req))
 		return PTR_ERR(req);
 
@@ -2137,7 +2141,7 @@ error:
 EXPORT_SYMBOL(p9_client_mknod_dotl);
 
 int p9_client_mkdir_dotl(struct p9_fid *fid, char *name, int mode,
-				gid_t gid, struct p9_qid *qid)
+				kgid_t gid, struct p9_qid *qid)
 {
 	int err;
 	struct p9_client *clnt;
@@ -2146,9 +2150,9 @@ int p9_client_mkdir_dotl(struct p9_fid *fid, char *name, int mode,
 	err = 0;
 	clnt = fid->clnt;
 	p9_debug(P9_DEBUG_9P, ">>> TMKDIR fid %d name %s mode %d gid %d\n",
-		 fid->fid, name, mode, gid);
+		 fid->fid, name, mode, from_kgid(&init_user_ns, gid));
 	req = p9_client_rpc(clnt, P9_TMKDIR, "dsdd", fid->fid, name, mode,
-		gid);
+		from_kgid(&init_user_ns, gid));
 	if (IS_ERR(req))
 		return PTR_ERR(req);
 
-- 
1.7.5.4
