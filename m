From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 6/6] proc: cleanup proc_flush_task()
Date: Tue, 6 Jan 2009 02:34:47 +0300
Message-ID: <20090105233447.GF3924@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755386AbZAEX35@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: ebiederm@xmission.com, viro@zeniv.linux.org.uk
Cc: linux-kernel@vger.kernel.org, containers@lists.osdl.org, sds@tycho.nsa.gov, jmorris@namei.org
List-Id: containers.vger.kernel.org

From f9485836e531dec10b15bf97e95dc20fa2d6914a Mon Sep 17 00:00:00 2001
From: Eric W. Biederman <ebiederm@xmission.com>
Date: Wed, 19 Nov 2008 05:16:17 +0300
Subject: [PATCH 6/6] proc: cleanup proc_flush_task()

- shrink_dcache_parent is guaranteed to only flush dcache entries
  from the specified superblock.  So the the insanely subtle
  PF_EXITING check designed to avoid flushing filesystems inodes
  that are not safe to call during exit is unecessary.

- The test to avoid excess flushing of dcache entries in proc
  got inverted and generally broken for threads, and frankly
  all it saved was a single d_hash_and_lookup so there was
  very little point to it.  So remove the check and keep
  the code stupid and correct.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 fs/proc/base.c |   11 +++--------
 1 files changed, 3 insertions(+), 8 deletions(-)

diff --git a/fs/proc/base.c b/fs/proc/base.c
index a4b7cac..e43a013 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -2600,15 +2600,11 @@ static void proc_flush_task_mnt(struct vfsmount *mnt, pid_t pid, pid_t tgid)
 	name.len = snprintf(buf, sizeof(buf), "%d", pid);
 	dentry = d_hash_and_lookup(mnt->mnt_root, &name);
 	if (dentry) {
-		if (!(current->flags & PF_EXITING))
-			shrink_dcache_parent(dentry);
+		shrink_dcache_parent(dentry);
 		d_drop(dentry);
 		dput(dentry);
 	}
 
-	if (tgid == 0)
-		goto out;
-
 	name.name = buf;
 	name.len = snprintf(buf, sizeof(buf), "%d", tgid);
 	leader = d_hash_and_lookup(mnt->mnt_root, &name);
@@ -2669,13 +2665,12 @@ void proc_flush_task(struct task_struct *task)
 	struct upid *upid;
 
 	pid = task_pid(task);
-	if (thread_group_leader(task))
-		tgid = task_tgid(task);
+	tgid = task_tgid(task);
 
 	for (i = 0; i <= pid->level; i++) {
 		upid = &pid->numbers[i];
 		proc_flush_task_mnt(upid->ns->proc_mnt, upid->nr,
-			tgid ? tgid->numbers[i].nr : 0);
+				    tgid->numbers[i].nr);
 	}
 
 	upid = &pid->numbers[pid->level];
-- 
1.5.6.5
