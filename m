From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 46/85] sunrpc: Convert kuids and kgids to uids and gids
	for printing
Date: Wed, 13 Feb 2013 09:51:35 -0800
Message-ID: <1360777934-5663-46-git-send-email-ebiederm@xmission.com>
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

When printing kuids and kgids for debugging purpropses convert them
to ordinary integers so their values can be fed to the oridnary
print functions.

Cc: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Cc: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 net/sunrpc/auth_generic.c      |    4 +++-
 net/sunrpc/auth_gss/auth_gss.c |   13 ++++++++-----
 net/sunrpc/auth_unix.c         |    3 ++-
 3 files changed, 13 insertions(+), 7 deletions(-)

diff --git a/net/sunrpc/auth_generic.c b/net/sunrpc/auth_generic.c
index bff3e47..b6badaf 100644
--- a/net/sunrpc/auth_generic.c
+++ b/net/sunrpc/auth_generic.c
@@ -96,7 +96,9 @@ generic_create_cred(struct rpc_auth *auth, struct auth_cred *acred, int flags)
 
 	dprintk("RPC:       allocated %s cred %p for uid %d gid %d\n",
 			gcred->acred.machine_cred ? "machine" : "generic",
-			gcred, acred->uid, acred->gid);
+			gcred,
+			from_kuid(&init_user_ns, acred->uid),
+			from_kgid(&init_user_ns, acred->gid));
 	return &gcred->gc_base;
 }
 
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 1b8b3e4..afbbcfb 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -517,7 +517,7 @@ gss_refresh_upcall(struct rpc_task *task)
 	int err = 0;
 
 	dprintk("RPC: %5u %s for uid %u\n",
-		task->tk_pid, __func__, cred->cr_uid);
+		task->tk_pid, __func__, from_kuid(&init_user_ns, cred->cr_uid));
 	gss_msg = gss_setup_upcall(task->tk_client, gss_auth, cred);
 	if (PTR_ERR(gss_msg) == -EAGAIN) {
 		/* XXX: warning on the first, under the assumption we
@@ -549,7 +549,8 @@ gss_refresh_upcall(struct rpc_task *task)
 	gss_release_msg(gss_msg);
 out:
 	dprintk("RPC: %5u %s for uid %u result %d\n",
-		task->tk_pid, __func__, cred->cr_uid, err);
+		task->tk_pid, __func__,
+		from_kuid(&init_user_ns, cred->cr_uid),	err);
 	return err;
 }
 
@@ -562,7 +563,8 @@ gss_create_upcall(struct gss_auth *gss_auth, struct gss_cred *gss_cred)
 	DEFINE_WAIT(wait);
 	int err = 0;
 
-	dprintk("RPC:       %s for uid %u\n", __func__, cred->cr_uid);
+	dprintk("RPC:       %s for uid %u\n",
+		__func__, from_kuid(&init_user_ns, cred->cr_uid));
 retry:
 	gss_msg = gss_setup_upcall(gss_auth->client, gss_auth, cred);
 	if (PTR_ERR(gss_msg) == -EAGAIN) {
@@ -604,7 +606,7 @@ out_intr:
 	gss_release_msg(gss_msg);
 out:
 	dprintk("RPC:       %s for uid %u result %d\n",
-		__func__, cred->cr_uid, err);
+		__func__, from_kuid(&init_user_ns, cred->cr_uid), err);
 	return err;
 }
 
@@ -1059,7 +1061,8 @@ gss_create_cred(struct rpc_auth *auth, struct auth_cred *acred, int flags)
 	int err = -ENOMEM;
 
 	dprintk("RPC:       %s for uid %d, flavor %d\n",
-		__func__, acred->uid, auth->au_flavor);
+		__func__, from_kuid(&init_user_ns, acred->uid),
+		auth->au_flavor);
 
 	if (!(cred = kzalloc(sizeof(*cred), GFP_NOFS)))
 		goto out_err;
diff --git a/net/sunrpc/auth_unix.c b/net/sunrpc/auth_unix.c
index 9f38857..55b6ca6 100644
--- a/net/sunrpc/auth_unix.c
+++ b/net/sunrpc/auth_unix.c
@@ -65,7 +65,8 @@ unx_create_cred(struct rpc_auth *auth, struct auth_cred *acred, int flags)
 	unsigned int i;
 
 	dprintk("RPC:       allocating UNIX cred for uid %d gid %d\n",
-			acred->uid, acred->gid);
+			from_kuid(&init_user_ns, acred->uid),
+			from_kgid(&init_user_ns, acred->gid));
 
 	if (!(cred = kmalloc(sizeof(*cred), GFP_NOFS)))
 		return ERR_PTR(-ENOMEM);
-- 
1.7.5.4
