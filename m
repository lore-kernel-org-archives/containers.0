From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 09/85] 9p: Modify the stat structures to use kuid_t and
	kgid_t
Date: Wed, 13 Feb 2013 09:50:58 -0800
Message-ID: <1360777934-5663-9-git-send-email-ebiederm@xmission.com>
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

9p has thre strucrtures that can encode inode stat information.  Modify
all of those structures to contain kuid_t and kgid_t values.  Modify
he wire encoders and decoders of those structures to use 'u' and 'g' instead of
'd' in the format string where uids and gids are present.

This results in all kuid and kgid conversion to and from on the wire values
being performed by the same code in protocol.c where the client is known
at the time of the conversion.

Cc: Eric Van Hensbergen <ericvh-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Ron Minnich <rminnich-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Latchesar Ionkov <lucho-OnYtXJJ0/fesTnJN9+BGXg@public.gmane.org>
Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/9p/vfs_inode.c   |    6 +++---
 include/net/9p/9p.h |   14 +++++++-------
 net/9p/client.c     |   18 +++++++++++++-----
 net/9p/protocol.c   |   13 +++++++------
 4 files changed, 30 insertions(+), 21 deletions(-)

diff --git a/fs/9p/vfs_inode.c b/fs/9p/vfs_inode.c
index 890bed5..1581fe2 100644
--- a/fs/9p/vfs_inode.c
+++ b/fs/9p/vfs_inode.c
@@ -228,9 +228,9 @@ v9fs_blank_wstat(struct p9_wstat *wstat)
 	wstat->uid = NULL;
 	wstat->gid = NULL;
 	wstat->muid = NULL;
-	wstat->n_uid = ~0;
-	wstat->n_gid = ~0;
-	wstat->n_muid = ~0;
+	wstat->n_uid = INVALID_UID;
+	wstat->n_gid = INVALID_GID;
+	wstat->n_muid = INVALID_UID;
 	wstat->extension = NULL;
 }
 
diff --git a/include/net/9p/9p.h b/include/net/9p/9p.h
index 7184853..27dfe85 100644
--- a/include/net/9p/9p.h
+++ b/include/net/9p/9p.h
@@ -407,17 +407,17 @@ struct p9_wstat {
 	char *gid;
 	char *muid;
 	char *extension;	/* 9p2000.u extensions */
-	u32 n_uid;		/* 9p2000.u extensions */
-	u32 n_gid;		/* 9p2000.u extensions */
-	u32 n_muid;		/* 9p2000.u extensions */
+	kuid_t n_uid;		/* 9p2000.u extensions */
+	kgid_t n_gid;		/* 9p2000.u extensions */
+	kuid_t n_muid;		/* 9p2000.u extensions */
 };
 
 struct p9_stat_dotl {
 	u64 st_result_mask;
 	struct p9_qid qid;
 	u32 st_mode;
-	u32 st_uid;
-	u32 st_gid;
+	kuid_t st_uid;
+	kgid_t st_gid;
 	u64 st_nlink;
 	u64 st_rdev;
 	u64 st_size;
@@ -471,8 +471,8 @@ struct p9_stat_dotl {
 struct p9_iattr_dotl {
 	u32 valid;
 	u32 mode;
-	u32 uid;
-	u32 gid;
+	kuid_t uid;
+	kgid_t gid;
 	u64 size;
 	u64 atime_sec;
 	u64 atime_nsec;
diff --git a/net/9p/client.c b/net/9p/client.c
index 17855f0..8eb7542 100644
--- a/net/9p/client.c
+++ b/net/9p/client.c
@@ -1711,7 +1711,9 @@ struct p9_wstat *p9_client_stat(struct p9_fid *fid)
 		(unsigned long long)ret->qid.path, ret->qid.version, ret->mode,
 		ret->atime, ret->mtime, (unsigned long long)ret->length,
 		ret->name, ret->uid, ret->gid, ret->muid, ret->extension,
-		ret->n_uid, ret->n_gid, ret->n_muid);
+		from_kuid(&init_user_ns, ret->n_uid),
+		from_kgid(&init_user_ns, ret->n_gid),
+		from_kuid(&init_user_ns, ret->n_muid));
 
 	p9_free_req(clnt, req);
 	return ret;
@@ -1765,8 +1767,10 @@ struct p9_stat_dotl *p9_client_getattr_dotl(struct p9_fid *fid,
 		"<<< st_btime_sec=%lld st_btime_nsec=%lld\n"
 		"<<< st_gen=%lld st_data_version=%lld",
 		ret->st_result_mask, ret->qid.type, ret->qid.path,
-		ret->qid.version, ret->st_mode, ret->st_nlink, ret->st_uid,
-		ret->st_gid, ret->st_rdev, ret->st_size, ret->st_blksize,
+		ret->qid.version, ret->st_mode, ret->st_nlink,
+		from_kuid(&init_user_ns, ret->st_uid),
+		from_kgid(&init_user_ns, ret->st_gid),
+		ret->st_rdev, ret->st_size, ret->st_blksize,
 		ret->st_blocks, ret->st_atime_sec, ret->st_atime_nsec,
 		ret->st_mtime_sec, ret->st_mtime_nsec, ret->st_ctime_sec,
 		ret->st_ctime_nsec, ret->st_btime_sec, ret->st_btime_nsec,
@@ -1829,7 +1833,9 @@ int p9_client_wstat(struct p9_fid *fid, struct p9_wstat *wst)
 		(unsigned long long)wst->qid.path, wst->qid.version, wst->mode,
 		wst->atime, wst->mtime, (unsigned long long)wst->length,
 		wst->name, wst->uid, wst->gid, wst->muid, wst->extension,
-		wst->n_uid, wst->n_gid, wst->n_muid);
+		from_kuid(&init_user_ns, wst->n_uid),
+		from_kgid(&init_user_ns, wst->n_gid),
+		from_kuid(&init_user_ns, wst->n_muid));
 
 	req = p9_client_rpc(clnt, P9_TWSTAT, "dwS", fid->fid, wst->size+2, wst);
 	if (IS_ERR(req)) {
@@ -1858,7 +1864,9 @@ int p9_client_setattr(struct p9_fid *fid, struct p9_iattr_dotl *p9attr)
 		"    valid=%x mode=%x uid=%d gid=%d size=%lld\n"
 		"    atime_sec=%lld atime_nsec=%lld\n"
 		"    mtime_sec=%lld mtime_nsec=%lld\n",
-		p9attr->valid, p9attr->mode, p9attr->uid, p9attr->gid,
+		p9attr->valid, p9attr->mode,
+		from_kuid(&init_user_ns, p9attr->uid),
+		from_kgid(&init_user_ns, p9attr->gid),
 		p9attr->size, p9attr->atime_sec, p9attr->atime_nsec,
 		p9attr->mtime_sec, p9attr->mtime_nsec);
 
