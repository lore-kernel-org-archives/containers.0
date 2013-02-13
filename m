From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 27/85] gfs2: Remove improper checks in gfs2_set_dqblk.
Date: Wed, 13 Feb 2013 09:51:16 -0800
Message-ID: <1360777934-5663-27-git-send-email-ebiederm__7899.14237470857$1360778297$gmane$org@xmission.com>
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

In set_dqblk it is an error to look at fdq->d_id or fdq->d_flags.
Userspace quota applications do not set these fields when calling
quotactl(Q_XSETQLIM,...), and the kernel does not set those fields
when quota_setquota calls set_dqblk.

gfs2 never looks at fdq->d_id or fdq->d_flags after checking
to see if they match the id and type supplied to set_dqblk.

No other linux filesystem in set_dqblk looks at either fdq->d_id
or fdq->d_flags.

Therefore remove these bogus checks from gfs2 and allow normal
quota setting applications to work.

Cc: Steven Whitehouse <swhiteho-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/gfs2/quota.c |    6 ------
 1 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/fs/gfs2/quota.c b/fs/gfs2/quota.c
index ae55e24..e4f6ccf 100644
--- a/fs/gfs2/quota.c
+++ b/fs/gfs2/quota.c
@@ -1543,13 +1543,9 @@ static int gfs2_set_dqblk(struct super_block *sb, struct kqid qid,
 	switch(qid.type) {
 	case USRQUOTA:
 		type = QUOTA_USER;
-		if (fdq->d_flags != FS_USER_QUOTA)
-			return -EINVAL;
 		break;
 	case GRPQUOTA:
 		type = QUOTA_GROUP;
-		if (fdq->d_flags != FS_GROUP_QUOTA)
-			return -EINVAL;
 		break;
 	default:
 		return -EINVAL;
@@ -1557,8 +1553,6 @@ static int gfs2_set_dqblk(struct super_block *sb, struct kqid qid,
 
 	if (fdq->d_fieldmask & ~GFS2_FIELDMASK)
 		return -EINVAL;
-	if (fdq->d_id != from_kqid(&init_user_ns, qid))
-		return -EINVAL;
 
 	error = qd_get(sdp, type, from_kqid(&init_user_ns, qid), &qd);
 	if (error)
-- 
1.7.5.4
