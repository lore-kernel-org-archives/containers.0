From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 82/85] cifs: Modify struct smb_vol to use kuids and
	kgids
Date: Wed, 13 Feb 2013 09:52:11 -0800
Message-ID: <1360777934-5663-82-git-send-email-ebiederm__26900.0481967398$1360779099$gmane$org@xmission.com>
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

Add two helper functions get_option_uid and get_option_gid to handle
the work of parsing uid and gids paramaters from the command line and
making kuids and kgids out of them.

Cc: Steve French <smfrench-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/cifs/cifsglob.h |   10 +++++-----
 fs/cifs/connect.c  |   50 ++++++++++++++++++++++++++++++++++++++++----------
 2 files changed, 45 insertions(+), 15 deletions(-)

diff --git a/fs/cifs/cifsglob.h b/fs/cifs/cifsglob.h
index 04aa74e..e308e8b 100644
--- a/fs/cifs/cifsglob.h
+++ b/fs/cifs/cifsglob.h
@@ -399,11 +399,11 @@ struct smb_vol {
 	char *iocharset;  /* local code page for mapping to and from Unicode */
 	char source_rfc1001_name[RFC1001_NAME_LEN_WITH_NULL]; /* clnt nb name */
 	char target_rfc1001_name[RFC1001_NAME_LEN_WITH_NULL]; /* srvr nb name */
-	uid_t cred_uid;
-	uid_t linux_uid;
-	gid_t linux_gid;
-	uid_t backupuid;
-	gid_t backupgid;
+	kuid_t cred_uid;
+	kuid_t linux_uid;
+	kgid_t linux_gid;
+	kuid_t backupuid;
+	kgid_t backupgid;
 	umode_t file_mode;
 	umode_t dir_mode;
 	unsigned secFlg;
diff --git a/fs/cifs/connect.c b/fs/cifs/connect.c
index 5411694..9bd13a7 100644
--- a/fs/cifs/connect.c
+++ b/fs/cifs/connect.c
@@ -987,6 +987,41 @@ static int get_option_ul(substring_t args[], unsigned long *option)
 	return rc;
 }
 
+static int get_option_uid(substring_t args[], kuid_t *result)
+{
+	unsigned long value;
+	kuid_t uid;
+	int rc;
+
+	rc = get_option_ul(args, &value);
+	if (rc)
+		return rc;
+
+	uid = make_kuid(current_user_ns(), value);
+	if (!uid_valid(uid))
+		return -EINVAL;
+
+	*result = uid;
+	return 0;
+}
+
+static int get_option_gid(substring_t args[], kgid_t *result)
+{
+	unsigned long value;
+	kgid_t gid;
+	int rc;
+
+	rc = get_option_ul(args, &value);
+	if (rc)
+		return rc;
+
+	gid = make_kgid(current_user_ns(), value);
+	if (!gid_valid(gid))
+		return -EINVAL;
+
+	*result = gid;
+	return 0;
+}
 
 static int cifs_parse_security_flavors(char *value,
 				       struct smb_vol *vol)
@@ -1424,47 +1459,42 @@ cifs_parse_mount_options(const char *mountdata, const char *devname,
 
 		/* Numeric Values */
 		case Opt_backupuid:
-			if (get_option_ul(args, &option)) {
+			if (get_option_uid(args, &vol->backupuid)) {
 				cERROR(1, "%s: Invalid backupuid value",
 					__func__);
 				goto cifs_parse_mount_err;
 			}
-			vol->backupuid = option;
 			vol->backupuid_specified = true;
 			break;
 		case Opt_backupgid:
-			if (get_option_ul(args, &option)) {
+			if (get_option_gid(args, &vol->backupgid)) {
 				cERROR(1, "%s: Invalid backupgid value",
 					__func__);
 				goto cifs_parse_mount_err;
 			}
-			vol->backupgid = option;
 			vol->backupgid_specified = true;
 			break;
 		case Opt_uid:
-			if (get_option_ul(args, &option)) {
+			if (get_option_uid(args, &vol->linux_uid)) {
 				cERROR(1, "%s: Invalid uid value",
 					__func__);
 				goto cifs_parse_mount_err;
 			}
-			vol->linux_uid = option;
 			uid_specified = true;
 			break;
 		case Opt_cruid:
-			if (get_option_ul(args, &option)) {
+			if (get_option_uid(args, &vol->cred_uid)) {
 				cERROR(1, "%s: Invalid cruid value",
 					__func__);
 				goto cifs_parse_mount_err;
 			}
-			vol->cred_uid = option;
 			break;
 		case Opt_gid:
-			if (get_option_ul(args, &option)) {
+			if (get_option_gid(args, &vol->linux_gid)) {
 				cERROR(1, "%s: Invalid gid value",
 						__func__);
 				goto cifs_parse_mount_err;
 			}
-			vol->linux_gid = option;
 			gid_specified = true;
 			break;
 		case Opt_file_mode:
-- 
1.7.5.4
