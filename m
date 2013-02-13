From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 11/85] 9p: Modify struct v9fs_session_info to use a
	kuids and kgids
Date: Wed, 13 Feb 2013 09:51:00 -0800
Message-ID: <1360777934-5663-11-git-send-email-ebiederm@xmission.com>
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

Change struct v9fs_session_info and the code that popluates it to use
kuids and kgids.  When parsing the 9p mount options convert the
dfltuid, dflutgid, and the session uid from the current user namespace
into kuids and kgids.  Modify V9FS_DEFUID and V9FS_DEFGUID to be kuid
and kgid values.

Cc: Eric Van Hensbergen <ericvh-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Ron Minnich <rminnich-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Latchesar Ionkov <lucho-OnYtXJJ0/fesTnJN9+BGXg@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/9p/v9fs.c |   30 +++++++++++++++++++++++++-----
 fs/9p/v9fs.h |   10 +++++-----
 2 files changed, 30 insertions(+), 10 deletions(-)

diff --git a/fs/9p/v9fs.c b/fs/9p/v9fs.c
index d64967c..58e6cbc 100644
--- a/fs/9p/v9fs.c
+++ b/fs/9p/v9fs.c
@@ -161,7 +161,13 @@ static int v9fs_parse_options(struct v9fs_session_info *v9ses, char *opts)
 				ret = r;
 				continue;
 			}
-			v9ses->dfltuid = option;
+			v9ses->dfltuid = make_kuid(current_user_ns(), option);
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
+			v9ses->dfltgid = make_kgid(current_user_ns(), option);
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
+				v9ses->uid = make_kuid(current_user_ns(), uid);
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
-- 
1.7.5.4
