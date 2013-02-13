From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 32/85] gfs2: Modify qdsb_get to take a struct kqid
Date: Wed, 13 Feb 2013 09:51:21 -0800
Message-ID: <1360777934-5663-32-git-send-email-ebiederm__37393.1166519926$1360778302$gmane$org@xmission.com>
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
 fs/gfs2/quota.c |   13 +++++++------
 1 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/fs/gfs2/quota.c b/fs/gfs2/quota.c
index 02913e9..20762ae 100644
--- a/fs/gfs2/quota.c
+++ b/fs/gfs2/quota.c
@@ -464,12 +464,13 @@ static void qd_unlock(struct gfs2_quota_data *qd)
 	qd_put(qd);
 }
 
-static int qdsb_get(struct gfs2_sbd *sdp, int user, u32 id,
+static int qdsb_get(struct gfs2_sbd *sdp, struct kqid qid,
 		    struct gfs2_quota_data **qdp)
 {
 	int error;
 
-	error = qd_get(sdp, user, id, qdp);
+	error = qd_get(sdp, qid.type == USRQUOTA ? QUOTA_USER : QUOTA_GROUP,
+		       from_kqid(&init_user_ns, qid), qdp);
 	if (error)
 		return error;
 
@@ -518,20 +519,20 @@ int gfs2_quota_hold(struct gfs2_inode *ip, u32 uid, u32 gid)
 	if (sdp->sd_args.ar_quota == GFS2_QUOTA_OFF)
 		return 0;
 
-	error = qdsb_get(sdp, QUOTA_USER, ip->i_inode.i_uid, qd);
+	error = qdsb_get(sdp, make_kqid_uid(ip->i_inode.i_uid), qd);
 	if (error)
 		goto out;
 	ip->i_res->rs_qa_qd_num++;
 	qd++;
 
-	error = qdsb_get(sdp, QUOTA_GROUP, ip->i_inode.i_gid, qd);
+	error = qdsb_get(sdp, make_kqid_gid(ip->i_inode.i_gid), qd);
 	if (error)
 		goto out;
 	ip->i_res->rs_qa_qd_num++;
 	qd++;
 
 	if (uid != NO_UID_QUOTA_CHANGE && uid != ip->i_inode.i_uid) {
-		error = qdsb_get(sdp, QUOTA_USER, uid, qd);
+		error = qdsb_get(sdp, make_kqid_uid(uid), qd);
 		if (error)
 			goto out;
 		ip->i_res->rs_qa_qd_num++;
@@ -539,7 +540,7 @@ int gfs2_quota_hold(struct gfs2_inode *ip, u32 uid, u32 gid)
 	}
 
 	if (gid != NO_GID_QUOTA_CHANGE && gid != ip->i_inode.i_gid) {
-		error = qdsb_get(sdp, QUOTA_GROUP, gid, qd);
+		error = qdsb_get(sdp, make_kqid_gid(gid), qd);
 		if (error)
 			goto out;
 		ip->i_res->rs_qa_qd_num++;
-- 
1.7.5.4
