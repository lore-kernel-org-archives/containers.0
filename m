From: Greg KH <gregkh-l3A5Bk7waGM@public.gmane.org>
Subject: [PATCH] cgroupfs: create /sys/fs/cgroup to mount cgroupfs on
Date: Thu, 22 Jul 2010 11:26:38 -0700
Message-ID: <20100722182638.GA12712__45457.8849640258$1279823376$gmane$org@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Lennart Poettering <lennart-mdGvqq1h2p+GdvJs77BJ7Q@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

We really shouldn't be asking userspace to create new root filesystems.
So follow along with all of the other in-kernel filesystems, and provide
a mount point in sysfs.

For cgroupfs, this should be in /sys/fs/cgroup/  This change provides
that mount point when the cgroup filesystem is registered in the kernel.

Cc: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: Lennart Poettering <lennart-mdGvqq1h2p+GdvJs77BJ7Q@public.gmane.org>
Cc: Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>
Signed-off-by: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>

--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1623,6 +1623,8 @@ static struct file_system_type cgroup_fs_type = {
 	.kill_sb = cgroup_kill_sb,
 };
 
+static struct kobject *cgroup_kobj;
+
 static inline struct cgroup *__d_cgrp(struct dentry *dentry)
 {
 	return dentry->d_fsdata;
@@ -3871,9 +3873,18 @@ int __init cgroup_init(void)
 	hhead = css_set_hash(init_css_set.subsys);
 	hlist_add_head(&init_css_set.hlist, hhead);
 	BUG_ON(!init_root_id(&rootnode));
+
+	cgroup_kobj = kobject_create_and_add("cgroup", fs_kobj);
+	if (!cgroup_kobj) {
+		err = -ENOMEM;
+		goto out;
+	}
+
 	err = register_filesystem(&cgroup_fs_type);
-	if (err < 0)
+	if (err < 0) {
+		kobject_put(cgroup_kobj);
 		goto out;
+	}
 
 	proc_create("cgroups", 0, NULL, &proc_cgroupstats_operations);
