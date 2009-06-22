From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 2/4] fs.h: fix header export breakage
Date: Mon, 22 Jun 2009 18:06:16 -0500
Message-ID: <1245711978-1453-3-git-send-email-ntl@pobox.com>
References: <1245711978-1453-1-git-send-email-ntl@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1245711978-1453-1-git-send-email-ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

# make headers_check
...
/home/nathanl/devel/linux-2.6.git/usr/include/linux/fs.h:11: included file 'linux/checkpoint_types.h' is not exported

This breaks building of any user space code which includes fs.h.

include/linux/checkpoint_types.h is not exported.
include/linux/fs.h is exported.

The latter #includes the former for the declaration of struct
ckpt_ctx, but this is not strictly necessary for correctness.
Forward-declaring struct ckpt_ctx and removing the include of
checkpoint_types.h is sufficient and fixes the breakage.

Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
---
 include/linux/fs.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/fs.h b/include/linux/fs.h
index e64f892..18e462c 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -8,7 +8,6 @@
 
 #include <linux/limits.h>
 #include <linux/ioctl.h>
-#include <linux/checkpoint_types.h>
 
 /*
  * It's silly to have NR_OPEN bigger than NR_FILE, but you can change
@@ -389,6 +388,7 @@ struct kstatfs;
 struct vm_area_struct;
 struct vfsmount;
 struct cred;
+struct ckpt_ctx;
 
 extern void __init inode_init(void);
 extern void __init inode_init_early(void);
-- 
1.6.0.6
