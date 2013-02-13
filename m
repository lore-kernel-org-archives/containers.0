From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 38/85] gfs2: Convert uids and gids between dinodes and
	vfs inodes.
Date: Wed, 13 Feb 2013 09:51:27 -0800
Message-ID: <1360777934-5663-38-git-send-email-ebiederm@xmission.com>
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
Cc: Steven Whitehouse <swhiteho-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

When reading dinodes from the disk convert uids and gids
into kuids and kgids to store in vfs data structures.

When writing to dinodes to the disk convert kuids and kgids
in the in memory structures into plain uids and gids.

For now all on disk data structures are assumed to be
stored in the initial user namespace.

Cc: Steven Whitehouse <swhiteho-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/gfs2/glops.c |    4 ++--
 fs/gfs2/inode.c |    4 ++--
 fs/gfs2/super.c |    4 ++--
 3 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/fs/gfs2/glops.c b/fs/gfs2/glops.c
index 78d4184..444b650 100644
--- a/fs/gfs2/glops.c
+++ b/fs/gfs2/glops.c
@@ -322,8 +322,8 @@ static int gfs2_dinode_in(struct gfs2_inode *ip, const void *buf)
 		break;
 	};
 
-	ip->i_inode.i_uid = be32_to_cpu(str->di_uid);
-	ip->i_inode.i_gid = be32_to_cpu(str->di_gid);
+	i_uid_write(&ip->i_inode, be32_to_cpu(str->di_uid));
+	i_gid_write(&ip->i_inode, be32_to_cpu(str->di_gid));
 	gfs2_set_nlink(&ip->i_inode, be32_to_cpu(str->di_nlink));
 	i_size_write(&ip->i_inode, be64_to_cpu(str->di_size));
 	gfs2_set_inode_blocks(&ip->i_inode, be64_to_cpu(str->di_blocks));
diff --git a/fs/gfs2/inode.c b/fs/gfs2/inode.c
index bb7c754..b862d11 100644
--- a/fs/gfs2/inode.c
+++ b/fs/gfs2/inode.c
@@ -456,8 +456,8 @@ static void init_dinode(struct gfs2_inode *dip, struct gfs2_inode *ip,
 	di->di_num.no_formal_ino = cpu_to_be64(ip->i_no_formal_ino);
 	di->di_num.no_addr = cpu_to_be64(ip->i_no_addr);
 	di->di_mode = cpu_to_be32(ip->i_inode.i_mode);
-	di->di_uid = cpu_to_be32(ip->i_inode.i_uid);
-	di->di_gid = cpu_to_be32(ip->i_inode.i_gid);
+	di->di_uid = cpu_to_be32(i_uid_read(&ip->i_inode));
+	di->di_gid = cpu_to_be32(i_gid_read(&ip->i_inode));
 	di->di_nlink = 0;
 	di->di_size = cpu_to_be64(ip->i_inode.i_size);
 	di->di_blocks = cpu_to_be64(1);
diff --git a/fs/gfs2/super.c b/fs/gfs2/super.c
index 7cc5a60..a034253 100644
--- a/fs/gfs2/super.c
+++ b/fs/gfs2/super.c
@@ -721,8 +721,8 @@ void gfs2_dinode_out(const struct gfs2_inode *ip, void *buf)
 	str->di_num.no_addr = cpu_to_be64(ip->i_no_addr);
 	str->di_num.no_formal_ino = cpu_to_be64(ip->i_no_formal_ino);
 	str->di_mode = cpu_to_be32(ip->i_inode.i_mode);
-	str->di_uid = cpu_to_be32(ip->i_inode.i_uid);
-	str->di_gid = cpu_to_be32(ip->i_inode.i_gid);
+	str->di_uid = cpu_to_be32(i_uid_read(&ip->i_inode));
+	str->di_gid = cpu_to_be32(i_gid_read(&ip->i_inode));
 	str->di_nlink = cpu_to_be32(ip->i_inode.i_nlink);
 	str->di_size = cpu_to_be64(i_size_read(&ip->i_inode));
 	str->di_blocks = cpu_to_be64(gfs2_get_inode_blocks(&ip->i_inode));
-- 
1.7.5.4
