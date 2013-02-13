From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 18/85] coda: Restrict coda messages to the initial user
	namespace
Date: Wed, 13 Feb 2013 09:51:07 -0800
Message-ID: <1360777934-5663-18-git-send-email-ebiederm@xmission.com>
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
Cc: Jan Harkes <jaharkes-ETDLCGt7PQU3uPMLIKxrzw@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Remove the slight chance that uids and gids in coda messages will be
interpreted in the wrong user namespace.

- Only allow processes in the initial user namespace to open the coda
  character device to communicate with coda filesystems.
- Explicitly convert the uids in the coda header into the initial user
  namespace.
- In coda_vattr_to_attr make kuids and kgids from the initial user
  namespace uids and gids in struct coda_vattr that just came from
  userspace.
- In coda_iattr_to_vattr convert kuids and kgids into uids and gids
  in the intial user namespace and store them in struct coda_vattr for
  sending to coda userspace programs.

Nothing needs to be changed with mounts as coda does not support
being mounted in anything other than the initial user namespace.

Cc: Jan Harkes <jaharkes-ETDLCGt7PQU3uPMLIKxrzw@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/coda/coda_linux.c       |    8 ++++----
 fs/coda/psdev.c            |    3 +++
 fs/coda/upcall.c           |    6 +++---
 include/linux/coda_psdev.h |    2 +-
 4 files changed, 11 insertions(+), 8 deletions(-)

diff --git a/fs/coda/coda_linux.c b/fs/coda/coda_linux.c
index 854ace7..2849f41 100644
--- a/fs/coda/coda_linux.c
+++ b/fs/coda/coda_linux.c
@@ -100,9 +100,9 @@ void coda_vattr_to_iattr(struct inode *inode, struct coda_vattr *attr)
 	if (attr->va_mode != (u_short) -1)
 	        inode->i_mode = attr->va_mode | inode_type;
         if (attr->va_uid != -1) 
-	        inode->i_uid = (uid_t) attr->va_uid;
+	        inode->i_uid = make_kuid(&init_user_ns, (uid_t) attr->va_uid);
         if (attr->va_gid != -1)
-	        inode->i_gid = (gid_t) attr->va_gid;
+	        inode->i_gid = make_kgid(&init_user_ns, (gid_t) attr->va_gid);
 	if (attr->va_nlink != -1)
 		set_nlink(inode, attr->va_nlink);
 	if (attr->va_size != -1)
@@ -171,10 +171,10 @@ void coda_iattr_to_vattr(struct iattr *iattr, struct coda_vattr *vattr)
                 vattr->va_mode = iattr->ia_mode;
 	}
         if ( valid & ATTR_UID ) {
-                vattr->va_uid = (vuid_t) iattr->ia_uid;
+                vattr->va_uid = (vuid_t) from_kuid(&init_user_ns, iattr->ia_uid);
 	}
         if ( valid & ATTR_GID ) {
-                vattr->va_gid = (vgid_t) iattr->ia_gid;
+                vattr->va_gid = (vgid_t) from_kgid(&init_user_ns, iattr->ia_gid);
 	}
         if ( valid & ATTR_SIZE ) {
                 vattr->va_size = iattr->ia_size;
diff --git a/fs/coda/psdev.c b/fs/coda/psdev.c
index dd60f90..ebc2bae 100644
--- a/fs/coda/psdev.c
+++ b/fs/coda/psdev.c
@@ -270,6 +270,9 @@ static int coda_psdev_open(struct inode * inode, struct file * file)
 	if (task_active_pid_ns(current) != &init_pid_ns)
 		return -EINVAL;
 
+	if (current_user_ns() != &init_user_ns)
+		return -EINVAL;
+
 	idx = iminor(inode);
 	if (idx < 0 || idx >= MAX_CODADEVS)
 		return -ENODEV;
diff --git a/fs/coda/upcall.c b/fs/coda/upcall.c
index 5c6d2cd..3a73197 100644
--- a/fs/coda/upcall.c
+++ b/fs/coda/upcall.c
@@ -52,7 +52,7 @@ static void *alloc_upcall(int opcode, int size)
         inp->ih.opcode = opcode;
 	inp->ih.pid = task_pid_nr_ns(current, &init_pid_ns);
 	inp->ih.pgid = task_pgrp_nr_ns(current, &init_pid_ns);
-	inp->ih.uid = current_fsuid();
+	inp->ih.uid = from_kuid(&init_user_ns, current_fsuid());
 
 	return (void*)inp;
 }
@@ -157,7 +157,7 @@ int venus_lookup(struct super_block *sb, struct CodaFid *fid,
 }
 
 int venus_close(struct super_block *sb, struct CodaFid *fid, int flags,
-		vuid_t uid)
+		kuid_t uid)
 {
 	union inputArgs *inp;
 	union outputArgs *outp;
@@ -166,7 +166,7 @@ int venus_close(struct super_block *sb, struct CodaFid *fid, int flags,
 	insize = SIZE(release);
 	UPARG(CODA_CLOSE);
 	
-	inp->ih.uid = uid;
+	inp->ih.uid = from_kuid(&init_user_ns, uid);
         inp->coda_close.VFid = *fid;
         inp->coda_close.flags = flags;
 
diff --git a/include/linux/coda_psdev.h b/include/linux/coda_psdev.h
index 8031d6e..5b8721e 100644
--- a/include/linux/coda_psdev.h
+++ b/include/linux/coda_psdev.h
@@ -34,7 +34,7 @@ int venus_lookup(struct super_block *sb, struct CodaFid *fid,
 		 const char *name, int length, int *type, 
 		 struct CodaFid *resfid);
 int venus_close(struct super_block *sb, struct CodaFid *fid, int flags,
-		vuid_t uid);
+		kuid_t uid);
 int venus_open(struct super_block *sb, struct CodaFid *fid, int flags,
 	       struct file **f);
 int venus_mkdir(struct super_block *sb, struct CodaFid *dirfid, 
-- 
1.7.5.4
