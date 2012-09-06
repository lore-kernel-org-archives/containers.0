From: Zhao Hongjiang <zhaohongjiang37-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] user_ns: compile bug fix in quota.h
Date: Thu, 06 Sep 2012 14:55:40 +0800
Message-ID: <504848EC.3010904@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

From: Zhao Hongjiang <zhaohongjiang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>

Failed to build userns-always-map-user-v53 from Eric's latest
user_ns branch with GCC 4.4.4 compiler due to violation of
C89 standard.

Signed-off-by: Zhao Hongjiang <zhaohongjiang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
 include/linux/quota.h |   15 +++++++++------
 1 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/include/linux/quota.h b/include/linux/quota.h
index 781ffc4..90f12d7 100644
--- a/include/linux/quota.h
+++ b/include/linux/quota.h
@@ -280,9 +280,10 @@ static inline struct kqid make_kqid_invalid(enum quota_type type)
 static inline struct kqid make_kqid_uid(kuid_t uid)
 {
 	struct kqid kqid = {
-		.type = USRQUOTA,
-		.uid  = uid,
+		.type = USRQUOTA
 	};
+	kqid.uid = uid;
+
 	return kqid;
 }

@@ -293,9 +294,10 @@ static inline struct kqid make_kqid_uid(kuid_t uid)
 static inline struct kqid make_kqid_gid(kgid_t gid)
 {
 	struct kqid kqid = {
-		.type = GRPQUOTA,
-		.gid  = gid,
+		.type = GRPQUOTA
 	};
+	kqid.gid  = gid;
+
 	return kqid;
 }

@@ -306,9 +308,10 @@ static inline struct kqid make_kqid_gid(kgid_t gid)
 static inline struct kqid make_kqid_projid(kprojid_t projid)
 {
 	struct kqid kqid = {
-		.type = PRJQUOTA,
-		.projid = projid,
+		.type = PRJQUOTA
 	};
+	kqid.projid = projid;
+
 	return kqid;
 }

-- 1.7.1
