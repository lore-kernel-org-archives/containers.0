From: Tejun Heo <htejun@gmail.com>
Subject: [PATCH 01/14] sysfs: fix i_mutex locking in sysfs_get_dentry()
Date: Mon, 20 Aug 2007 21:36:29 +0900
Message-ID: <11876133893733-git-send-email-htejun@gmail.com>
References: <11876133893720-git-send-email-htejun@gmail.com>
Reply-To: Tejun Heo <htejun@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757235AbXHTMg5@vger.kernel.org>
In-Reply-To: <11876133893720-git-send-email-htejun@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: ebiederm@xmission.com, cornelia.huck@de.ibm.com, greg@kroah.com, linux-kernel@vger.kernel.org, satyam@infradead.org, stern@rowland.harvard.edu, containers@lists.osdl.org
Cc: Tejun Heo <htejun@gmail.com>
List-Id: containers.vger.kernel.org

lookup_one_len_kern() should be called with the parent's i_mutex
locked.  Fix it.

Spotted by Eric W. Biederman.

Signed-off-by: Tejun Heo <htejun@gmail.com>
Cc: Eric W. Biederman <ebiederm@xmission.com>
---
 fs/sysfs/dir.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/fs/sysfs/dir.c b/fs/sysfs/dir.c
index e4fd8a2..b33af5e 100644
--- a/fs/sysfs/dir.c
+++ b/fs/sysfs/dir.c
@@ -130,8 +130,10 @@ struct dentry *sysfs_get_dentry(struct sysfs_dirent *sd)
 
 		/* look it up */
 		parent_dentry = dentry;
+		mutex_lock(&parent_dentry->d_inode->i_mutex);
 		dentry = lookup_one_len_kern(cur->s_name, parent_dentry,
 					     strlen(cur->s_name));
+		mutex_unlock(&parent_dentry->d_inode->i_mutex);
 		dput(parent_dentry);
 
 		if (IS_ERR(dentry)) {
-- 
1.5.0.3
