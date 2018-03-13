From: Christian Brauner <christian.brauner-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 3/4 v5] devpts: comment devpts_mntget()
Date: Tue, 13 Mar 2018 13:17:12 +0100
Message-ID: <20180313121713.32551-4-christian.brauner@ubuntu.com>
References: <20180313121713.32551-1-christian.brauner@ubuntu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20180313121713.32551-1-christian.brauner-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Christian Brauner <christian.brauner-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Signed-off-by: Christian Brauner <christian.brauner-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
---
ChangeLog v4->v5:
* patch added
ChangeLog v3->v4:
* patch not present
ChangeLog v2->v3:
* patch not present
ChangeLog v1->v2:
* patch not present
ChangeLog v0->v1:
* patch not present
---
 fs/devpts/inode.c | 18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

diff --git a/fs/devpts/inode.c b/fs/devpts/inode.c
index 542364bf923e..e072e955ce33 100644
--- a/fs/devpts/inode.c
+++ b/fs/devpts/inode.c
@@ -152,6 +152,24 @@ static int devpts_ptmx_path(struct path *path)
 	return 0;
 }
 
+/*
+ * Try to find a suitable devpts filesystem. We support the following
+ * scenarios:
+ * - The ptmx device node is located in the same directory as the devpts
+ *   mount where the pts device nodes are located.
+ *   This is e.g. the case when calling open on the /dev/pts/ptmx device
+ *   node when the devpts filesystem is mounted at /dev/pts.
+ * - The ptmx device node is located outside the devpts filesystem mount
+ *   where the pts device nodes are located. For example, the ptmx device
+ *   is a symlink, separate device node, or bind-mount.
+ *   A supported scenario is bind-mounting /dev/pts/ptmx to /dev/ptmx and
+ *   then calling open on /dev/ptmx. In this case a suitable pts
+ *   subdirectory can be found in the common parent directory /dev of the
+ *   devpts mount and the ptmx bind-mount, after resolving the /dev/ptmx
+ *   bind-mount.
+ *   If no suitable pts subdirectory can be found this function will fail.
+ *   This is e.g. the case when bind-mounting /dev/pts/ptmx to /ptmx.
+ */
 struct vfsmount *devpts_mntget(struct file *filp, struct pts_fs_info *fsi)
 {
 	struct path path;
-- 
2.15.1
