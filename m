From: Serge Hallyn <serge.hallyn@canonical.com>
Subject: prevent containers from turning host filesystem readonly
Date: Fri, 10 Feb 2012 21:19:39 -0600
Message-ID: <20120211031939.GA4772@sergelap>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-security-module-owner@vger.kernel.org
To: lkml <linux-kernel@vger.kernel.org>, Andy Whitcroft <apw@canonical.com>, Andrew Morton <akpm@linux-foundation.org>, "Eric W. Biederman" <ebiederm@xmission.com>, Dave Hansen <haveblue@us.ibm.com>, linux-security-module@vger.kernel.org, Linux Containers <containers@lists.osdl.org>, =?iso-8859-1?Q?St=E9phane?= Graber <stgraber@ubuntu.com>, Daniel Lezcano <daniel.lezcano@free.fr>
List-Id: containers.vger.kernel.org

When a container shuts down, it likes to do 'mount -o remount,ro /'.
That sets the superblock's readonly flag, not the mount's.  So unless
the mount action fails for some reason (i.e. a file is held open on
the fs), if the container's rootfs is just a directory on the host's
fs, the host fs will be marked readonly.

Thanks to Dave Hansen for pointing out how simple the fix can be.  If
the devices cgroup denies the mounting task write access to the
underlying superblock (as it usually does when the container's root fs
is on a block device shared with the host), then it do_remount_sb should
deny the right to change mount flags as well.

This patch adds that check.

Note that another possibility would be to have the LSM step in.  We
can't catch this (as is) at the LSM level because security_remount_sb
doesn't get the mount flags, so we can't distinguish
	mount -o remount,ro
from
	mount --bind -o remount,ro.
Sending the flags to that hook would probably be a good idea in addition
to this patch, but I haven't done it here.

Signed-off-by: Serge Hallyn <serge.hallyn@canonical.com>
---
 fs/super.c                    |    5 +++++
 include/linux/device_cgroup.h |    3 +++
 security/device_cgroup.c      |   32 ++++++++++++++++++++++++++++++++
 3 files changed, 40 insertions(+), 0 deletions(-)

diff --git a/fs/super.c b/fs/super.c
index afd0f1a..e29cdd1 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -32,6 +32,7 @@
 #include <linux/backing-dev.h>
 #include <linux/rculist_bl.h>
 #include <linux/cleancache.h>
+#include <linux/device_cgroup.h>
 #include "internal.h"
 
 
@@ -709,6 +710,10 @@ int do_remount_sb(struct super_block *sb, int flags, void *data, int force)
 		return -EACCES;
 #endif
 
+	retval = devcgroup_remount(sb);
+	if (retval)
+		return retval;
+
 	if (flags & MS_RDONLY)
 		acct_auto_close(sb);
 	shrink_dcache_sb(sb);
diff --git a/include/linux/device_cgroup.h b/include/linux/device_cgroup.h
index 8b64221..8c77b40 100644
--- a/include/linux/device_cgroup.h
+++ b/include/linux/device_cgroup.h
@@ -11,9 +11,12 @@ static inline int devcgroup_inode_permission(struct inode *inode, int mask)
 		return 0;
 	return __devcgroup_inode_permission(inode, mask);
 }
+extern int devcgroup_remount(struct super_block *sb);
 #else
 static inline int devcgroup_inode_permission(struct inode *inode, int mask)
 { return 0; }
 static inline int devcgroup_inode_mknod(int mode, dev_t dev)
 { return 0; }
+static inline int devcgroup_remount(struct super_block *sb)
+{ return 0; }
 #endif
diff --git a/security/device_cgroup.c b/security/device_cgroup.c
index 662ae5f..8b76d73 100644
--- a/security/device_cgroup.c
+++ b/security/device_cgroup.c
@@ -538,3 +538,35 @@ found:
 
 	return -EPERM;
 }
+
+int devcgroup_remount(struct super_block *sb)
+{
+	struct dev_cgroup *dev_cgroup;
+	struct dev_whitelist_item *wh;
+	u32 major = MAJOR(sb->s_dev), minor = MINOR(sb->s_dev);
+
+	rcu_read_lock();
+
+	dev_cgroup = task_devcgroup(current);
+
+	list_for_each_entry_rcu(wh, &dev_cgroup->whitelist, list) {
+		if (wh->type & DEV_ALL)
+			goto found;
+		if (!(wh->type & DEV_BLOCK))
+			continue;
+		if (wh->major != ~0 && wh->major != major)
+			continue;
+		if (wh->minor != ~0 && wh->minor != minor)
+			continue;
+		if (!(wh->access & ACC_WRITE))
+			continue;
+found:
+		rcu_read_unlock();
+		return 0;
+	}
+
+	rcu_read_unlock();
+
+	return -EPERM;
+}
+EXPORT_SYMBOL(devcgroup_remount);
-- 
1.7.9

