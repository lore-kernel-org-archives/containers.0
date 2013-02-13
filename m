From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 84/85] cifs: Convert struct cifs_ses to use a kuid_t
	and a kgid_t
Date: Wed, 13 Feb 2013 09:52:13 -0800
Message-ID: <1360777934-5663-84-git-send-email-ebiederm__15633.1881451935$1360778967$gmane$org@xmission.com>
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
Cc: Steve French <smfrench-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Cc: Steve French <smfrench-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/cifs/cifs_spnego.c |    6 ++++--
 fs/cifs/cifsglob.h    |    4 ++--
 fs/cifs/connect.c     |    2 +-
 3 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/fs/cifs/cifs_spnego.c b/fs/cifs/cifs_spnego.c
index 086f381..10e7747 100644
--- a/fs/cifs/cifs_spnego.c
+++ b/fs/cifs/cifs_spnego.c
@@ -149,10 +149,12 @@ cifs_get_spnego_key(struct cifs_ses *sesInfo)
 		goto out;
 
 	dp = description + strlen(description);
-	sprintf(dp, ";uid=0x%x", sesInfo->linux_uid);
+	sprintf(dp, ";uid=0x%x",
+		from_kuid_munged(&init_user_ns, sesInfo->linux_uid));
 
 	dp = description + strlen(description);
-	sprintf(dp, ";creduid=0x%x", sesInfo->cred_uid);
+	sprintf(dp, ";creduid=0x%x",
+		from_kuid_munged(&init_user_ns, sesInfo->cred_uid));
 
 	if (sesInfo->user_name) {
 		dp = description + strlen(description);
diff --git a/fs/cifs/cifsglob.h b/fs/cifs/cifsglob.h
index e308e8b..aaef57b 100644
--- a/fs/cifs/cifsglob.h
+++ b/fs/cifs/cifsglob.h
@@ -702,8 +702,8 @@ struct cifs_ses {
 	char *serverNOS;	/* name of network operating system of server */
 	char *serverDomain;	/* security realm of server */
 	__u64 Suid;		/* remote smb uid  */
-	uid_t linux_uid;        /* overriding owner of files on the mount */
-	uid_t cred_uid;		/* owner of credentials */
+	kuid_t linux_uid;	/* overriding owner of files on the mount */
+	kuid_t cred_uid;	/* owner of credentials */
 	unsigned int capabilities;
 	char serverName[SERVER_NAME_LEN_WITH_NULL * 2];	/* BB make bigger for
 				TCP names - will ipv6 and sctp addresses fit? */
diff --git a/fs/cifs/connect.c b/fs/cifs/connect.c
index 01279b8..067b0e1 100644
--- a/fs/cifs/connect.c
+++ b/fs/cifs/connect.c
@@ -2271,7 +2271,7 @@ static int match_session(struct cifs_ses *ses, struct smb_vol *vol)
 {
 	switch (ses->server->secType) {
 	case Kerberos:
-		if (vol->cred_uid != ses->cred_uid)
+		if (!uid_eq(vol->cred_uid, ses->cred_uid))
 			return 0;
 		break;
 	default:
-- 
1.7.5.4