diff --git a/net/9p/protocol.c b/net/9p/protocol.c
index c289c6c..ab9127e 100644
--- a/net/9p/protocol.c
+++ b/net/9p/protocol.c
@@ -199,11 +199,12 @@ p9pdu_vreadf(struct p9_fcall *pdu, int proto_version, const char *fmt,
 				    va_arg(ap, struct p9_wstat *);
 
 				memset(stbuf, 0, sizeof(struct p9_wstat));
-				stbuf->n_uid = stbuf->n_gid = stbuf->n_muid =
-									-1;
+				stbuf->n_uid = stbuf->n_muid = INVALID_UID;
+				stbuf->n_gid = INVALID_GID;
+
 				errcode =
 				    p9pdu_readf(pdu, proto_version,
-						"wwdQdddqssss?sddd",
+						"wwdQdddqssss?sugu",
 						&stbuf->size, &stbuf->type,
 						&stbuf->dev, &stbuf->qid,
 						&stbuf->mode, &stbuf->atime,
@@ -316,7 +317,7 @@ p9pdu_vreadf(struct p9_fcall *pdu, int proto_version, const char *fmt,
 				memset(stbuf, 0, sizeof(struct p9_stat_dotl));
 				errcode =
 				    p9pdu_readf(pdu, proto_version,
-					"qQdddqqqqqqqqqqqqqqq",
+					"qQdugqqqqqqqqqqqqqqq",
 					&stbuf->st_result_mask,
 					&stbuf->qid,
 					&stbuf->st_mode,
@@ -426,7 +427,7 @@ p9pdu_vwritef(struct p9_fcall *pdu, int proto_version, const char *fmt,
 				    va_arg(ap, const struct p9_wstat *);
 				errcode =
 				    p9pdu_writef(pdu, proto_version,
-						 "wwdQdddqssss?sddd",
+						 "wwdQdddqssss?sugu",
 						 stbuf->size, stbuf->type,
 						 stbuf->dev, &stbuf->qid,
 						 stbuf->mode, stbuf->atime,
@@ -504,7 +505,7 @@ p9pdu_vwritef(struct p9_fcall *pdu, int proto_version, const char *fmt,
 							struct p9_iattr_dotl *);
 
 				errcode = p9pdu_writef(pdu, proto_version,
-							"ddddqqqqq",
+							"ddugqqqqq",
 							p9attr->valid,
 							p9attr->mode,
 							p9attr->uid,
-- 
1.7.5.4
