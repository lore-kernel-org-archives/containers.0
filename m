From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 73/85] cifs: Override unmappable incoming uids and gids
Date: Wed, 13 Feb 2013 09:52:02 -0800
Message-ID: <1360777934-5663-73-git-send-email-ebiederm__25632.5739356273$1360779099$gmane$org@xmission.com>
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

The cifs protocol has a 64bit space for uids and gids, while linux
only supports a 32bit space today.  Instead of silently truncating
64bit cifs ids, replace cifs ids that do not fit in the 32bit linux
id space with the default uid and gids for the cifs mount.

Cc: Steve French <smfrench-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/cifs/inode.c |   22 +++++++++++++---------
 1 files changed, 13 insertions(+), 9 deletions(-)

diff --git a/fs/cifs/inode.c b/fs/cifs/inode.c
index ed6208f..d7ea2a6 100644
--- a/fs/cifs/inode.c
+++ b/fs/cifs/inode.c
@@ -244,15 +244,19 @@ cifs_unix_basic_to_fattr(struct cifs_fattr *fattr, FILE_UNIX_BASIC_INFO *info,
 		break;
 	}
 
-	if (cifs_sb->mnt_cifs_flags & CIFS_MOUNT_OVERR_UID)
-		fattr->cf_uid = cifs_sb->mnt_uid;
-	else
-		fattr->cf_uid = le64_to_cpu(info->Uid);
-
-	if (cifs_sb->mnt_cifs_flags & CIFS_MOUNT_OVERR_GID)
-		fattr->cf_gid = cifs_sb->mnt_gid;
-	else
-		fattr->cf_gid = le64_to_cpu(info->Gid);
+	fattr->cf_uid = cifs_sb->mnt_uid;
+	if (!(cifs_sb->mnt_cifs_flags & CIFS_MOUNT_OVERR_UID)) {
+		u64 id = le64_to_cpu(info->Uid);
+		if (id < ((uid_t)-1))
+			fattr->cf_uid = id;
+	}
+	
+	fattr->cf_gid = cifs_sb->mnt_gid;
+	if (!(cifs_sb->mnt_cifs_flags & CIFS_MOUNT_OVERR_GID)) {
+		u64 id = le64_to_cpu(info->Gid);
+		if (id < ((gid_t)-1))
+			fattr->cf_gid = id;
+	}
 
 	fattr->cf_nlink = le64_to_cpu(info->Nlinks);
 }
-- 
1.7.5.4
