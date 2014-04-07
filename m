From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH cgroup/for-3.15-fixes] cgroup: newly created dirs and files
	should be owned by the creator
Date: Mon, 7 Apr 2014 16:59:16 -0400
Message-ID: <20140407205916.GD27461@htj.dyndns.org>
References: <20140403164911.GE24119@htj.dyndns.org>
	<CA+55aFyGz2q4iDEt56Bw+x_ri_-DQYLAKPJvk3Uxj9z-y+0uPw@mail.gmail.com>
	<CA+55aFy+Jt0B32kj=Ldz9Krp4DXcXSP4r-o3f-2LPcVs4udGVA@mail.gmail.com>
	<CA+55aFwM0aG1PHY7xOQbsFG+Ot4mL4=7yRnT7dssUaOyaLQ3GQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CA+55aFwM0aG1PHY7xOQbsFG+Ot4mL4=7yRnT7dssUaOyaLQ3GQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

Applied to cgroup/for-3.15.  Will soon send pull request for this one
and the cgroup_root refcnt fix from Li.

Thanks.

------ 8< ------
From 49957f8e2a43035a97d05bddefa394492a969c0d Mon Sep 17 00:00:00 2001
From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Date: Mon, 7 Apr 2014 16:44:47 -0400

While converting cgroup to kernfs, 2bd59d48ebfb ("cgroup: convert to
kernfs") accidentally dropped the logic which makes newly created
cgroup dirs and files owned by the current uid / gid.  This broke
cases where cgroup subtree management is delegated to !root as the sub
manager wouldn't be able to create more than single level of hierarchy
or put tasks into child cgroups it created.

Among other things, this breaks user session management in systemd and
one of the symptoms was 90s hang during shutdown.  User session
systemd running as the user creates a sub-service to initiate shutdown
and tries to put kill(1) into it but fails because cgroup.procs is
owned by root.  This leads to 90s hang during shutdown.

Implement cgroup_kn_set_ugid() which sets a kn's uid and gid to those
of the caller and use it from file and dir creation paths.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Reported-by: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
---
 kernel/cgroup.c | 27 ++++++++++++++++++++++++++-
 1 file changed, 26 insertions(+), 1 deletion(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 0dfc732..9fcdaa7 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -2346,11 +2346,26 @@ static int cgroup_rename(struct kernfs_node *kn, struct kernfs_node *new_parent,
 	return ret;
 }
 
+/* set uid and gid of cgroup dirs and files to that of the creator */
+static int cgroup_kn_set_ugid(struct kernfs_node *kn)
+{
+	struct iattr iattr = { .ia_valid = ATTR_UID | ATTR_GID,
+			       .ia_uid = current_fsuid(),
+			       .ia_gid = current_fsgid(), };
+
+	if (uid_eq(iattr.ia_uid, GLOBAL_ROOT_UID) &&
+	    gid_eq(iattr.ia_gid, GLOBAL_ROOT_GID))
+		return 0;
+
+	return kernfs_setattr(kn, &iattr);
+}
+
 static int cgroup_add_file(struct cgroup *cgrp, struct cftype *cft)
 {
 	char name[CGROUP_FILE_NAME_MAX];
 	struct kernfs_node *kn;
 	struct lock_class_key *key = NULL;
+	int ret;
 
 #ifdef CONFIG_DEBUG_LOCK_ALLOC
 	key = &cft->lockdep_key;
@@ -2358,7 +2373,13 @@ static int cgroup_add_file(struct cgroup *cgrp, struct cftype *cft)
 	kn = __kernfs_create_file(cgrp->kn, cgroup_file_name(cgrp, cft, name),
 				  cgroup_file_mode(cft), 0, cft->kf_ops, cft,
 				  NULL, false, key);
-	return PTR_ERR_OR_ZERO(kn);
+	if (IS_ERR(kn))
+		return PTR_ERR(kn);
+
+	ret = cgroup_kn_set_ugid(kn);
+	if (ret)
+		kernfs_remove(kn);
+	return ret;
 }
 
 /**
@@ -3753,6 +3774,10 @@ static long cgroup_create(struct cgroup *parent, const char *name,
 	 */
 	idr_replace(&root->cgroup_idr, cgrp, cgrp->id);
 
+	err = cgroup_kn_set_ugid(kn);
+	if (err)
+		goto err_destroy;
+
 	err = cgroup_addrm_files(cgrp, cgroup_base_files, true);
 	if (err)
 		goto err_destroy;
-- 
1.9.0
