From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 33/85] gfs2: Convert gfs2_quota_refresh to take a kqid
Date: Wed, 13 Feb 2013 09:51:22 -0800
Message-ID: <1360777934-5663-33-git-send-email-ebiederm__18864.5829017789$1360778741$gmane$org@xmission.com>
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
Cc: Steven Whitehouse <swhiteho-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

- In quota_refresh_user_store convert the user supplied uid
  into a kqid and pass it to gfs2_quota_refresh.

- In quota_refresh_group_store convert the user supplied gid
  into a kqid and pass it to gfs2_quota_refresh.

Cc: Steven Whitehouse <swhiteho-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/gfs2/quota.c |    5 +++--
 fs/gfs2/quota.h |    2 +-
 fs/gfs2/sys.c   |   14 ++++++++++++--
 3 files changed, 16 insertions(+), 5 deletions(-)

diff --git a/fs/gfs2/quota.c b/fs/gfs2/quota.c
index 20762ae..47315c0 100644
--- a/fs/gfs2/quota.c
+++ b/fs/gfs2/quota.c
@@ -1177,13 +1177,14 @@ static int gfs2_quota_sync_timeo(struct super_block *sb, int type)
 	return gfs2_quota_sync(sb, type);
 }
 
-int gfs2_quota_refresh(struct gfs2_sbd *sdp, int user, u32 id)
+int gfs2_quota_refresh(struct gfs2_sbd *sdp, struct kqid qid)
 {
 	struct gfs2_quota_data *qd;
 	struct gfs2_holder q_gh;
 	int error;
 
-	error = qd_get(sdp, user, id, &qd);
+	error = qd_get(sdp, qid.type == USRQUOTA ? QUOTA_USER : QUOTA_GROUP,
+		       from_kqid(&init_user_ns, qid), &qd);
 	if (error)
 		return error;
 
diff --git a/fs/gfs2/quota.h b/fs/gfs2/quota.h
index 7f67323..bef805d 100644
--- a/fs/gfs2/quota.h
+++ b/fs/gfs2/quota.h
@@ -28,7 +28,7 @@ extern void gfs2_quota_change(struct gfs2_inode *ip, s64 change,
 			      u32 uid, u32 gid);
 
 extern int gfs2_quota_sync(struct super_block *sb, int type);
-extern int gfs2_quota_refresh(struct gfs2_sbd *sdp, int user, u32 id);
+extern int gfs2_quota_refresh(struct gfs2_sbd *sdp, struct kqid qid);
 
 extern int gfs2_quota_init(struct gfs2_sbd *sdp);
 extern void gfs2_quota_cleanup(struct gfs2_sbd *sdp);
diff --git a/fs/gfs2/sys.c b/fs/gfs2/sys.c
index 8056b7b..e6d8d48 100644
--- a/fs/gfs2/sys.c
+++ b/fs/gfs2/sys.c
@@ -175,6 +175,7 @@ static ssize_t quota_sync_store(struct gfs2_sbd *sdp, const char *buf,
 static ssize_t quota_refresh_user_store(struct gfs2_sbd *sdp, const char *buf,
 					size_t len)
 {
+	struct kqid qid;
 	int error;
 	u32 id;
 
@@ -183,13 +184,18 @@ static ssize_t quota_refresh_user_store(struct gfs2_sbd *sdp, const char *buf,
 
 	id = simple_strtoul(buf, NULL, 0);
 
-	error = gfs2_quota_refresh(sdp, 1, id);
+	qid = make_kqid(current_user_ns(), USRQUOTA, id);
+	if (!qid_valid(qid))
+		return -EINVAL;
+
+	error = gfs2_quota_refresh(sdp, qid);
 	return error ? error : len;
 }
 
 static ssize_t quota_refresh_group_store(struct gfs2_sbd *sdp, const char *buf,
 					 size_t len)
 {
+	struct kqid qid;
 	int error;
 	u32 id;
 
@@ -198,7 +204,11 @@ static ssize_t quota_refresh_group_store(struct gfs2_sbd *sdp, const char *buf,
 
 	id = simple_strtoul(buf, NULL, 0);
 
-	error = gfs2_quota_refresh(sdp, 0, id);
+	qid = make_kqid(current_user_ns(), GRPQUOTA, id);
+	if (!qid_valid(qid))
+		return -EINVAL;
+
+	error = gfs2_quota_refresh(sdp, qid);
 	return error ? error : len;
 }
 
-- 
1.7.5.4
