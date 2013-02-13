From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 35/85] gfs2: Remove the QUOTA_USER and QUOTA_GROUP
	defines
Date: Wed, 13 Feb 2013 09:51:24 -0800
Message-ID: <1360777934-5663-35-git-send-email-ebiederm@xmission.com>
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

Remove the QUOTA_USER and QUOTA_GRUP defines.  Remove
the last vestigal users of QUOTA_USER and QUOTA_GROUP.

Now that struct kqid is used throughout the gfs2 quota
code the need there is to use QUOTA_USER and QUOTA_GROUP
and the defines are just extraneous and confusing.

Cc: Steven Whitehouse <swhiteho-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/gfs2/quota.c |   25 +++++--------------------
 1 files changed, 5 insertions(+), 20 deletions(-)

diff --git a/fs/gfs2/quota.c b/fs/gfs2/quota.c
index 8cb4d10..0bbb040 100644
--- a/fs/gfs2/quota.c
+++ b/fs/gfs2/quota.c
@@ -65,9 +65,6 @@
 #include "inode.h"
 #include "util.h"
 
-#define QUOTA_USER 1
-#define QUOTA_GROUP 0
-
 struct gfs2_quota_change_host {
 	u64 qc_change;
 	u32 qc_flags; /* GFS2_QCF_... */
@@ -1476,18 +1473,14 @@ static int gfs2_get_dqblk(struct super_block *sb, struct kqid qid,
 	struct gfs2_quota_data *qd;
 	struct gfs2_holder q_gh;
 	int error;
-	int type;
 
 	memset(fdq, 0, sizeof(struct fs_disk_quota));
 
 	if (sdp->sd_args.ar_quota == GFS2_QUOTA_OFF)
 		return -ESRCH; /* Crazy XFS error code */
 
-	if (qid.type == USRQUOTA)
-		type = QUOTA_USER;
-	else if (qid.type == GRPQUOTA)
-		type = QUOTA_GROUP;
-	else
+	if ((qid.type != USRQUOTA) &&
+	    (qid.type != GRPQUOTA))
 		return -EINVAL;
 
 	error = qd_get(sdp, qid, &qd);
@@ -1499,7 +1492,7 @@ static int gfs2_get_dqblk(struct super_block *sb, struct kqid qid,
 
 	qlvb = (struct gfs2_quota_lvb *)qd->qd_gl->gl_lksb.sb_lvbptr;
 	fdq->d_version = FS_DQUOT_VERSION;
-	fdq->d_flags = (type == QUOTA_USER) ? FS_USER_QUOTA : FS_GROUP_QUOTA;
+	fdq->d_flags = (qid.type == USRQUOTA) ? FS_USER_QUOTA : FS_GROUP_QUOTA;
 	fdq->d_id = from_kqid_munged(current_user_ns(), qid);
 	fdq->d_blk_hardlimit = be64_to_cpu(qlvb->qb_limit) << sdp->sd_fsb2bb_shift;
 	fdq->d_blk_softlimit = be64_to_cpu(qlvb->qb_warn) << sdp->sd_fsb2bb_shift;
@@ -1526,21 +1519,13 @@ static int gfs2_set_dqblk(struct super_block *sb, struct kqid qid,
 	int alloc_required;
 	loff_t offset;
 	int error;
-	int type;
 
 	if (sdp->sd_args.ar_quota == GFS2_QUOTA_OFF)
 		return -ESRCH; /* Crazy XFS error code */
 
-	switch(qid.type) {
-	case USRQUOTA:
-		type = QUOTA_USER;
-		break;
-	case GRPQUOTA:
-		type = QUOTA_GROUP;
-		break;
-	default:
+	if ((qid.type != USRQUOTA) &&
+	    (qid.type != GRPQUOTA))
 		return -EINVAL;
-	}
 
 	if (fdq->d_fieldmask & ~GFS2_FIELDMASK)
 		return -EINVAL;
-- 
1.7.5.4
