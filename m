From: Zhao Hongjiang <zhaohongjiang37-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] userns: fix return value on mntns_install() failure
Date: Thu, 13 Sep 2012 16:38:03 +0800
Message-ID: <50519B6B.1050902@gmail.com>
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

Change return value from -EINVAL to -EPERM when the permission check fails.

Signed-off-by: Zhao Hongjiang <zhaohongjiang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
 fs/namespace.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/namespace.c b/fs/namespace.c
index 72be266..1e79d20 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -2764,7 +2764,7 @@ static int mntns_install(struct nsproxy *nsproxy, void *ns)

 	if (!ns_capable(mnt_ns->user_ns, CAP_SYS_ADMIN) ||
 	    !nsown_capable(CAP_SYS_CHROOT))
-		return -EINVAL;
+		return -EPERM;

 	if (fs->users != 1)
 		return -EINVAL;
-- 1.7.1
