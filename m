From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 36/85] gfs2: Use kuid_t and kgid_t types where
	appropriate.
Date: Wed, 13 Feb 2013 09:51:25 -0800
Message-ID: <1360777934-5663-36-git-send-email-ebiederm@xmission.com>
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

Cc: Steven Whitehouse <swhiteho-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/gfs2/inode.c |    3 ++-
 fs/gfs2/quota.c |    8 ++++----
 fs/gfs2/quota.h |    8 ++++----
 3 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/fs/gfs2/inode.c b/fs/gfs2/inode.c
index aa10502..ce07ce4 100644
--- a/fs/gfs2/inode.c
+++ b/fs/gfs2/inode.c
@@ -1580,7 +1580,8 @@ static int setattr_chown(struct inode *inode, struct iattr *attr)
 {
 	struct gfs2_inode *ip = GFS2_I(inode);
 	struct gfs2_sbd *sdp = GFS2_SB(inode);
-	u32 ouid, ogid, nuid, ngid;
+	kuid_t ouid, nuid;
+	kgid_t ogid, ngid;
 	int error;
 
 	ouid = inode->i_uid;
diff --git a/fs/gfs2/quota.c b/fs/gfs2/quota.c
index 0bbb040..87f2740 100644
--- a/fs/gfs2/quota.c
+++ b/fs/gfs2/quota.c
@@ -492,7 +492,7 @@ static void qdsb_put(struct gfs2_quota_data *qd)
 	qd_put(qd);
 }
 
-int gfs2_quota_hold(struct gfs2_inode *ip, u32 uid, u32 gid)
+int gfs2_quota_hold(struct gfs2_inode *ip, kuid_t uid, kgid_t gid)
 {
 	struct gfs2_sbd *sdp = GFS2_SB(&ip->i_inode);
 	struct gfs2_quota_data **qd;
@@ -918,7 +918,7 @@ fail:
 	return error;
 }
 
-int gfs2_quota_lock(struct gfs2_inode *ip, u32 uid, u32 gid)
+int gfs2_quota_lock(struct gfs2_inode *ip, kuid_t uid, kgid_t gid)
 {
 	struct gfs2_sbd *sdp = GFS2_SB(&ip->i_inode);
 	struct gfs2_quota_data *qd;
@@ -1039,7 +1039,7 @@ static int print_message(struct gfs2_quota_data *qd, char *type)
 	return 0;
 }
 
-int gfs2_quota_check(struct gfs2_inode *ip, u32 uid, u32 gid)
+int gfs2_quota_check(struct gfs2_inode *ip, kuid_t uid, kgid_t gid)
 {
 	struct gfs2_sbd *sdp = GFS2_SB(&ip->i_inode);
 	struct gfs2_quota_data *qd;
@@ -1088,7 +1088,7 @@ int gfs2_quota_check(struct gfs2_inode *ip, u32 uid, u32 gid)
 }
 
 void gfs2_quota_change(struct gfs2_inode *ip, s64 change,
-		       u32 uid, u32 gid)
+		       kuid_t uid, kgid_t gid)
 {
 	struct gfs2_quota_data *qd;
 	unsigned int x;
diff --git a/fs/gfs2/quota.h b/fs/gfs2/quota.h
index bef805d..4f5e6e4 100644
--- a/fs/gfs2/quota.h
+++ b/fs/gfs2/quota.h
@@ -17,15 +17,15 @@ struct shrink_control;
 #define NO_UID_QUOTA_CHANGE INVALID_UID
 #define NO_GID_QUOTA_CHANGE INVALID_GID
 
-extern int gfs2_quota_hold(struct gfs2_inode *ip, u32 uid, u32 gid);
+extern int gfs2_quota_hold(struct gfs2_inode *ip, kuid_t uid, kgid_t gid);
 extern void gfs2_quota_unhold(struct gfs2_inode *ip);
 
-extern int gfs2_quota_lock(struct gfs2_inode *ip, u32 uid, u32 gid);
+extern int gfs2_quota_lock(struct gfs2_inode *ip, kuid_t uid, kgid_t gid);
 extern void gfs2_quota_unlock(struct gfs2_inode *ip);
 
-extern int gfs2_quota_check(struct gfs2_inode *ip, u32 uid, u32 gid);
+extern int gfs2_quota_check(struct gfs2_inode *ip, kuid_t uid, kgid_t gid);
 extern void gfs2_quota_change(struct gfs2_inode *ip, s64 change,
-			      u32 uid, u32 gid);
+			      kuid_t uid, kgid_t gid);
 
 extern int gfs2_quota_sync(struct super_block *sb, int type);
 extern int gfs2_quota_refresh(struct gfs2_sbd *sdp, struct kqid qid);
-- 
1.7.5.4
