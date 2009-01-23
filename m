From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] cgroup: Fix root_count when mount fails due to busy
	subsystem
Date: Fri, 23 Jan 2009 19:10:56 +0100
Message-ID: <20090123181056.GA31142@elte.hu>
References: <20090123004703.25103.29754.stgit@menage.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759789AbZAWSL6@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090123004703.25103.29754.stgit@menage.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Paul Menage <menage@google.com>
Cc: akpm@linux-foundation.org, serue@us.ibm.com, linux-kernel@vger.kernel.org, containers@lists.osdl.org
List-Id: containers.vger.kernel.org


* Paul Menage <menage@google.com> wrote:

> cgroup: Fix root_count when mount fails due to busy subsystem
> 
> root_count was being incremented in cgroup_get_sb() after all error 
> checking was complete, but decremented in cgroup_kill_sb(), which can be 
> called on a superblock that we gave up on due to an error.  This patch 
> changes cgroup_kill_sb() to only decrement root_count if the root was 
> previously linked into the list of roots.

i'm wondering, what happens in the buggy case: does cgroup_kill_sb() get 
called twice (if yes, why?), or do we call cgroup_kill_sb() on a not yet 
added sb and hence root_count has not been elevated yet? (if yes, which 
codepath does this?)

The error handling in cgroup_get_sb() definitely seems a bit twisted - 
find below a few error path and other cleanups.

Thanks,

	Ingo

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index c298310..28d1b67 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1025,18 +1026,12 @@ static int cgroup_get_sb(struct file_system_type *fs_type,
 		 * have some link structures left over
 		 */
 		ret = allocate_cg_links(css_set_count, &tmp_cg_links);
-		if (ret) {
-			mutex_unlock(&cgroup_mutex);
-			mutex_unlock(&inode->i_mutex);
-			goto drop_new_super;
-		}
+		if (ret)
+			goto drop_new_super_unlock;
 
 		ret = rebind_subsystems(root, root->subsys_bits);
-		if (ret == -EBUSY) {
-			mutex_unlock(&cgroup_mutex);
-			mutex_unlock(&inode->i_mutex);
+		if (ret == -EBUSY)
 			goto free_cg_links;
-		}
 
 		/* EBUSY should be the only error here */
 		BUG_ON(ret);
@@ -1075,18 +1070,24 @@ static int cgroup_get_sb(struct file_system_type *fs_type,
 
  free_cg_links:
 	free_cg_links(&tmp_cg_links);
+
+ drop_new_super_unlock:
+	mutex_unlock(&cgroup_mutex);
+	mutex_unlock(&inode->i_mutex);
  drop_new_super:
 	up_write(&sb->s_umount);
 	deactivate_super(sb);
+
 	return ret;
 }
 
-static void cgroup_kill_sb(struct super_block *sb) {
+static void cgroup_kill_sb(struct super_block *sb)
+{
 	struct cgroupfs_root *root = sb->s_fs_info;
 	struct cgroup *cgrp = &root->top_cgroup;
-	int ret;
-	struct cg_cgroup_link *link;
 	struct cg_cgroup_link *saved_link;
+	struct cg_cgroup_link *link;
+	int ret;
 
 	BUG_ON(!root);
 
