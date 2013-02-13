From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 42/85] sunrpc: Use userns friendly constants.
Date: Wed, 13 Feb 2013 09:51:31 -0800
Message-ID: <1360777934-5663-42-git-send-email-ebiederm@xmission.com>
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

Instead of (uid_t)0 use GLOBAL_ROOT_UID.
Instead of (gid_t)0 use GLOBAL_ROOT_GID.
Instead of (uid_t)-1 use INVALID_UID
Instead of (gid_t)-1 use INVALID_GID.
Instead of NOGROUP use INVALID_GID.

Cc: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Cc: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 net/sunrpc/auth.c         |    4 ++--
 net/sunrpc/auth_generic.c |    4 ++--
 net/sunrpc/auth_unix.c    |    6 +++---
 net/sunrpc/svcauth_unix.c |    4 ++--
 4 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index b5c067b..4cd0ecf 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -519,8 +519,8 @@ rpcauth_bind_root_cred(struct rpc_task *task, int lookupflags)
 {
 	struct rpc_auth *auth = task->tk_client->cl_auth;
 	struct auth_cred acred = {
-		.uid = 0,
-		.gid = 0,
+		.uid = GLOBAL_ROOT_UID,
+		.gid = GLOBAL_ROOT_GID,
 	};
 
 	dprintk("RPC: %5u looking up %s cred\n",
diff --git a/net/sunrpc/auth_generic.c b/net/sunrpc/auth_generic.c
index 6ed6f20..9d2e0b0 100644
--- a/net/sunrpc/auth_generic.c
+++ b/net/sunrpc/auth_generic.c
@@ -18,8 +18,8 @@
 # define RPCDBG_FACILITY	RPCDBG_AUTH
 #endif
 
-#define RPC_MACHINE_CRED_USERID		((uid_t)0)
-#define RPC_MACHINE_CRED_GROUPID	((gid_t)0)
+#define RPC_MACHINE_CRED_USERID		GLOBAL_ROOT_UID
+#define RPC_MACHINE_CRED_GROUPID	GLOBAL_ROOT_GID
 
 struct generic_cred {
 	struct rpc_cred gc_base;
diff --git a/net/sunrpc/auth_unix.c b/net/sunrpc/auth_unix.c
index 52c5abd..2f86270 100644
--- a/net/sunrpc/auth_unix.c
+++ b/net/sunrpc/auth_unix.c
@@ -85,7 +85,7 @@ unx_create_cred(struct rpc_auth *auth, struct auth_cred *acred, int flags)
 		cred->uc_gids[i] = gid;
 	}
 	if (i < NFS_NGROUPS)
-		cred->uc_gids[i] = NOGROUP;
+		cred->uc_gids[i] = INVALID_GID;
 
 	return &cred->uc_base;
 }
@@ -137,7 +137,7 @@ unx_match(struct auth_cred *acred, struct rpc_cred *rcred, int flags)
 			return 0;
 	}
 	if (groups < NFS_NGROUPS &&
-	    cred->uc_gids[groups] != NOGROUP)
+	    cred->uc_gids[groups] != INVALID_GID)
 		return 0;
 	return 1;
 }
@@ -166,7 +166,7 @@ unx_marshal(struct rpc_task *task, __be32 *p)
 	*p++ = htonl((u32) cred->uc_uid);
 	*p++ = htonl((u32) cred->uc_gid);
 	hold = p++;
-	for (i = 0; i < 16 && cred->uc_gids[i] != (gid_t) NOGROUP; i++)
+	for (i = 0; i < 16 && cred->uc_gids[i] != INVALID_GID; i++)
 		*p++ = htonl((u32) cred->uc_gids[i]);
 	*hold = htonl(p - hold - 1);		/* gid array length */
 	*base = htonl((p - base - 1) << 2);	/* cred length */
diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
index 4d01292..c8cb5dc 100644
--- a/net/sunrpc/svcauth_unix.c
+++ b/net/sunrpc/svcauth_unix.c
@@ -750,8 +750,8 @@ svcauth_null_accept(struct svc_rqst *rqstp, __be32 *authp)
 	}
 
 	/* Signal that mapping to nobody uid/gid is required */
-	cred->cr_uid = (uid_t) -1;
-	cred->cr_gid = (gid_t) -1;
+	cred->cr_uid = INVALID_UID;
+	cred->cr_gid = INVALID_GID;
 	cred->cr_group_info = groups_alloc(0);
 	if (cred->cr_group_info == NULL)
 		return SVC_CLOSE; /* kmalloc failure - client must retry */
-- 
1.7.5.4
