From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 2/9] cgroup: remove cftype->release()
Date: Sun, 24 Nov 2013 17:11:29 -0500
Message-ID: <1385331096-7918-3-git-send-email-tj__11426.9643825994$1385331129$gmane$org@kernel.org>
References: <1385331096-7918-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1385331096-7918-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Now that pidlist files don't use cftype->release(), it doesn't have
any user left.  Remove it.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 include/linux/cgroup.h | 2 --
 kernel/cgroup.c        | 3 ---
 2 files changed, 5 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 492fa01..5207c28 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -499,8 +499,6 @@ struct cftype {
 	 * kick type for multiplexing.
 	 */
 	int (*trigger)(struct cgroup_subsys_state *css, unsigned int event);
-
-	int (*release)(struct inode *inode, struct file *file);
 };
 
 /*
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 61a5e2e..2fd888f 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -2447,12 +2447,9 @@ static int cgroup_file_open(struct inode *inode, struct file *file)
 static int cgroup_file_release(struct inode *inode, struct file *file)
 {
 	struct cfent *cfe = __d_cfe(file->f_dentry);
-	struct cftype *cft = __d_cft(file->f_dentry);
 	struct cgroup_subsys_state *css = cfe->css;
 	int ret = 0;
 
-	if (cft->release)
-		ret = cft->release(inode, file);
 	if (css->ss)
 		css_put(css);
 	return ret;
-- 
1.8.4.2
