From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 31/85] gfs2: Modify struct gfs2_quota_change_host to
	use struct kqid
Date: Wed, 13 Feb 2013 09:51:20 -0800
Message-ID: <1360777934-5663-31-git-send-email-ebiederm__1816.07675408504$1360778704$gmane$org@xmission.com>
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
 fs/gfs2/quota.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/fs/gfs2/quota.c b/fs/gfs2/quota.c
index 0e7c982..02913e9 100644
--- a/fs/gfs2/quota.c
+++ b/fs/gfs2/quota.c
@@ -71,7 +71,7 @@
 struct gfs2_quota_change_host {
 	u64 qc_change;
 	u32 qc_flags; /* GFS2_QCF_... */
-	u32 qc_id;
+	struct kqid qc_id;
 };
 
 static LIST_HEAD(qd_lru_list);
@@ -1200,7 +1200,9 @@ static void gfs2_quota_change_in(struct gfs2_quota_change_host *qc, const void *
 
 	qc->qc_change = be64_to_cpu(str->qc_change);
 	qc->qc_flags = be32_to_cpu(str->qc_flags);
-	qc->qc_id = be32_to_cpu(str->qc_id);
+	qc->qc_id = make_kqid(&init_user_ns,
+			      (qc->qc_flags & GFS2_QCF_USER)?USRQUOTA:GRPQUOTA,
+			      be32_to_cpu(str->qc_id));
 }
 
 int gfs2_quota_init(struct gfs2_sbd *sdp)
@@ -1264,7 +1266,7 @@ int gfs2_quota_init(struct gfs2_sbd *sdp)
 				continue;
 
 			error = qd_alloc(sdp, (qc.qc_flags & GFS2_QCF_USER),
-					 qc.qc_id, &qd);
+					 from_kqid(&init_user_ns, qc.qc_id), &qd);
 			if (error) {
 				brelse(bh);
 				goto fail;
-- 
1.7.5.4
