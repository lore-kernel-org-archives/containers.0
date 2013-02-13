From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 45/85] sunrpc: Simplify auth_unix now that everything
	is a kgid_t
Date: Wed, 13 Feb 2013 09:51:34 -0800
Message-ID: <1360777934-5663-45-git-send-email-ebiederm__37209.2629354031$1360778761$gmane$org@xmission.com>
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

In unx_create_cred directly assign gids from acred->group_info
to cred->uc_gids.

In unx_match directly compare uc_gids with group_info.

Now that both group_info and unx_cred gids are stored as kgids
this is valid and the extra layer of translation can be removed.

Cc: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Cc: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 net/sunrpc/auth_unix.c |   14 ++++----------
 1 files changed, 4 insertions(+), 10 deletions(-)

diff --git a/net/sunrpc/auth_unix.c b/net/sunrpc/auth_unix.c
index 8365a9c..9f38857 100644
--- a/net/sunrpc/auth_unix.c
+++ b/net/sunrpc/auth_unix.c
@@ -79,11 +79,8 @@ unx_create_cred(struct rpc_auth *auth, struct auth_cred *acred, int flags)
 		groups = NFS_NGROUPS;
 
 	cred->uc_gid = acred->gid;
-	for (i = 0; i < groups; i++) {
-		gid_t gid;
-		gid = from_kgid(&init_user_ns, GROUP_AT(acred->group_info, i));
-		cred->uc_gids[i] = gid;
-	}
+	for (i = 0; i < groups; i++)
+		cred->uc_gids[i] = GROUP_AT(acred->group_info, i);
 	if (i < NFS_NGROUPS)
 		cred->uc_gids[i] = INVALID_GID;
 
@@ -130,12 +127,9 @@ unx_match(struct auth_cred *acred, struct rpc_cred *rcred, int flags)
 		groups = acred->group_info->ngroups;
 	if (groups > NFS_NGROUPS)
 		groups = NFS_NGROUPS;
-	for (i = 0; i < groups ; i++) {
-		gid_t gid;
-		gid = from_kgid(&init_user_ns, GROUP_AT(acred->group_info, i));
-		if (cred->uc_gids[i] != gid)
+	for (i = 0; i < groups ; i++)
+		if (!gid_eq(cred->uc_gids[i], GROUP_AT(acred->group_info, i)))
 			return 0;
-	}
 	if (groups < NFS_NGROUPS &&
 	    cred->uc_gids[groups] != INVALID_GID)
 		return 0;
-- 
1.7.5.4
