From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH] cgroup: superblock can't be released with active dentries
Date: Thu, 24 May 2012 08:41:39 -0700
Message-ID: <20120524154139.GA27983__5340.83077586747$1337874111$gmane$org@google.com>
References: <20120330223423.GJ28934@google.com>
	<20120330223606.GK28934@google.com> <4F77B6BA.4070207@huawei.com>
	<20120401185430.GA9230@dhcp-172-17-108-109.mtv.corp.google.com>
	<CA+1xoqe5hMuxzCRhMy7J0XchDk2ZnuxOHJKikROk1-ReAzcT6g@mail.gmail.com>
	<20120518175548.GM19388@google.com>
	<CA+1xoqfr5aaGbxoX3YKrJHXTjU9fWSbX_xbuEOU=4K7kMay6XQ@mail.gmail.com>
	<20120523222242.GD3933@htj.dyndns.org>
	<CA+1xoqdbtkC5Ue3s1qZHHJBLcj9a=djFDGny6AJJSV-pdn7mcA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CA+1xoqdbtkC5Ue3s1qZHHJBLcj9a=djFDGny6AJJSV-pdn7mcA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, Sasha Levin <levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

From 88787c483106c5830a46d18deaffdc1e70929af7 Mon Sep 17 00:00:00 2001
From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Date: Thu, 24 May 2012 08:24:39 -0700

48ddbe1946 "cgroup: make css->refcnt clearing on cgroup removal
optional" allowed a css to linger after the associated cgroup is
removed.  As a css holds a reference on the cgroup's dentry, it means
that cgroup dentries may linger for a while.

cgroup_create() does grab an active reference on the superblock to
prevent it from going away while there are !root cgroups; however, the
reference is put from cgroup_diput() which is invoked on cgroup
removal, so cgroup dentries which are removed but persisting due to
lingering csses already have released their superblock active refs
allowing superblock to be killed while those dentries are around.

Given the right condition, this makes cgroup_kill_sb() call
kill_litter_super() with dentries with non-zero d_count leading to
BUG() in shrink_dcache_for_umount_subtree().

Fix it by adding cgroup_dops->d_release() operation and moving
deactivate_super() to it.  cgroup_diput() now marks dentry->d_fsdata
with itself if superblock should be deactivated and cgroup_d_release()
deactivates the superblock on dentry release.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Reported-by: Sasha Levin <levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Tested-by: Sasha Levin <levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
LKML-Reference: <CA+1xoqe5hMuxzCRhMy7J0XchDk2ZnuxOHJKikROk1-ReAzcT6g-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
---
Li, can you please ack this?

Thanks.

 kernel/cgroup.c |   17 ++++++++++++++---
 1 files changed, 14 insertions(+), 3 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index ad8eae5..e887b55 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -896,10 +896,13 @@ static void cgroup_diput(struct dentry *dentry, struct inode *inode)
 		mutex_unlock(&cgroup_mutex);
 
 		/*
-		 * Drop the active superblock reference that we took when we
-		 * created the cgroup
+		 * We want to drop the active superblock reference from the
+		 * cgroup creation after all the dentry refs are gone -
+		 * kill_sb gets mighty unhappy otherwise.  Mark
+		 * dentry->d_fsdata with cgroup_diput() to tell
+		 * cgroup_d_release() to call deactivate_super().
 		 */
-		deactivate_super(cgrp->root->sb);
+		dentry->d_fsdata = cgroup_diput;
 
 		/*
 		 * if we're getting rid of the cgroup, refcount should ensure
@@ -925,6 +928,13 @@ static int cgroup_delete(const struct dentry *d)
 	return 1;
 }
 
+static void cgroup_d_release(struct dentry *dentry)
+{
+	/* did cgroup_diput() tell me to deactivate super? */
+	if (dentry->d_fsdata == cgroup_diput)
+		deactivate_super(dentry->d_sb);
+}
+
 static void remove_dir(struct dentry *d)
 {
 	struct dentry *parent = dget(d->d_parent);
@@ -1532,6 +1542,7 @@ static int cgroup_get_rootdir(struct super_block *sb)
 	static const struct dentry_operations cgroup_dops = {
 		.d_iput = cgroup_diput,
 		.d_delete = cgroup_delete,
+		.d_release = cgroup_d_release,
 	};
 
 	struct inode *inode =
-- 
1.7.7.3
