From: "Kirill A. Shutemov" <kas-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: [PATCH v3 01/16] sunrpc: mount rpc_pipefs on initialization
Date: Fri, 14 Jan 2011 15:48:59 +0200
Message-ID: <1295012954-7769-2-git-send-email-kas__25324.5276319378$1295013775$gmane$org@openvz.org>
References: <1295012954-7769-1-git-send-email-kas@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1295012954-7769-1-git-send-email-kas-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>, "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>, Neil Brown <neilb-l3A5Bk7waGM@public.gmane.org>
Cc: linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, "Kirill A. Shutemov" <kas-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Mount rpc_pipefs on register_rpc_pipefs() and replace
rpc_get_mount()/rpc_put_mount() implementation with mntget()/mntput().

This commit introduces temprorary regression: there is no way to
remove the module. It will be fixed at the end of the patchset.

Signed-off-by: Kirill A. Shutemov <kas-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
---
 net/sunrpc/rpc_pipe.c |   26 +++++++++++++++-----------
 1 files changed, 15 insertions(+), 11 deletions(-)

diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 72bc536..9ab9355 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -29,7 +29,6 @@
 #include <linux/sunrpc/cache.h>
 
 static struct vfsmount *rpc_mnt __read_mostly;
-static int rpc_mount_count;
 
 static struct file_system_type rpc_pipe_fs_type;
 
@@ -423,18 +422,13 @@ struct rpc_filelist {
 
 struct vfsmount *rpc_get_mount(void)
 {
-	int err;
-
-	err = simple_pin_fs(&rpc_pipe_fs_type, &rpc_mnt, &rpc_mount_count);
-	if (err != 0)
-		return ERR_PTR(err);
-	return rpc_mnt;
+	return mntget(rpc_mnt);
 }
 EXPORT_SYMBOL_GPL(rpc_get_mount);
 
 void rpc_put_mount(void)
 {
-	simple_release_fs(&rpc_mnt, &rpc_mount_count);
+	mntput(rpc_mnt);
 }
 EXPORT_SYMBOL_GPL(rpc_put_mount);
 
@@ -1071,12 +1065,22 @@ int register_rpc_pipefs(void)
 	if (!rpc_inode_cachep)
 		return -ENOMEM;
 	err = register_filesystem(&rpc_pipe_fs_type);
-	if (err) {
-		kmem_cache_destroy(rpc_inode_cachep);
-		return err;
+	if (err)
+		goto destroy_cache;
+
+	rpc_mnt = kern_mount(&rpc_pipe_fs_type);
+	if (IS_ERR(rpc_mnt)) {
+		err = PTR_ERR(rpc_mnt);
+		goto unregister_fs;
 	}
 
 	return 0;
+
+unregister_fs:
+	unregister_filesystem(&rpc_pipe_fs_type);
+destroy_cache:
+	kmem_cache_destroy(rpc_inode_cachep);
+	return err;
 }
 
 void unregister_rpc_pipefs(void)
-- 
1.7.3.4
