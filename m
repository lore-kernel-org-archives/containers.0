From: anqin <anqin.qin@gmail.com>
Subject: [RFC] [PATCH] cgroup: accounting and limitation of disk quota
Date: Sun, 22 Feb 2009 20:37:46 +0800
Message-ID: <d95d44a20902220437m2fb7af08y8c71fe275fe06a57@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755744AbZBVMiD@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Daniel Lezcano <dlezcano@fr.ibm.com>, "Serge E. Hallyn" <serue@us.ibm.com>, Rolando Martins <rolando.martins@gmail.com>, menage@google.com
Cc: linux-kernel@vger.kernel.org, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

The patch presents a cgroup subsystem to control the usage of disk quota.

The subsystem for disk quota (disk_cgroup, to be brief) does accounting
of inode and block allocated by ext3/ext2 filesystem. Simarily as
filesystem quota, the disk_cgroup can do limitation but without needing
to open filesytem quota options (e.g. usrquota,grpquota in /etc/fstab).

The simple usage of disk_cgroup is as follows:

# mount -t cgroup cgroup /mnt/cgrp
# lxc-execute -n lxc-template.conf /bin/bash
# ls /mnt/cgrp/11457/           // <--  11457 is the pid of bash
...
disk.stat
disk.usage_in_inode
disk.usage_in_block
disk.max_usage_in_inode
disk.max_usage_in_block
disk.limit_in_inode
disk.limit_in_inode
...

# echo  3 > /mnt/cgrp/11457/disk.max_usage_in_block

