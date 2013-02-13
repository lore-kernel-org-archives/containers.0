From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 30/85] gfs2: Introduce qd2index
Date: Wed, 13 Feb 2013 09:51:19 -0800
Message-ID: <1360777934-5663-30-git-send-email-ebiederm__25328.8877815523$1360778730$gmane$org@xmission.com>
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

Both qd_alloc and qd2offset perform the exact same computation
to get an index from a gfs2_quota_data.   Make life a little
simpler and factor out this index computation.

Cc: Steven Whitehouse <swhiteho-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/gfs2/quota.c |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/fs/gfs2/quota.c b/fs/gfs2/quota.c
index f8279ee..0e7c982 100644
--- a/fs/gfs2/quota.c
+++ b/fs/gfs2/quota.c
@@ -120,11 +120,17 @@ out:
 	return (atomic_read(&qd_lru_count) * sysctl_vfs_cache_pressure) / 100;
 }
 
+static u64 qd2index(struct gfs2_quota_data *qd)
+{
+	return (2 * (u64)qd->qd_id) +
+		test_bit(QDF_USER, &qd->qd_flags) ? 0 : 1;
+}
+
 static u64 qd2offset(struct gfs2_quota_data *qd)
 {
 	u64 offset;
 
-	offset = 2 * (u64)qd->qd_id + !test_bit(QDF_USER, &qd->qd_flags);
+	offset = qd2index(qd);
 	offset *= sizeof(struct gfs2_quota);
 
 	return offset;
@@ -147,7 +153,7 @@ static int qd_alloc(struct gfs2_sbd *sdp, int user, u32 id,
 	qd->qd_slot = -1;
 	INIT_LIST_HEAD(&qd->qd_reclaim);
 
-	error = gfs2_glock_get(sdp, 2 * (u64)id + !user,
+	error = gfs2_glock_get(sdp, qd2index(qd),
 			      &gfs2_quota_glops, CREATE, &qd->qd_gl);
 	if (error)
 		goto fail;
-- 
1.7.5.4
