From: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: [RFC][PATCH 2/4]: Use interface to access allocated_ptys
Date: Tue, 5 Feb 2008 21:10:27 -0800
Message-ID: <20080206051027.GB19764@us.ibm.com>
References: <20080206050428.GA19461@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080206050428.GA19461-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

From: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [RFC][PATCH 2/4]: Use interface to access allocated_ptys

In preparation for supporting multiple PTY namespaces, use an inline
function to access the 'allocated_ptys' idr.

Changelog:
	- Version 0: Based on earlier versions from Serge Hallyn and
	  Matt Helsley.

Signed-off-by: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 fs/devpts/inode.c |   13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

Index: linux-2.6.24/fs/devpts/inode.c
===================================================================
--- linux-2.6.24.orig/fs/devpts/inode.c	2008-02-05 17:17:11.000000000 -0800
+++ linux-2.6.24/fs/devpts/inode.c	2008-02-05 17:30:52.000000000 -0800
@@ -28,6 +28,11 @@ extern int pty_limit;		/* Config limit o
 static DEFINE_IDR(allocated_ptys);
 static DECLARE_MUTEX(allocated_ptys_lock);
 
+static inline struct idr *current_pts_ns_allocated_ptys(void)
+{
+	return &allocated_ptys;
+}
+
 static struct vfsmount *devpts_mnt;
 static struct dentry *devpts_root;
 
@@ -167,12 +172,12 @@ int devpts_new_index(void)
 	int idr_ret;
 
 retry:
-	if (!idr_pre_get(&allocated_ptys, GFP_KERNEL)) {
+	if (!idr_pre_get(current_pts_ns_allocated_ptys(), GFP_KERNEL)) {
 		return -ENOMEM;
 	}
 
 	down(&allocated_ptys_lock);
-	idr_ret = idr_get_new(&allocated_ptys, NULL, &index);
+	idr_ret = idr_get_new(current_pts_ns_allocated_ptys(), NULL, &index);
 	if (idr_ret < 0) {
 		up(&allocated_ptys_lock);
 		if (idr_ret == -EAGAIN)
@@ -181,7 +186,7 @@ retry:
 	}
 
 	if (index >= pty_limit) {
-		idr_remove(&allocated_ptys, index);
+		idr_remove(current_pts_ns_allocated_ptys(), index);
 		up(&allocated_ptys_lock);
 		return -EIO;
 	}
@@ -192,7 +197,7 @@ retry:
 void devpts_kill_index(int idx)
 {
 	down(&allocated_ptys_lock);
-	idr_remove(&allocated_ptys, idx);
+	idr_remove(current_pts_ns_allocated_ptys(), idx);
 	up(&allocated_ptys_lock);
 }
