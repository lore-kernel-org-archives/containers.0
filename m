From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 19/85] coda: Cache permisions in struct coda_inode_info
	in a kuid_t.
Date: Wed, 13 Feb 2013 09:51:08 -0800
Message-ID: <1360777934-5663-19-git-send-email-ebiederm@xmission.com>
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

- Change c_uid in struct coda_indoe_info from a vuid_t to a kuid_t.
- Initialize c_uid to GLOBAL_ROOT_UID instead of 0.
- Use uid_eq to compare cached kuids.

Cc: Jan Harkes <jaharkes-ETDLCGt7PQU3uPMLIKxrzw@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/coda/cache.c     |    4 ++--
 fs/coda/coda_fs_i.h |    2 +-
 fs/coda/inode.c     |    2 +-
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/coda/cache.c b/fs/coda/cache.c
index 958ae0e..1da168c 100644
--- a/fs/coda/cache.c
+++ b/fs/coda/cache.c
@@ -33,7 +33,7 @@ void coda_cache_enter(struct inode *inode, int mask)
 
 	spin_lock(&cii->c_lock);
 	cii->c_cached_epoch = atomic_read(&permission_epoch);
-	if (cii->c_uid != current_fsuid()) {
+	if (!uid_eq(cii->c_uid, current_fsuid())) {
 		cii->c_uid = current_fsuid();
                 cii->c_cached_perm = mask;
         } else
@@ -65,7 +65,7 @@ int coda_cache_check(struct inode *inode, int mask)
 	
 	spin_lock(&cii->c_lock);
 	hit = (mask & cii->c_cached_perm) == mask &&
-	    cii->c_uid == current_fsuid() &&
+	    uid_eq(cii->c_uid, current_fsuid()) &&
 	    cii->c_cached_epoch == atomic_read(&permission_epoch);
 	spin_unlock(&cii->c_lock);
 
diff --git a/fs/coda/coda_fs_i.h b/fs/coda/coda_fs_i.h
index b24fdfd..c640752 100644
--- a/fs/coda/coda_fs_i.h
+++ b/fs/coda/coda_fs_i.h
@@ -25,7 +25,7 @@ struct coda_inode_info {
 	u_short	           c_flags;     /* flags (see below) */
 	unsigned int	   c_mapcount;  /* nr of times this inode is mapped */
 	unsigned int	   c_cached_epoch; /* epoch for cached permissions */
-	vuid_t		   c_uid;	/* fsuid for cached permissions */
+	kuid_t		   c_uid;	/* fsuid for cached permissions */
 	unsigned int       c_cached_perm; /* cached access permissions */
 	spinlock_t	   c_lock;
 	struct inode	   vfs_inode;
diff --git a/fs/coda/inode.c b/fs/coda/inode.c
index 77bbaf4..cf674e9 100644
--- a/fs/coda/inode.c
+++ b/fs/coda/inode.c
@@ -49,7 +49,7 @@ static struct inode *coda_alloc_inode(struct super_block *sb)
 		return NULL;
 	memset(&ei->c_fid, 0, sizeof(struct CodaFid));
 	ei->c_flags = 0;
-	ei->c_uid = 0;
+	ei->c_uid = GLOBAL_ROOT_UID;
 	ei->c_cached_perm = 0;
 	spin_lock_init(&ei->c_lock);
 	return &ei->vfs_inode;
-- 
1.7.5.4
