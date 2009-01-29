From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Subject: [RFC][PATCH] devpts: Must release s_umount on error
Date: Wed, 28 Jan 2009 22:33:30 -0800
Message-ID: <20090129063330.GB22898@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755845AbZA2Ghq@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>, hpa@zytor.com, hch@lst.de
Cc: serue@us.ibm.com, "David C. Hansen" <haveblue@us.ibm.com>, Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org, sukadev@us.ibm.com
List-Id: containers.vger.kernel.org


From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Date: Wed, 28 Jan 2009 16:57:12 -0800
Subject: [RFC][PATCH] devpts: Must release s_umount on error

We should drop the ->s_umount mutex if an error occurs after the
sget()/grab_super() call. This was introduced when adding support
for multiple instances of devpts and noticed during a code review/reorg.

Signed-off-by: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
---
 fs/devpts/inode.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/fs/devpts/inode.c b/fs/devpts/inode.c
index d008105..ad186b4 100644
--- a/fs/devpts/inode.c
+++ b/fs/devpts/inode.c
@@ -390,6 +390,7 @@ static int new_pts_mount(struct file_system_type *fs_type, int flags,
 
 fail:
 	dput(mnt->mnt_sb->s_root);
+	up_write(&mnt->mnt_sb->s_umount);
 	deactivate_super(mnt->mnt_sb);
 	return err;
 }
@@ -479,6 +480,7 @@ static int init_pts_mount(struct file_system_type *fs_type, int flags,
 	err = mknod_ptmx(mnt->mnt_sb);
 	if (err) {
 		dput(mnt->mnt_sb->s_root);
+		up_write(&mnt->mnt_sb->s_umount);
 		deactivate_super(mnt->mnt_sb);
 	}
 
-- 
1.5.2.5
