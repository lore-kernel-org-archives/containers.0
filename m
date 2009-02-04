From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Subject: [v2][PATCH 1/5] Unroll essentials of do_remount_sb() into devpts
Date: Tue, 3 Feb 2009 20:36:40 -0800
Message-ID: <20090204043640.GA26202@us.ibm.com>
References: <20090204043516.GB25963@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755134AbZBDElV@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090204043516.GB25963@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>, hpa@zytor.com, hch@lst.de
Cc: serue@us.ibm.com, sukadev@us.ibm.com, Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org


From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Date: Tue, 27 Jan 2009 22:58:18 -0800
Subject: [v2][PATCH 1/5] Unroll essentials of do_remount_sb() into devpts

On remount, devpts fs only needs to parse the mount options. Users cannot
directly create/dirty files in /dev/pts so the MS_RDONLY flag and
shrinking the dcache does not really apply to devpts.

So effectively on remount, devpts only parses the mount options and updates
these options in its super block. As such, we could replace do_remount_sb()
call with a direct parse_mount_options().

Doing so enables subsequent patches to avoid parsing the mount options twice
and simplify the code.

Signed-off-by: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
---
 fs/devpts/inode.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/fs/devpts/inode.c b/fs/devpts/inode.c
index ad186b4..de15e73 100644
--- a/fs/devpts/inode.c
+++ b/fs/devpts/inode.c
@@ -442,6 +442,8 @@ static int get_init_pts_sb(struct file_system_type *fs_type, int flags,
 		void *data, struct vfsmount *mnt)
 {
 	struct super_block *s;
+	struct pts_mount_opts *opts;
+	struct pts_fs_info *fsi;
 	int error;
 
 	s = sget(fs_type, compare_init_pts_sb, set_anon_super, NULL);
@@ -458,7 +460,10 @@ static int get_init_pts_sb(struct file_system_type *fs_type, int flags,
 		}
 		s->s_flags |= MS_ACTIVE;
 	}
-	do_remount_sb(s, flags, data, 0);
+	fsi = DEVPTS_SB(s);
+	opts = &fsi->mount_opts;
+	parse_mount_options(data, PARSE_REMOUNT, opts);
+
 	simple_set_mnt(mnt, s);
 	return 0;
 }
-- 
1.5.2.5
