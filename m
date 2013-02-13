From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 49/85] sunrpc: Update svcgss xdr handle to
	rpsec_contect cache
Date: Wed, 13 Feb 2013 09:51:38 -0800
Message-ID: <1360777934-5663-49-git-send-email-ebiederm__3181.51234318993$1360778671$gmane$org@xmission.com>
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

For each received uid call make_kuid and validate the result.
For each received gid call make_kgid and validate the result.

Cc: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Cc: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 net/sunrpc/auth_gss/svcauth_gss.c |   18 +++++++++++++-----
 1 files changed, 13 insertions(+), 5 deletions(-)

diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index 73e9573..ecd1d58 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -418,6 +418,7 @@ static int rsc_parse(struct cache_detail *cd,
 {
 	/* contexthandle expiry [ uid gid N <n gids> mechname ...mechdata... ] */
 	char *buf = mesg;
+	int id;
 	int len, rv;
 	struct rsc rsci, *rscp = NULL;
 	time_t expiry;
@@ -444,7 +445,7 @@ static int rsc_parse(struct cache_detail *cd,
 		goto out;
 
 	/* uid, or NEGATIVE */
-	rv = get_int(&mesg, &rsci.cred.cr_uid);
+	rv = get_int(&mesg, &id);
 	if (rv == -EINVAL)
 		goto out;
 	if (rv == -ENOENT)
@@ -452,8 +453,16 @@ static int rsc_parse(struct cache_detail *cd,
 	else {
 		int N, i;
 
+		/* uid */
+		rsci.cred.cr_uid = make_kuid(&init_user_ns, id);
+		if (!uid_valid(rsci.cred.cr_uid))
+			goto out;
+
 		/* gid */
-		if (get_int(&mesg, &rsci.cred.cr_gid))
+		if (get_int(&mesg, &id))
+			goto out;
+		rsci.cred.cr_gid = make_kgid(&init_user_ns, id);
+		if (!gid_valid(rsci.cred.cr_gid))
 			goto out;
 
 		/* number of additional gid's */
@@ -467,11 +476,10 @@ static int rsc_parse(struct cache_detail *cd,
 		/* gid's */
 		status = -EINVAL;
 		for (i=0; i<N; i++) {
-			gid_t gid;
 			kgid_t kgid;
-			if (get_int(&mesg, &gid))
+			if (get_int(&mesg, &id))
 				goto out;
-			kgid = make_kgid(&init_user_ns, gid);
+			kgid = make_kgid(&init_user_ns, id);
 			if (!gid_valid(kgid))
 				goto out;
 			GROUP_AT(rsci.cred.cr_group_info, i) = kgid;
-- 
1.7.5.4
