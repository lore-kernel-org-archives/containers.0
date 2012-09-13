From: Zhao Hongjiang <zhaohongjiang37-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] user_ns: Add support for unprivileged remount
Date: Thu, 13 Sep 2012 16:43:30 +0800
Message-ID: <50519CB2.7040801@gmail.com>
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
To: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

From: Zhao Hongjiang <zhaohongjiang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>

Relax the permission checks to allow unprivileged users that have
CAP_SYS_ADMIN permissions in the user namespace referred to by the
current mount namespace to be allowed to remount filesystems.

Signed-off-by: Zhao Hongjiang <zhaohongjiang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
 fs/namespace.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/namespace.c b/fs/namespace.c
index af238d0..72be266 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -1748,7 +1748,7 @@ static int do_remount(struct path *path, int flags, int mnt_flags,
 	struct super_block *sb = path->mnt->mnt_sb;
 	struct mount *mnt = real_mount(path->mnt);

-	if (!capable(CAP_SYS_ADMIN))
+	if (!ns_capable(mnt->mnt_ns->user_ns, CAP_SYS_ADMIN))
 		return -EPERM;

 	if (!check_mnt(mnt))
-- 1.7.1
