From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 81/85] cifs: Convert struct cifsFileInfo to use a kuid
Date: Wed, 13 Feb 2013 09:52:10 -0800
Message-ID: <1360777934-5663-81-git-send-email-ebiederm@xmission.com>
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
 fs/cifs/cifsglob.h |    2 +-
 fs/cifs/file.c     |    4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/cifs/cifsglob.h b/fs/cifs/cifsglob.h
index 98312fd..04aa74e 100644
--- a/fs/cifs/cifsglob.h
+++ b/fs/cifs/cifsglob.h
@@ -930,7 +930,7 @@ struct cifsFileInfo {
 	struct list_head tlist;	/* pointer to next fid owned by tcon */
 	struct list_head flist;	/* next fid (file instance) for this inode */
 	struct cifs_fid_locks *llist;	/* brlocks held by this fid */
-	unsigned int uid;	/* allows finding which FileInfo structure */
+	kuid_t uid;		/* allows finding which FileInfo structure */
 	__u32 pid;		/* process id who opened file */
 	struct cifs_fid fid;	/* file id from remote */
 	/* BB add lock scope info here if needed */ ;
diff --git a/fs/cifs/file.c b/fs/cifs/file.c
index b9baf5f..c23fbd8 100644
--- a/fs/cifs/file.c
+++ b/fs/cifs/file.c
@@ -1649,7 +1649,7 @@ struct cifsFileInfo *find_readable_file(struct cifsInodeInfo *cifs_inode,
 	   are always at the end of the list but since the first entry might
 	   have a close pending, we go through the whole list */
 	list_for_each_entry(open_file, &cifs_inode->openFileList, flist) {
-		if (fsuid_only && open_file->uid != current_fsuid())
+		if (fsuid_only && !uid_eq(open_file->uid, current_fsuid()))
 			continue;
 		if (OPEN_FMODE(open_file->f_flags) & FMODE_READ) {
 			if (!open_file->invalidHandle) {
@@ -1702,7 +1702,7 @@ refind_writable:
 	list_for_each_entry(open_file, &cifs_inode->openFileList, flist) {
 		if (!any_available && open_file->pid != current->tgid)
 			continue;
-		if (fsuid_only && open_file->uid != current_fsuid())
+		if (fsuid_only && !uid_eq(open_file->uid, current_fsuid()))
 			continue;
 		if (OPEN_FMODE(open_file->f_flags) & FMODE_WRITE) {
 			if (!open_file->invalidHandle) {
-- 
1.7.5.4
