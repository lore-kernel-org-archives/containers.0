From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 43/85] sunrpc: Use kuid_t and kgid_t where appropriate
Date: Wed, 13 Feb 2013 09:51:32 -0800
Message-ID: <1360777934-5663-43-git-send-email-ebiederm@xmission.com>
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

Convert variables that store uids and gids to be of type
kuid_t and kgid_t instead of type uid_t and gid_t.

Cc: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Cc: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 include/linux/sunrpc/auth.h    |    7 ++++---
 include/linux/sunrpc/svcauth.h |    4 ++--
 net/sunrpc/auth_gss/auth_gss.c |    8 ++++----
 net/sunrpc/auth_unix.c         |    4 ++--
 net/sunrpc/svcauth_unix.c      |    8 ++++----
 5 files changed, 16 insertions(+), 15 deletions(-)

diff --git a/include/linux/sunrpc/auth.h b/include/linux/sunrpc/auth.h
index f25ba92..58fda1c 100644
--- a/include/linux/sunrpc/auth.h
+++ b/include/linux/sunrpc/auth.h
@@ -17,14 +17,15 @@
 
 #include <linux/atomic.h>
 #include <linux/rcupdate.h>
+#include <linux/uidgid.h>
 
 /* size of the nodename buffer */
 #define UNX_MAXNODENAME	32
 
 /* Work around the lack of a VFS credential */
 struct auth_cred {
-	uid_t	uid;
-	gid_t	gid;
+	kuid_t	uid;
+	kgid_t	gid;
 	struct group_info *group_info;
 	const char *principal;
 	unsigned char machine_cred : 1;
@@ -48,7 +49,7 @@ struct rpc_cred {
 	unsigned long		cr_flags;	/* various flags */
 	atomic_t		cr_count;	/* ref count */
 
-	uid_t			cr_uid;
+	kuid_t			cr_uid;
 
 	/* per-flavor data */
 };
diff --git a/include/linux/sunrpc/svcauth.h b/include/linux/sunrpc/svcauth.h
index dd74084..ff374ab 100644
--- a/include/linux/sunrpc/svcauth.h
+++ b/include/linux/sunrpc/svcauth.h
@@ -18,8 +18,8 @@
 #include <linux/cred.h>
 
 struct svc_cred {
-	uid_t			cr_uid;
-	gid_t			cr_gid;
+	kuid_t			cr_uid;
+	kgid_t			cr_gid;
 	struct group_info	*cr_group_info;
 	u32			cr_flavor; /* pseudoflavor */
 	char			*cr_principal; /* for gss */
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 6e5c824..4daab81 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -256,7 +256,7 @@ err:
 
 struct gss_upcall_msg {
 	atomic_t count;
-	uid_t	uid;
+	kuid_t	uid;
 	struct rpc_pipe_msg msg;
 	struct list_head list;
 	struct gss_auth *auth;
@@ -303,7 +303,7 @@ gss_release_msg(struct gss_upcall_msg *gss_msg)
 }
 
 static struct gss_upcall_msg *
-__gss_find_upcall(struct rpc_pipe *pipe, uid_t uid)
+__gss_find_upcall(struct rpc_pipe *pipe, kuid_t uid)
 {
 	struct gss_upcall_msg *pos;
 	list_for_each_entry(pos, &pipe->in_downcall, list) {
@@ -445,7 +445,7 @@ static void gss_encode_msg(struct gss_upcall_msg *gss_msg,
 
 static struct gss_upcall_msg *
 gss_alloc_msg(struct gss_auth *gss_auth, struct rpc_clnt *clnt,
-		uid_t uid, const char *service_name)
+		kuid_t uid, const char *service_name)
 {
 	struct gss_upcall_msg *gss_msg;
 	int vers;
@@ -475,7 +475,7 @@ gss_setup_upcall(struct rpc_clnt *clnt, struct gss_auth *gss_auth, struct rpc_cr
 	struct gss_cred *gss_cred = container_of(cred,
 			struct gss_cred, gc_base);
 	struct gss_upcall_msg *gss_new, *gss_msg;
-	uid_t uid = cred->cr_uid;
+	kuid_t uid = cred->cr_uid;
 
 	gss_new = gss_alloc_msg(gss_auth, clnt, uid, gss_cred->gc_principal);
 	if (IS_ERR(gss_new))
diff --git a/net/sunrpc/auth_unix.c b/net/sunrpc/auth_unix.c
index 2f86270..372d915 100644
--- a/net/sunrpc/auth_unix.c
+++ b/net/sunrpc/auth_unix.c
@@ -18,8 +18,8 @@
 
 struct unx_cred {
 	struct rpc_cred		uc_base;
-	gid_t			uc_gid;
-	gid_t			uc_gids[NFS_NGROUPS];
+	kgid_t			uc_gid;
+	kgid_t			uc_gids[NFS_NGROUPS];
 };
 #define uc_uid			uc_base.cr_uid
 
diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
index c8cb5dc..caae662 100644
--- a/net/sunrpc/svcauth_unix.c
+++ b/net/sunrpc/svcauth_unix.c
@@ -415,7 +415,7 @@ svcauth_unix_info_release(struct svc_xprt *xpt)
 
 struct unix_gid {
 	struct cache_head	h;
-	uid_t			uid;
+	kuid_t			uid;
 	struct group_info	*gi;
 };
 
@@ -475,7 +475,7 @@ static int unix_gid_upcall(struct cache_detail *cd, struct cache_head *h)
 	return sunrpc_cache_pipe_upcall(cd, h, unix_gid_request);
 }
 
-static struct unix_gid *unix_gid_lookup(struct cache_detail *cd, uid_t uid);
+static struct unix_gid *unix_gid_lookup(struct cache_detail *cd, kuid_t uid);
 
 static int unix_gid_parse(struct cache_detail *cd,
 			char *mesg, int mlen)
@@ -615,7 +615,7 @@ void unix_gid_cache_destroy(struct net *net)
 	cache_destroy_net(cd, net);
 }
 
-static struct unix_gid *unix_gid_lookup(struct cache_detail *cd, uid_t uid)
+static struct unix_gid *unix_gid_lookup(struct cache_detail *cd, kuid_t uid)
 {
 	struct unix_gid ug;
 	struct cache_head *ch;
@@ -628,7 +628,7 @@ static struct unix_gid *unix_gid_lookup(struct cache_detail *cd, uid_t uid)
 		return NULL;
 }
 
-static struct group_info *unix_gid_find(uid_t uid, struct svc_rqst *rqstp)
+static struct group_info *unix_gid_find(kuid_t uid, struct svc_rqst *rqstp)
 {
 	struct unix_gid *ug;
 	struct group_info *gi;
-- 
1.7.5.4
