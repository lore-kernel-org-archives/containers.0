From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 29/85] gfs2: Report quotas in the caller's user
	namespace.
Date: Wed, 13 Feb 2013 09:51:18 -0800
Message-ID: <1360777934-5663-29-git-send-email-ebiederm__41799.5247561068$1360778683$gmane$org@xmission.com>
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

When a quota is queried return the uid or the gid in the mapped into
the caller's user namespace.  In addition perform the munged version
of the mapping so that instead of -1 a value that does not map is
reported as the overflowuid or the overflowgid.

Cc: Steven Whitehouse <swhiteho-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/gfs2/quota.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/gfs2/quota.c b/fs/gfs2/quota.c
index dbfacaa..f8279ee 100644
--- a/fs/gfs2/quota.c
+++ b/fs/gfs2/quota.c
@@ -1509,7 +1509,7 @@ static int gfs2_get_dqblk(struct super_block *sb, struct kqid qid,
 	qlvb = (struct gfs2_quota_lvb *)qd->qd_gl->gl_lksb.sb_lvbptr;
 	fdq->d_version = FS_DQUOT_VERSION;
 	fdq->d_flags = (type == QUOTA_USER) ? FS_USER_QUOTA : FS_GROUP_QUOTA;
-	fdq->d_id = from_kqid(&init_user_ns, qid);
+	fdq->d_id = from_kqid_munged(current_user_ns(), qid);
 	fdq->d_blk_hardlimit = be64_to_cpu(qlvb->qb_limit) << sdp->sd_fsb2bb_shift;
 	fdq->d_blk_softlimit = be64_to_cpu(qlvb->qb_warn) << sdp->sd_fsb2bb_shift;
 	fdq->d_bcount = be64_to_cpu(qlvb->qb_value) << sdp->sd_fsb2bb_shift;
-- 
1.7.5.4
