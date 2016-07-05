From: Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: [PATCH 1/3 v2] namei: add LOOKUP_DFD_ROOT to use dfd as root
Date: Tue,  5 Jul 2016 14:26:58 -0700
Message-ID: <1467754018-29203-1-git-send-email-avagin@openvz.org>
References: <20160702005525.GA28451@vader.dhcp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20160702005525.GA28451-VOCez//ZDM7jzTBT5J8yX/MCgOUTN/qS0E9HWUfgJXw@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Miklos Szeredi <mszeredi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "J. Bruce Fields" <bfields-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, NeilBrown <neilb-l3A5Bk7waGM@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Shuah Khan <shuahkh-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>, criu-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Id: containers.vger.kernel.org

The problem is that a pathname can contain absolute symlinks and now
they are resolved relative to the current root.

If we want to open a file in another mount namespaces and we have a file
descriptor to its root directory, we probably want to resolve pathname
in the target mount namespace. For this we add this new flag.

If LOOKUP_DFD_ROOT is set, path_init() initializes nd->root and nd->path
to the same value.

Changes since v1:
* initialize nd->root_seq (thanks to Omar Sandoval for reporting and
  fixing this issue)

Cc: Omar Sandoval <osandov-nWWhXC5lh1RBDgjK7y7TUQ@public.gmane.org>
Signed-off-by: Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
---
 fs/namei.c            | 16 +++++++++++++++-
 include/linux/namei.h |  2 ++
 2 files changed, 17 insertions(+), 1 deletion(-)

diff --git a/fs/namei.c b/fs/namei.c
index 70580ab..d52541a 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -2148,7 +2148,7 @@ static const char *path_init(struct nameidata *nd, unsigned flags)
 	nd->path.dentry = NULL;
 
 	nd->m_seq = read_seqbegin(&mount_lock);
-	if (*s == '/') {
+	if (*s == '/' && !(flags & LOOKUP_DFD_ROOT)) {
 		if (flags & LOOKUP_RCU)
 			rcu_read_lock();
 		set_root(nd);
@@ -2174,6 +2174,13 @@ static const char *path_init(struct nameidata *nd, unsigned flags)
 			get_fs_pwd(current->fs, &nd->path);
 			nd->inode = nd->path.dentry->d_inode;
 		}
+		if (flags & LOOKUP_DFD_ROOT) {
+			nd->root = nd->path;
+			if (flags & LOOKUP_RCU)
+				nd->root_seq = nd->seq;
+			else
+				path_get(&nd->root);
+		}
 		return s;
 	} else {
 		/* Caller must check execute permissions on the starting path component */
@@ -2202,6 +2209,13 @@ static const char *path_init(struct nameidata *nd, unsigned flags)
 			nd->inode = nd->path.dentry->d_inode;
 		}
 		fdput(f);
+		if (flags & LOOKUP_DFD_ROOT) {
+			nd->root = nd->path;
+			if (flags & LOOKUP_RCU)
+				nd->root_seq = nd->seq;
+			else
+				path_get(&nd->root);
+		}
 		return s;
 	}
 }
diff --git a/include/linux/namei.h b/include/linux/namei.h
index d3d0398..ca2ea13 100644
--- a/include/linux/namei.h
+++ b/include/linux/namei.h
@@ -45,6 +45,8 @@ enum {LAST_NORM, LAST_ROOT, LAST_DOT, LAST_DOTDOT, LAST_BIND};
 #define LOOKUP_ROOT		0x2000
 #define LOOKUP_EMPTY		0x4000
 
+#define LOOKUP_DFD_ROOT		0x8000
+
 extern int path_pts(struct path *path);
 
 extern int user_path_at_empty(int, const char __user *, unsigned, struct path *, int *empty);
-- 
2.5.5
