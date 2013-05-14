From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] cgroup: initialize xattr before calling d_instantiate()
Date: Tue, 14 May 2013 19:44:20 +0800
Message-ID: <51922394.2020002__7450.30268230966$1368531900$gmane$org@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, LSM <linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Casey Schaufler <casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org>, Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Ivan Bulatovic <combuster-fd97jBR+K/7gvPn8nOUGzA@public.gmane.org>
List-Id: containers.vger.kernel.org

cgroup_create_file() calls d_instantiate(), which may decide to look
at the xattrs on the file. Smack always does this and SELinux can be
configured to do so.

But cgroup_add_file() didn't initialize xattrs before calling
cgroup_create_file(), which finally leads to dereferencing NULL
dentry->d_fsdata.

This bug has been there since cgroup xattr was introduced.

Cc: <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org> # 3.8.x
Reported-by: Ivan Bulatovic <combuster-fd97jBR+K/7gvPn8nOUGzA@public.gmane.org>
Reported-by: Casey Schaufler <casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org>
Signed-off-by: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
 kernel/cgroup.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 2a99262..38b1365 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -2699,13 +2699,14 @@ static int cgroup_add_file(struct cgroup *cgrp, struct cgroup_subsys *subsys,
 		goto out;
 	}
 
+	cfe->type = (void *)cft;
+	cfe->dentry = dentry;
+	dentry->d_fsdata = cfe;
+	simple_xattrs_init(&cfe->xattrs);
+
 	mode = cgroup_file_mode(cft);
 	error = cgroup_create_file(dentry, mode | S_IFREG, cgrp->root->sb);
 	if (!error) {
-		cfe->type = (void *)cft;
-		cfe->dentry = dentry;
-		dentry->d_fsdata = cfe;
-		simple_xattrs_init(&cfe->xattrs);
 		list_add_tail(&cfe->node, &parent->files);
 		cfe = NULL;
 	}
-- 
1.8.0.2
