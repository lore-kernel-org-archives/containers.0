From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 64/85] nfsd: Convert idmap to use kuids and kgids
Date: Wed, 13 Feb 2013 09:51:53 -0800
Message-ID: <1360777934-5663-64-git-send-email-ebiederm__13532.3471775793$1360779018$gmane$org@xmission.com>
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Convert nfsd_map_name_to_uid to return a kuid_t value.
Convert nfsd_map_name_to_gid to return a kgid_t value.
Convert nfsd_map_uid_to_name to take a kuid_t parameter.
Convert nfsd_map_gid_to_name to take a kgid_t paramater.

Cc: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Cc: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/nfsd/idmap.h     |    8 ++++----
 fs/nfsd/nfs4idmap.c |   26 ++++++++++++++++++++------
 2 files changed, 24 insertions(+), 10 deletions(-)

diff --git a/fs/nfsd/idmap.h b/fs/nfsd/idmap.h
index 9d513ef..bf95f6b 100644
--- a/fs/nfsd/idmap.h
+++ b/fs/nfsd/idmap.h
@@ -54,9 +54,9 @@ static inline void nfsd_idmap_shutdown(struct net *net)
 }
 #endif
 
-__be32 nfsd_map_name_to_uid(struct svc_rqst *, const char *, size_t, __u32 *);
-__be32 nfsd_map_name_to_gid(struct svc_rqst *, const char *, size_t, __u32 *);
-int nfsd_map_uid_to_name(struct svc_rqst *, __u32, char *);
-int nfsd_map_gid_to_name(struct svc_rqst *, __u32, char *);
+__be32 nfsd_map_name_to_uid(struct svc_rqst *, const char *, size_t, kuid_t *);
+__be32 nfsd_map_name_to_gid(struct svc_rqst *, const char *, size_t, kgid_t *);
+int nfsd_map_uid_to_name(struct svc_rqst *, kuid_t, char *);
+int nfsd_map_gid_to_name(struct svc_rqst *, kgid_t, char *);
 
 #endif /* LINUX_NFSD_IDMAP_H */
diff --git a/fs/nfsd/nfs4idmap.c b/fs/nfsd/nfs4idmap.c
index 7e84dfa..0ce1234 100644
--- a/fs/nfsd/nfs4idmap.c
+++ b/fs/nfsd/nfs4idmap.c
@@ -625,26 +625,40 @@ do_id_to_name(struct svc_rqst *rqstp, int type, u32 id, char *name)
 
 __be32
 nfsd_map_name_to_uid(struct svc_rqst *rqstp, const char *name, size_t namelen,
-		__u32 *id)
+		kuid_t *uid)
 {
-	return do_name_to_id(rqstp, IDMAP_TYPE_USER, name, namelen, id);
+	__be32 status;
+	u32 id = -1;
+	status = do_name_to_id(rqstp, IDMAP_TYPE_USER, name, namelen, &id);
+	*uid = make_kuid(&init_user_ns, id);
+	if (!uid_valid(*uid))
+		status = nfserr_badowner;
+	return status;
 }
 
 __be32
 nfsd_map_name_to_gid(struct svc_rqst *rqstp, const char *name, size_t namelen,
-		__u32 *id)
+		kgid_t *gid)
 {
-	return do_name_to_id(rqstp, IDMAP_TYPE_GROUP, name, namelen, id);
+	__be32 status;
+	u32 id = -1;
+	status = do_name_to_id(rqstp, IDMAP_TYPE_GROUP, name, namelen, &id);
+	*gid = make_kgid(&init_user_ns, id);
+	if (!gid_valid(*gid))
+		status = nfserr_badowner;
+	return status;
 }
 
 int
-nfsd_map_uid_to_name(struct svc_rqst *rqstp, __u32 id, char *name)
+nfsd_map_uid_to_name(struct svc_rqst *rqstp, kuid_t uid, char *name)
 {
+	u32 id = from_kuid(&init_user_ns, uid);
 	return do_id_to_name(rqstp, IDMAP_TYPE_USER, id, name);
 }
 
 int
-nfsd_map_gid_to_name(struct svc_rqst *rqstp, __u32 id, char *name)
+nfsd_map_gid_to_name(struct svc_rqst *rqstp, kgid_t gid, char *name)
 {
+	u32 id = from_kgid(&init_user_ns, gid);
 	return do_id_to_name(rqstp, IDMAP_TYPE_GROUP, id, name);
 }
-- 
1.7.5.4
