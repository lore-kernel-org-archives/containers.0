From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 01/16] userns: Ignore suid and sgid on binaries if the
	uid or gid can not be mapped
Date: Mon, 19 Nov 2012 07:12:26 -0800
Message-ID: <1353337961-12962-1-git-send-email-ebiederm@xmission.com>
References: <87lidx8wbo.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87lidx8wbo.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

When performing an exec where the binary lives in one user namespace and
the execing process lives in another usre namespace there is the possibility
that the target uids can not be represented.

Instead of failing the exec simply ignore the suid/sgid bits and run
the binary with lower privileges.   We already do this in the case
of MNT_NOSUID so this should be a well tested code path.

As the user and group are not changed this should not introduce any
security issues.

Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/exec.c |    9 +++------
 1 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/fs/exec.c b/fs/exec.c
index 0039055..aef0c2f 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -1266,14 +1266,13 @@ int prepare_binprm(struct linux_binprm *bprm)
 	bprm->cred->egid = current_egid();
 
 	if (!(bprm->file->f_path.mnt->mnt_flags & MNT_NOSUID) &&
-	    !current->no_new_privs) {
+	    !current->no_new_privs &&
+	    kuid_has_mapping(bprm->cred->user_ns, inode->i_uid) &&
+	    kgid_has_mapping(bprm->cred->user_ns, inode->i_gid)) {
 		/* Set-uid? */
 		if (mode & S_ISUID) {
-			if (!kuid_has_mapping(bprm->cred->user_ns, inode->i_uid))
-				return -EPERM;
 			bprm->per_clear |= PER_CLEAR_ON_SETID;
 			bprm->cred->euid = inode->i_uid;
-
 		}
 
 		/* Set-gid? */
@@ -1283,8 +1282,6 @@ int prepare_binprm(struct linux_binprm *bprm)
 		 * executable.
 		 */
 		if ((mode & (S_ISGID | S_IXGRP)) == (S_ISGID | S_IXGRP)) {
-			if (!kgid_has_mapping(bprm->cred->user_ns, inode->i_gid))
-				return -EPERM;
 			bprm->per_clear |= PER_CLEAR_ON_SETID;
 			bprm->cred->egid = inode->i_gid;
 		}
-- 
1.7.5.4
