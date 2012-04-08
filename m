From: "\"Eric W. Beiderman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 41/43] userns: Convert tmpfs to use kuid and kgid where
	appropriate
Date: Sat,  7 Apr 2012 22:15:37 -0700
Message-ID: <1333862139-31737-41-git-send-email-ebiederm__49931.0013176457$1333862172$gmane$org@xmission.com>
References: <m11unyn70b.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m11unyn70b.fsf-+imSwln9KH6u2/kzUuoCbdi2O/JbrIOy@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Cyrill Gorcunov <gorcunov-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

From: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 include/linux/shmem_fs.h |    4 ++--
 mm/shmem.c               |   22 ++++++++++++++++------
 2 files changed, 18 insertions(+), 8 deletions(-)

diff --git a/include/linux/shmem_fs.h b/include/linux/shmem_fs.h
index 79ab255..bef2cf0 100644
--- a/include/linux/shmem_fs.h
+++ b/include/linux/shmem_fs.h
@@ -28,8 +28,8 @@ struct shmem_sb_info {
 	unsigned long max_inodes;   /* How many inodes are allowed */
 	unsigned long free_inodes;  /* How many are left for allocation */
 	spinlock_t stat_lock;	    /* Serialize shmem_sb_info changes */
-	uid_t uid;		    /* Mount uid for root directory */
-	gid_t gid;		    /* Mount gid for root directory */
+	kuid_t uid;		    /* Mount uid for root directory */
+	kgid_t gid;		    /* Mount gid for root directory */
 	umode_t mode;		    /* Mount mode for root directory */
 	struct mempolicy *mpol;     /* default memory policy for mappings */
 };
diff --git a/mm/shmem.c b/mm/shmem.c
index f99ff3e..d7b433a 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -2075,6 +2075,8 @@ static int shmem_parse_options(char *options, struct shmem_sb_info *sbinfo,
 			       bool remount)
 {
 	char *this_char, *value, *rest;
+	uid_t uid;
+	gid_t gid;
 
 	while (options != NULL) {
 		this_char = options;
@@ -2134,15 +2136,21 @@ static int shmem_parse_options(char *options, struct shmem_sb_info *sbinfo,
 		} else if (!strcmp(this_char,"uid")) {
 			if (remount)
 				continue;
-			sbinfo->uid = simple_strtoul(value, &rest, 0);
+			uid = simple_strtoul(value, &rest, 0);
 			if (*rest)
 				goto bad_val;
+			sbinfo->uid = make_kuid(current_user_ns(), uid);
+			if (!uid_valid(sbinfo->uid))
+				goto bad_val;
 		} else if (!strcmp(this_char,"gid")) {
 			if (remount)
 				continue;
-			sbinfo->gid = simple_strtoul(value, &rest, 0);
+			gid = simple_strtoul(value, &rest, 0);
 			if (*rest)
 				goto bad_val;
+			sbinfo->gid = make_kgid(current_user_ns(), gid);
+			if (!gid_valid(sbinfo->gid))
+				goto bad_val;
 		} else if (!strcmp(this_char,"mpol")) {
 			if (mpol_parse_str(value, &sbinfo->mpol, 1))
 				goto bad_val;
@@ -2210,10 +2218,12 @@ static int shmem_show_options(struct seq_file *seq, struct dentry *root)
 		seq_printf(seq, ",nr_inodes=%lu", sbinfo->max_inodes);
 	if (sbinfo->mode != (S_IRWXUGO | S_ISVTX))
 		seq_printf(seq, ",mode=%03ho", sbinfo->mode);
-	if (sbinfo->uid != 0)
-		seq_printf(seq, ",uid=%u", sbinfo->uid);
-	if (sbinfo->gid != 0)
-		seq_printf(seq, ",gid=%u", sbinfo->gid);
+	if (!uid_eq(sbinfo->uid, GLOBAL_ROOT_UID))
+		seq_printf(seq, ",uid=%u",
+				from_kuid_munged(&init_user_ns, sbinfo->uid));
+	if (!gid_eq(sbinfo->gid, GLOBAL_ROOT_GID))
+		seq_printf(seq, ",gid=%u",
+				from_kgid_munged(&init_user_ns, sbinfo->gid));
 	shmem_show_mpol(seq, sbinfo->mpol);
 	return 0;
 }
-- 
1.7.2.5
