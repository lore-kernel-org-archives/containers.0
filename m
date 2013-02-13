From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 63/85] nfsd: idmap use u32 not uid_t as the
	intermediate type
Date: Wed, 13 Feb 2013 09:51:52 -0800
Message-ID: <1360777934-5663-63-git-send-email-ebiederm@xmission.com>
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

u32 and uid_t have the same size and semantics so this change
should have no operational effect.  This just removes the WTF
factor when looking at variables that hold both uids and gids
whos type is uid_t.

Cc: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Cc: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/nfsd/nfs4idmap.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4idmap.c b/fs/nfsd/nfs4idmap.c
index a1f10c0..7e84dfa 100644
--- a/fs/nfsd/nfs4idmap.c
+++ b/fs/nfsd/nfs4idmap.c
@@ -65,7 +65,7 @@ MODULE_PARM_DESC(nfs4_disable_idmapping,
 struct ent {
 	struct cache_head h;
 	int               type;		       /* User / Group */
-	uid_t             id;
+	u32               id;
 	char              name[IDMAP_NAMESZ];
 	char              authname[IDMAP_NAMESZ];
 };
@@ -540,7 +540,7 @@ rqst_authname(struct svc_rqst *rqstp)
 
 static __be32
 idmap_name_to_id(struct svc_rqst *rqstp, int type, const char *name, u32 namelen,
-		uid_t *id)
+		u32 *id)
 {
 	struct ent *item, key = {
 		.type = type,
@@ -564,7 +564,7 @@ idmap_name_to_id(struct svc_rqst *rqstp, int type, const char *name, u32 namelen
 }
 
 static int
-idmap_id_to_name(struct svc_rqst *rqstp, int type, uid_t id, char *name)
+idmap_id_to_name(struct svc_rqst *rqstp, int type, u32 id, char *name)
 {
 	struct ent *item, key = {
 		.id = id,
@@ -587,7 +587,7 @@ idmap_id_to_name(struct svc_rqst *rqstp, int type, uid_t id, char *name)
 }
 
 static bool
-numeric_name_to_id(struct svc_rqst *rqstp, int type, const char *name, u32 namelen, uid_t *id)
+numeric_name_to_id(struct svc_rqst *rqstp, int type, const char *name, u32 namelen, u32 *id)
 {
 	int ret;
 	char buf[11];
@@ -603,7 +603,7 @@ numeric_name_to_id(struct svc_rqst *rqstp, int type, const char *name, u32 namel
 }
 
 static __be32
-do_name_to_id(struct svc_rqst *rqstp, int type, const char *name, u32 namelen, uid_t *id)
+do_name_to_id(struct svc_rqst *rqstp, int type, const char *name, u32 namelen, u32 *id)
 {
 	if (nfs4_disable_idmapping && rqstp->rq_cred.cr_flavor < RPC_AUTH_GSS)
 		if (numeric_name_to_id(rqstp, type, name, namelen, id))
@@ -616,7 +616,7 @@ do_name_to_id(struct svc_rqst *rqstp, int type, const char *name, u32 namelen, u
 }
 
 static int
-do_id_to_name(struct svc_rqst *rqstp, int type, uid_t id, char *name)
+do_id_to_name(struct svc_rqst *rqstp, int type, u32 id, char *name)
 {
 	if (nfs4_disable_idmapping && rqstp->rq_cred.cr_flavor < RPC_AUTH_GSS)
 		return sprintf(name, "%u", id);
-- 
1.7.5.4