# touch /tmp/mytestfile1
# touch /tmp/mytestfile2
# touch /tmp/mytestfile3
# touch /tmp/mytestfile4
touch: cannot touch `/tmp/mytestfile4': Disk quota exceeded

The disk_cgroup is easily extended to manage complex objects
of filesystem.


Signed-off-by: An Qin <anqin.qin@gmail.com>

---
diff -uprN -X linux-2.6.28.5/Documentation/dontdiff
linux-2.6.28.5/fs/ext2/balloc.c
linux-2.6.28.5-cgroup-disk-quota/fs/ext2/balloc.c
--- linux-2.6.28.5/fs/ext2/balloc.c	2009-02-13 01:51:15.000000000 +0800
+++ linux-2.6.28.5-cgroup-disk-quota/fs/ext2/balloc.c	2009-02-21
12:09:17.000000000 +0800
@@ -16,7 +16,7 @@
 #include <linux/sched.h>
 #include <linux/buffer_head.h>
 #include <linux/capability.h>
-
+#include <linux/cgroup_disk.h>
 /*
  * balloc.c contains the blocks allocation and deallocation routines
  */
@@ -571,6 +571,8 @@ error_return:
 	brelse(bitmap_bh);
 	release_blocks(sb, freed);
 	DQUOT_FREE_BLOCK(inode, freed);
+        disk_cgroup_acct_quota(DISK_CURRENT_BLOCK,0,
+                freed << inode->i_sb->s_blocksize_bits);
 }

 /**
@@ -1247,11 +1249,15 @@ ext2_fsblk_t ext2_new_blocks(struct inod
 	/*
 	 * Check quota for allocation of this block.
 	 */
-	if (DQUOT_ALLOC_BLOCK(inode, num)) {
+	if (DQUOT_ALLOC_BLOCK(inode, num)
+		|| disk_cgroup_check_quota(DISK_CURRENT_BLOCK,
+			num << inode->i_sb->s_blocksize_bits)) {
 		*errp = -EDQUOT;
 		return 0;
 	}

+        disk_cgroup_acct_quota(DISK_CURRENT_BLOCK,1,
+                  num << inode->i_sb->s_blocksize_bits);
 	sbi = EXT2_SB(sb);
 	es = EXT2_SB(sb)->s_es;
 	ext2_debug("goal=%lu.\n", goal);
@@ -1410,6 +1416,8 @@ allocated:
 	*errp = 0;
 	brelse(bitmap_bh);
 	DQUOT_FREE_BLOCK(inode, *count-num);
+        disk_cgroup_acct_quota(DISK_CURRENT_BLOCK,0,
+                 (*count-num) << inode->i_sb->s_blocksize_bits);
 	*count = num;
 	return ret_block;

@@ -1419,8 +1427,11 @@ out:
 	/*
 	 * Undo the block allocation
 	 */
-	if (!performed_allocation)
+	if (!performed_allocation) {
 		DQUOT_FREE_BLOCK(inode, *count);
+                disk_cgroup_acct_quota(DISK_CURRENT_BLOCK,0,
+                        (*count) << inode->i_sb->s_blocksize_bits);
+	}
 	brelse(bitmap_bh);
 	return 0;
 }
diff -uprN -X linux-2.6.28.5/Documentation/dontdiff
linux-2.6.28.5/fs/ext2/ialloc.c
linux-2.6.28.5-cgroup-disk-quota/fs/ext2/ialloc.c
--- linux-2.6.28.5/fs/ext2/ialloc.c	2009-02-13 01:51:15.000000000 +0800
+++ linux-2.6.28.5-cgroup-disk-quota/fs/ext2/ialloc.c	2009-02-19
06:50:51.000000000 +0800
@@ -17,6 +17,7 @@
 #include <linux/backing-dev.h>
 #include <linux/buffer_head.h>
 #include <linux/random.h>
+#include <linux/cgroup_disk.h>
 #include "ext2.h"
 #include "xattr.h"
 #include "acl.h"
@@ -123,6 +124,7 @@ void ext2_free_inode (struct inode * ino
 		ext2_xattr_delete_inode(inode);
 	    	DQUOT_FREE_INODE(inode);
 		DQUOT_DROP(inode);
+		disk_cgroup_acct_quota(DISK_CURRENT_INODE,0,1);
 	}

 	es = EXT2_SB(sb)->s_es;
@@ -587,11 +589,12 @@ got:
 	spin_unlock(&sbi->s_next_gen_lock);
 	insert_inode_hash(inode);

-	if (DQUOT_ALLOC_INODE(inode)) {
+	if (DQUOT_ALLOC_INODE(inode) ||
disk_cgroup_check_quota(DISK_CURRENT_INODE,1)) {
 		err = -EDQUOT;
 		goto fail_drop;
 	}

+	disk_cgroup_acct_quota(DISK_CURRENT_INODE,1,1);
 	err = ext2_init_acl(inode, dir);
 	if (err)
 		goto fail_free_drop;
@@ -607,9 +610,11 @@ got:

 fail_free_drop:
 	DQUOT_FREE_INODE(inode);
+	disk_cgroup_acct_quota(DISK_CURRENT_INODE,0,1);

 fail_drop:
 	DQUOT_DROP(inode);
+	disk_cgroup_acct_quota(DISK_CURRENT_INODE,0,1);
 	inode->i_flags |= S_NOQUOTA;
 	inode->i_nlink = 0;
 	iput(inode);
diff -uprN -X linux-2.6.28.5/Documentation/dontdiff
linux-2.6.28.5/fs/ext2/xattr.c
linux-2.6.28.5-cgroup-disk-quota/fs/ext2/xattr.c
--- linux-2.6.28.5/fs/ext2/xattr.c	2009-02-13 01:51:15.000000000 +0800
+++ linux-2.6.28.5-cgroup-disk-quota/fs/ext2/xattr.c	2009-02-19
06:50:51.000000000 +0800
@@ -60,6 +60,7 @@
 #include <linux/mbcache.h>
 #include <linux/quotaops.h>
 #include <linux/rwsem.h>
+#include <linux/cgroup_disk.h>
 #include "ext2.h"
 #include "xattr.h"
 #include "acl.h"
@@ -640,12 +641,17 @@ ext2_xattr_set2(struct inode *inode, str
 				/* The old block is released after updating
 				   the inode.  */
 				ea_bdebug(new_bh, "reusing block");
-
 				error = -EDQUOT;
-				if (DQUOT_ALLOC_BLOCK(inode, 1)) {
+				if (DQUOT_ALLOC_BLOCK(inode, 1)
+					||disk_cgroup_check_quota(DISK_CURRENT_BLOCK,
+						1 << inode->i_sb->s_blocksize_bits)) {
 					unlock_buffer(new_bh);
 					goto cleanup;
 				}
+
+                                disk_cgroup_acct_quota(DISK_CURRENT_BLOCK,1,
+                                        1 << inode->i_sb->s_blocksize_bits);
+
 				le32_add_cpu(&HDR(new_bh)->h_refcount, 1);
 				ea_bdebug(new_bh, "refcount now=%d",
 					le32_to_cpu(HDR(new_bh)->h_refcount));
@@ -698,8 +704,11 @@ ext2_xattr_set2(struct inode *inode, str
 		 * written (only some dirty data were not) so we just proceed
 		 * as if nothing happened and cleanup the unused block */
 		if (error && error != -ENOSPC) {
-			if (new_bh && new_bh != old_bh)
+			if (new_bh && new_bh != old_bh) {
 				DQUOT_FREE_BLOCK(inode, 1);
+		                disk_cgroup_acct_quota(DISK_CURRENT_BLOCK,0,
+                		        1 << inode->i_sb->s_blocksize_bits);
+			}
 			goto cleanup;
 		}
 	} else
@@ -732,6 +741,8 @@ ext2_xattr_set2(struct inode *inode, str
 			if (ce)
 				mb_cache_entry_release(ce);
 			DQUOT_FREE_BLOCK(inode, 1);
+	                disk_cgroup_acct_quota(DISK_CURRENT_BLOCK,0,
+        	                1 << inode->i_sb->s_blocksize_bits);
 			mark_buffer_dirty(old_bh);
 			ea_bdebug(old_bh, "refcount now=%d",
 				le32_to_cpu(HDR(old_bh)->h_refcount));
diff -uprN -X linux-2.6.28.5/Documentation/dontdiff
linux-2.6.28.5/fs/ext3/balloc.c
linux-2.6.28.5-cgroup-disk-quota/fs/ext3/balloc.c
--- linux-2.6.28.5/fs/ext3/balloc.c	2009-02-13 01:51:15.000000000 +0800
+++ linux-2.6.28.5-cgroup-disk-quota/fs/ext3/balloc.c	2009-02-21
12:27:44.000000000 +0800
@@ -20,6 +20,8 @@
 #include <linux/quotaops.h>
 #include <linux/buffer_head.h>

+#include <linux/cgroup_disk.h>
+
 /*
  * balloc.c contains the blocks allocation and deallocation routines
  */
@@ -675,8 +677,11 @@ void ext3_free_blocks(handle_t *handle,
 		return;
 	}
 	ext3_free_blocks_sb(handle, sb, block, count, &dquot_freed_blocks);
-	if (dquot_freed_blocks)
+	if (dquot_freed_blocks) {
 		DQUOT_FREE_BLOCK(inode, dquot_freed_blocks);
+	        disk_cgroup_acct_quota(DISK_CURRENT_BLOCK,0,
+		dquot_freed_blocks << inode->i_sb->s_blocksize_bits);
+	}
 	return;
 }

@@ -1502,10 +1507,14 @@ ext3_fsblk_t ext3_new_blocks(handle_t *h
 	/*
 	 * Check quota for allocation of this block.
 	 */
-	if (DQUOT_ALLOC_BLOCK(inode, num)) {
+	if (DQUOT_ALLOC_BLOCK(inode, num)
+		|| disk_cgroup_check_quota(DISK_CURRENT_BLOCK,
+			num << inode->i_sb->s_blocksize_bits)) {
 		*errp = -EDQUOT;
 		return 0;
 	}
+	
+	disk_cgroup_acct_quota(DISK_CURRENT_BLOCK,1,num <<
inode->i_sb->s_blocksize_bits);

 	sbi = EXT3_SB(sb);
 	es = EXT3_SB(sb)->s_es;
@@ -1715,6 +1724,8 @@ allocated:
 	*errp = 0;
 	brelse(bitmap_bh);
 	DQUOT_FREE_BLOCK(inode, *count-num);
+	disk_cgroup_acct_quota(DISK_CURRENT_BLOCK,0,
+		(*count-num) << inode->i_sb->s_blocksize_bits);
 	*count = num;
 	return ret_block;

@@ -1728,8 +1739,11 @@ out:
 	/*
 	 * Undo the block allocation
 	 */
-	if (!performed_allocation)
+	if (!performed_allocation) {
 		DQUOT_FREE_BLOCK(inode, *count);
+		disk_cgroup_acct_quota(DISK_CURRENT_BLOCK,0,
+			(*count) << inode->i_sb->s_blocksize_bits);
+	}
 	brelse(bitmap_bh);
 	return 0;
 }
diff -uprN -X linux-2.6.28.5/Documentation/dontdiff
linux-2.6.28.5/fs/ext3/ialloc.c
linux-2.6.28.5-cgroup-disk-quota/fs/ext3/ialloc.c
--- linux-2.6.28.5/fs/ext3/ialloc.c	2009-02-13 01:51:15.000000000 +0800
+++ linux-2.6.28.5-cgroup-disk-quota/fs/ext3/ialloc.c	2009-02-19
06:51:05.000000000 +0800
@@ -25,6 +25,7 @@
 #include <linux/bitops.h>

 #include <asm/byteorder.h>
+#include <linux/cgroup_disk.h>

 #include "xattr.h"
 #include "acl.h"
@@ -126,6 +127,7 @@ void ext3_free_inode (handle_t *handle,
 	DQUOT_INIT(inode);
 	ext3_xattr_delete_inode(handle, inode);
 	DQUOT_FREE_INODE(inode);
+	disk_cgroup_acct_quota(DISK_CURRENT_INODE,0,1);
 	DQUOT_DROP(inode);

 	is_directory = S_ISDIR(inode->i_mode);
@@ -590,11 +592,13 @@ got:
 		sizeof(struct ext3_inode) - EXT3_GOOD_OLD_INODE_SIZE : 0;

 	ret = inode;
-	if(DQUOT_ALLOC_INODE(inode)) {
+	if(DQUOT_ALLOC_INODE(inode) ||
disk_cgroup_check_quota(DISK_CURRENT_INODE,1)) {
 		err = -EDQUOT;
 		goto fail_drop;
 	}

+	disk_cgroup_acct_quota(DISK_CURRENT_INODE,1,1);
+
 	err = ext3_init_acl(handle, inode, dir);
 	if (err)
 		goto fail_free_drop;
@@ -622,6 +626,7 @@ really_out:

 fail_free_drop:
 	DQUOT_FREE_INODE(inode);
+	disk_cgroup_acct_quota(DISK_CURRENT_INODE,0,1);

 fail_drop:
 	DQUOT_DROP(inode);
diff -uprN -X linux-2.6.28.5/Documentation/dontdiff
linux-2.6.28.5/fs/ext3/xattr.c
linux-2.6.28.5-cgroup-disk-quota/fs/ext3/xattr.c
--- linux-2.6.28.5/fs/ext3/xattr.c	2009-02-13 01:51:15.000000000 +0800
+++ linux-2.6.28.5-cgroup-disk-quota/fs/ext3/xattr.c	2009-02-19
06:51:06.000000000 +0800
@@ -58,6 +58,7 @@
 #include <linux/mbcache.h>
 #include <linux/quotaops.h>
 #include <linux/rwsem.h>
+#include <linux/cgroup_disk.h>
 #include "xattr.h"
 #include "acl.h"

@@ -499,6 +500,8 @@ ext3_xattr_release_block(handle_t *handl
 		if (IS_SYNC(inode))
 			handle->h_sync = 1;
 		DQUOT_FREE_BLOCK(inode, 1);
+		disk_cgroup_acct_quota(DISK_CURRENT_BLOCK,0,
+			1 << inode->i_sb->s_blocksize_bits);
 		ea_bdebug(bh, "refcount now=%d; releasing",
 			  le32_to_cpu(BHDR(bh)->h_refcount));
 		if (ce)
@@ -773,9 +776,16 @@ inserted:
 			else {
 				/* The old block is released after updating
 				   the inode. */
+
 				error = -EDQUOT;
-				if (DQUOT_ALLOC_BLOCK(inode, 1))
+				if (DQUOT_ALLOC_BLOCK(inode, 1)
+					|| disk_cgroup_check_quota(DISK_CURRENT_BLOCK,
+					1 << inode->i_sb->s_blocksize_bits))
 					goto cleanup;
+
+                                disk_cgroup_acct_quota(DISK_CURRENT_BLOCK,1,
+                                        1 << inode->i_sb->s_blocksize_bits);
+
 				error = ext3_journal_get_write_access(handle,
 								      new_bh);
 				if (error)
@@ -849,6 +859,9 @@ cleanup:

 cleanup_dquot:
 	DQUOT_FREE_BLOCK(inode, 1);
+        disk_cgroup_acct_quota(DISK_CURRENT_BLOCK,0,
+                 1 << inode->i_sb->s_blocksize_bits);
+
 	goto cleanup;

 bad_block:
diff -uprN -X linux-2.6.28.5/Documentation/dontdiff
linux-2.6.28.5/include/linux/cgroup_disk.h
linux-2.6.28.5-cgroup-disk-quota/include/linux/cgroup_disk.h
--- linux-2.6.28.5/include/linux/cgroup_disk.h	1970-01-01
08:00:00.000000000 +0800
+++ linux-2.6.28.5-cgroup-disk-quota/include/linux/cgroup_disk.h	2009-02-21
11:57:57.000000000 +0800
@@ -0,0 +1,28 @@
+#ifndef CGROUP_DISK_H
+#define	CGROUP_DISK_H
+
+#include <linux/quota.h>
+
+enum {
+	DISK_MAX_USAGE_BLOCK,
+	DISK_CURRENT_BLOCK,
+	DISK_LIMIT_BLOCK,
+
+	DISK_MAX_USAGE_INODE,
+	DISK_CURRENT_INODE,
+	DISK_LIMIT_INODE,
+
+	DISK_USAGE_STAT,
+};
+
+#ifdef CONFIG_CGROUP_DISK
+extern void disk_cgroup_acct_stat(struct dqstats *pstat);
+extern void disk_cgroup_acct_quota(int dq_type, int inc, unsigned
long long number);
+extern int disk_cgroup_check_quota(int dq_type, unsigned long long number);
+#else
+static inline void disk_cgroup_acct_stat(struct dqstats *pstat) { }
+static inline void disk_cgroup_acct_quota(int dq_type, int inc,
unsigned long long number) { }
+static inline int disk_cgroup_check_quota(int dq_type, unsigned long
long number) { }
+#endif /* CONFIG_CGROUP_DISK */
+
+#endif
diff -uprN -X linux-2.6.28.5/Documentation/dontdiff
linux-2.6.28.5/include/linux/cgroup_subsys.h
linux-2.6.28.5-cgroup-disk-quota/include/linux/cgroup_subsys.h
--- linux-2.6.28.5/include/linux/cgroup_subsys.h	2009-02-13
01:51:15.000000000 +0800
+++ linux-2.6.28.5-cgroup-disk-quota/include/linux/cgroup_subsys.h	2009-02-19
06:48:52.000000000 +0800
@@ -53,4 +53,8 @@ SUBSYS(devices)
 SUBSYS(freezer)
 #endif

+#ifdef CONFIG_CGROUP_DISK
+SUBSYS(disk_cgroup)
+#endif
+
 /* */
diff -uprN -X linux-2.6.28.5/Documentation/dontdiff
linux-2.6.28.5/init/Kconfig
linux-2.6.28.5-cgroup-disk-quota/init/Kconfig
--- linux-2.6.28.5/init/Kconfig	2009-02-13 01:51:15.000000000 +0800
+++ linux-2.6.28.5-cgroup-disk-quota/init/Kconfig	2009-02-19
06:50:43.000000000 +0800
@@ -313,6 +313,16 @@ config CGROUP_DEVICE
 	  Provides a cgroup implementing whitelists for devices which
 	  a process in the cgroup can mknod or open.

+
+config CGROUP_DISK
+        bool "Enable cgroup disk quota limitinig (EXPERIMENTAL)"
+        depends on EXPERIMENTAL && CGROUPS
+        help
+          This allows to define disk quota limiting/shaping rules for
+          specific cgroup(s).
+
+          Say N if unsure.
+
 config CPUSETS
 	bool "Cpuset support"
 	depends on SMP && CGROUPS
diff -uprN -X linux-2.6.28.5/Documentation/dontdiff
linux-2.6.28.5/kernel/cgroup_disk.c
linux-2.6.28.5-cgroup-disk-quota/kernel/cgroup_disk.c
--- linux-2.6.28.5/kernel/cgroup_disk.c	1970-01-01 08:00:00.000000000 +0800
+++ linux-2.6.28.5-cgroup-disk-quota/kernel/cgroup_disk.c	2009-02-21
11:48:17.000000000 +0800
@@ -0,0 +1,375 @@
+/*
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public
+ * License as published by the Free Software Foundation; either
+ * version 2 of the License, or (at your option) any later version.
+ *
+ * Writen by An Qin <anqin.qin@gmail.com>
+ */
+
+
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/cgroup.h>
+#include <linux/slab.h>
+#include <linux/gfp.h>
+#include <linux/err.h>
+#include <linux/sched.h>
+#include <linux/fs.h>
+#include <linux/jiffies.h>
+#include <linux/spinlock.h>
+#include <linux/quota.h>
+
+#include <linux/cgroup_disk.h>
+
+
+struct disk_cgroup_stat
+{
+        int lookups;
+        int drops;
+        int reads;
+        int writes;
+        int cache_hits;
+        int allocated_dquots;
+        int free_dquots;
+        int syncs;
+};
+
+struct disk_cgroup_quota
+{
+        qsize_t dqb_bhardlimit;
+        qsize_t dqb_bsoftlimit;
+        qsize_t dqb_curspace;
+        qsize_t dqb_ihardlimit;
+        qsize_t dqb_isoftlimit;
+        qsize_t dqb_curinodes;
+        time_t dqb_btime;
+        time_t dqb_itime;
+};
+
+
+struct disk_cgroup
+{
+	struct cgroup_subsys_state css;
+	spinlock_t lock;
+	struct disk_cgroup_quota quota;
+	struct disk_cgroup_stat stat;
+};
+
+
+static inline struct disk_cgroup *cgroup_to_disk_cgroup(struct cgroup *cont)
+{
+	return container_of(cgroup_subsys_state(cont, disk_cgroup_subsys_id),
+			    struct disk_cgroup, css);
+}
+
+static inline struct disk_cgroup *task_to_disk_cgroup(struct task_struct *task)
+{
+	return container_of(task_subsys_state(task, disk_cgroup_subsys_id),
+			    struct disk_cgroup, css);
+}
+
+struct cgroup_subsys disk_cgroup_subsys;
+
+static struct cgroup_subsys_state *disk_cgroup_create(
+			struct cgroup_subsys *ss, struct cgroup *cont)
+{
+	struct disk_cgroup *disk;
+
+	if (!capable(CAP_SYS_ADMIN))
+		return ERR_PTR(-EPERM);
+
+	if (!cgroup_is_descendant(cont))
+		return ERR_PTR(-EPERM);
+	
+	disk = kzalloc(sizeof(struct disk_cgroup), GFP_KERNEL);
+	if (unlikely(!disk))
+		return ERR_PTR(-ENOMEM);
+
+	spin_lock_init(&disk->lock);
+
+	return &disk->css;
+}
+
+static void disk_cgroup_destroy(struct cgroup_subsys *ss, struct cgroup *cont)
+{
+	kfree(cgroup_to_disk_cgroup(cont));
+}
+
+
+static ssize_t disk_cgroup_read_stat(struct cgroup *cont, struct cftype *cft,
+			       struct file *file, char __user *buf,
+			       size_t nbytes, loff_t *ppos)
+{
+	ssize_t count, ret;
+        struct disk_cgroup_stat stat;
+	struct disk_cgroup *disk;
+	char *page;
+
+	page = (char *)__get_free_page(GFP_TEMPORARY);
+	if (!page)
+		return -ENOMEM;
+
+	cgroup_lock();
+	if (cgroup_is_removed(cont)) {
+		cgroup_unlock();
+		ret = -ENODEV;
+		goto out;
+	}
+
+	disk = cgroup_to_disk_cgroup(cont);
+	spin_lock_irq(&disk->lock);
+
+	/* may cause segment fault, pay attention */
+	memcpy(&stat,&(disk->stat),sizeof(stat));
+
+	spin_unlock_irq(&disk->lock);
+	cgroup_unlock();
+
+	/* print additional debugging stuff */
+	count = sprintf(page, 	"            type: %s\n"
+			      	"         lookups: %d\n"
+			      	"           drops: %d\n"
+			      	"           reads: %d\n"
+			      	"          writes: %d\n"
+				"      cache_hits: %d\n"
+				"allocated_dquots: %d\n"
+				"     free_dquots: %d\n"
+				"           syncs: %d\n",
+			      	cft->name,
+			      	stat.lookups, stat.drops, stat.reads,
+				stat.writes, stat.cache_hits,
+				stat.allocated_dquots, stat.free_dquots,
+				stat.syncs);
+
+	ret = simple_read_from_buffer(buf, nbytes, ppos, page, count);
+
+out:
+	free_page((unsigned long)page);
+	return ret;
+}
+
+static ssize_t disk_cgroup_read_quota(struct cgroup *cont, struct cftype *cft,
+                               struct file *file, char __user *buf,
+                               size_t nbytes, loff_t *ppos)
+{
+        ssize_t count, ret = 0;
+        struct disk_cgroup_quota quota;
+        struct disk_cgroup *disk;
+        char *page;
+
+        page = (char *)__get_free_page(GFP_TEMPORARY);
+        if (!page)
+                return -ENOMEM;
+
+        cgroup_lock();
+        if (cgroup_is_removed(cont)) {
+                cgroup_unlock();
+                ret = -ENODEV;
+                goto out;
+        }
+
+        disk = cgroup_to_disk_cgroup(cont);
+        spin_lock_irq(&disk->lock);
+        memcpy(&quota,&(disk->quota),sizeof(quota));
+        spin_unlock_irq(&disk->lock);
+        cgroup_unlock();
+
+	switch(cft->private) {
+		case DISK_CURRENT_BLOCK:
+                count = sprintf(page,   "current usage of block: %llu\n",
+					quota.dqb_curspace);
+		break;
+		case DISK_CURRENT_INODE:
+                count = sprintf(page,   "current usage of inode: %llu\n",
+                                        quota.dqb_curinodes);
+		break;
+		case DISK_MAX_USAGE_BLOCK:
+                count = sprintf(page,   "%llu\n",
+                                        quota.dqb_bhardlimit);
+		break;
+		case DISK_MAX_USAGE_INODE:
+                count = sprintf(page,   "%llu\n",
+                                        quota.dqb_ihardlimit);
+		break;
+		case DISK_LIMIT_BLOCK:
+                count = sprintf(page,   "%llu\n",
+                                        quota.dqb_bsoftlimit);
+		break;
+		case DISK_LIMIT_INODE:
+                count = sprintf(page,   "%llu\n",
+                                        quota.dqb_isoftlimit);
+                break;
+		default:
+			goto out;
+
+	}
+        ret = simple_read_from_buffer(buf, nbytes, ppos, page, count);
+
+out:
+        free_page((unsigned long)page);
+        return ret;
+}
+
+
+static int disk_cgroup_write_u64(struct cgroup *cont, struct cftype *cft,
+				 u64 val)
+{
+	struct disk_cgroup *disk;
+	int ret = 0;
+
+	cgroup_lock();
+	if (cgroup_is_removed(cont)) {
+		ret = -ENODEV;
+		goto out;
+	}
+
+	disk = cgroup_to_disk_cgroup(cont);
+
+	spin_lock_irq(&disk->lock);
+	switch(cft->private)
+	{
+		case DISK_MAX_USAGE_BLOCK:
+			disk->quota.dqb_bhardlimit = (unsigned long long) val;
+			break;
+		case DISK_MAX_USAGE_INODE:
+			disk->quota.dqb_ihardlimit = (unsigned long long) val;
+			break;
+		case DISK_LIMIT_BLOCK:
+			disk->quota.dqb_bsoftlimit = (unsigned long long) val;
+			break;
+		case DISK_LIMIT_INODE:
+			disk->quota.dqb_isoftlimit = (unsigned long long) val;
+			break;
+		default:
+			break;
+	}
+	spin_unlock_irq(&disk->lock);
+
+out:
+	cgroup_unlock();
+	return ret;
+}
+
+
+static struct cftype disk_cgroup_files[] = {
+	{
+		.name = "stat",
+		.read = disk_cgroup_read_stat,
+		.private = DISK_USAGE_STAT,
+	},
+        {
+                .name = "usage_in_block",
+                .read = disk_cgroup_read_quota,
+                .private = DISK_CURRENT_BLOCK,
+        },
+        {
+                .name = "usage_in_inode",
+                .read = disk_cgroup_read_quota,
+                .private = DISK_CURRENT_INODE,
+        },
+        {
+                .name = "max_usage_in_block",
+                .read = disk_cgroup_read_quota,
+                .write_u64 = disk_cgroup_write_u64,
+                .private = DISK_MAX_USAGE_BLOCK,
+        },
+        {
+                .name = "max_usage_in_inode",
+                .read = disk_cgroup_read_quota,
+                .write_u64 = disk_cgroup_write_u64,
+                .private = DISK_MAX_USAGE_INODE,
+        },
+        {
+                .name = "limit_in_block",
+                .read = disk_cgroup_read_quota,
+                .write_u64 = disk_cgroup_write_u64,
+                .private = DISK_LIMIT_BLOCK,
+        },
+        {
+                .name = "limit_in_inode",
+                .read = disk_cgroup_read_quota,
+                .write_u64 = disk_cgroup_write_u64,
+                .private = DISK_LIMIT_INODE,
+        },
+};
+
+static int disk_cgroup_populate(struct cgroup_subsys *ss, struct cgroup *cont)
+{
+	return cgroup_add_files(cont, ss, disk_cgroup_files,
ARRAY_SIZE(disk_cgroup_files));
+}
+
+struct cgroup_subsys disk_cgroup_subsys = {
+	.name = "disk",
+	.create = disk_cgroup_create,
+	.destroy = disk_cgroup_destroy,
+	.populate = disk_cgroup_populate,
+	.subsys_id = disk_cgroup_subsys_id,
+};
+
+void disk_cgroup_acct_stat(struct dqstats *pstat)
+{
+	struct disk_cgroup *disk;
+
+	disk = task_to_disk_cgroup(current);
+	if (!disk)
+		return;
+
+	disk->stat.lookups += pstat->lookups;
+	disk->stat.drops += pstat->drops;
+	disk->stat.reads += pstat->reads;
+	disk->stat.writes += pstat->writes;
+	disk->stat.cache_hits += pstat->cache_hits;
+	disk->stat.allocated_dquots += pstat->allocated_dquots;
+	disk->stat.free_dquots += pstat->free_dquots;
+	disk->stat.syncs += pstat->syncs;
+}
+EXPORT_SYMBOL(disk_cgroup_acct_stat);
+
+void disk_cgroup_acct_quota(int dq_type, int inc, unsigned long long number)
+{
+        struct disk_cgroup *disk;
+
+        disk = task_to_disk_cgroup(current);
+        if (!disk)
+                return;
+
+	if(dq_type == DISK_CURRENT_BLOCK ) {
+		if(inc)
+        		disk->quota.dqb_curspace += number;
+		else if(disk->quota.dqb_curspace > number)
+			disk->quota.dqb_curspace -= number;
+		else disk->quota.dqb_curspace = 0;
+	}
+	else if(dq_type == DISK_CURRENT_INODE) {
+		if(inc)
+			disk->quota.dqb_curinodes += number;
+		else if(disk->quota.dqb_curinodes > number)
+			disk->quota.dqb_curinodes -= number;
+		else disk->quota.dqb_curinodes = 0;
+	}
+}
+EXPORT_SYMBOL(disk_cgroup_acct_quota);
+
+int disk_cgroup_check_quota(int dq_type, unsigned long long number)
+{
+        struct disk_cgroup *disk;
+	int ret = 0;
+
+        disk = task_to_disk_cgroup(current);
+        if (!disk)
+                return ret;
+
+
+        if(dq_type == DISK_CURRENT_BLOCK
+		&& disk->quota.dqb_bhardlimit > 0
+		&& disk->quota.dqb_curspace + number > disk->quota.dqb_bhardlimit)
+        	ret = -1;
+        else if(dq_type == DISK_CURRENT_INODE
+                && disk->quota.dqb_ihardlimit > 0
+                && disk->quota.dqb_curinodes + number >
disk->quota.dqb_ihardlimit)
+                ret = -1;
+
+	return ret;
+}
+EXPORT_SYMBOL(disk_cgroup_check_quota);
diff -uprN -X linux-2.6.28.5/Documentation/dontdiff
linux-2.6.28.5/kernel/Makefile
linux-2.6.28.5-cgroup-disk-quota/kernel/Makefile
--- linux-2.6.28.5/kernel/Makefile	2009-02-13 01:51:15.000000000 +0800
+++ linux-2.6.28.5-cgroup-disk-quota/kernel/Makefile	2009-02-19
06:52:04.000000000 +0800
@@ -55,6 +55,7 @@ obj-$(CONFIG_COMPAT) += compat.o
 obj-$(CONFIG_CGROUPS) += cgroup.o
 obj-$(CONFIG_CGROUP_DEBUG) += cgroup_debug.o
 obj-$(CONFIG_CGROUP_FREEZER) += cgroup_freezer.o
+obj-$(CONFIG_CGROUP_FREEZER) += cgroup_disk.o
 obj-$(CONFIG_CPUSETS) += cpuset.o
 obj-$(CONFIG_CGROUP_NS) += ns_cgroup.o
 obj-$(CONFIG_UTS_NS) += utsname.o
