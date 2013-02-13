From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 44/85] sunrpc: Use uid_eq and gid_eq where appropriate
Date: Wed, 13 Feb 2013 09:51:33 -0800
Message-ID: <1360777934-5663-44-git-send-email-ebiederm@xmission.com>
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

When comparing uids use uid_eq instead of ==.
When comparing gids use gid_eq instead of ==.

And unfortunate cost of type safety.

Cc: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Cc: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 net/sunrpc/auth_generic.c      |    8 ++++----
 net/sunrpc/auth_gss/auth_gss.c |    4 ++--
 net/sunrpc/auth_unix.c         |    2 +-
 net/sunrpc/svcauth_unix.c      |    2 +-
 4 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/net/sunrpc/auth_generic.c b/net/sunrpc/auth_generic.c
index 9d2e0b0..bff3e47 100644
--- a/net/sunrpc/auth_generic.c
+++ b/net/sunrpc/auth_generic.c
@@ -129,8 +129,8 @@ machine_cred_match(struct auth_cred *acred, struct generic_cred *gcred, int flag
 {
 	if (!gcred->acred.machine_cred ||
 	    gcred->acred.principal != acred->principal ||
-	    gcred->acred.uid != acred->uid ||
-	    gcred->acred.gid != acred->gid)
+	    !uid_eq(gcred->acred.uid, acred->uid) ||
+	    !gid_eq(gcred->acred.gid, acred->gid))
 		return 0;
 	return 1;
 }
@@ -147,8 +147,8 @@ generic_match(struct auth_cred *acred, struct rpc_cred *cred, int flags)
 	if (acred->machine_cred)
 		return machine_cred_match(acred, gcred, flags);
 
-	if (gcred->acred.uid != acred->uid ||
-	    gcred->acred.gid != acred->gid ||
+	if (!uid_eq(gcred->acred.uid, acred->uid) ||
+	    !gid_eq(gcred->acred.gid, acred->gid) ||
 	    gcred->acred.machine_cred != 0)
 		goto out_nomatch;
 
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 4daab81..1b8b3e4 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -307,7 +307,7 @@ __gss_find_upcall(struct rpc_pipe *pipe, kuid_t uid)
 {
 	struct gss_upcall_msg *pos;
 	list_for_each_entry(pos, &pipe->in_downcall, list) {
-		if (pos->uid != uid)
+		if (!uid_eq(pos->uid, uid))
 			continue;
 		atomic_inc(&pos->count);
 		dprintk("RPC:       %s found msg %p\n", __func__, pos);
@@ -1115,7 +1115,7 @@ out:
 	}
 	if (gss_cred->gc_principal != NULL)
 		return 0;
-	return rc->cr_uid == acred->uid;
+	return uid_eq(rc->cr_uid, acred->uid);
 }
 
 /*
diff --git a/net/sunrpc/auth_unix.c b/net/sunrpc/auth_unix.c
index 372d915..8365a9c 100644
--- a/net/sunrpc/auth_unix.c
+++ b/net/sunrpc/auth_unix.c
@@ -123,7 +123,7 @@ unx_match(struct auth_cred *acred, struct rpc_cred *rcred, int flags)
 	unsigned int i;
 
 
-	if (cred->uc_uid != acred->uid || cred->uc_gid != acred->gid)
+	if (!uid_eq(cred->uc_uid, acred->uid) || !gid_eq(cred->uc_gid, acred->gid))
 		return 0;
 
 	if (acred->group_info != NULL)
diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
index caae662..92166b5 100644
--- a/net/sunrpc/svcauth_unix.c
+++ b/net/sunrpc/svcauth_unix.c
@@ -433,7 +433,7 @@ static int unix_gid_match(struct cache_head *corig, struct cache_head *cnew)
 {
 	struct unix_gid *orig = container_of(corig, struct unix_gid, h);
 	struct unix_gid *new = container_of(cnew, struct unix_gid, h);
-	return orig->uid == new->uid;
+	return uid_eq(orig->uid, new->uid);
 }
 static void unix_gid_init(struct cache_head *cnew, struct cache_head *citem)
 {
-- 
1.7.5.4
