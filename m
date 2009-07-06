From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: build breaks when checkpoint unimplemented by arch
Date: Mon, 6 Jul 2009 18:29:34 -0500
Message-ID: <20090706232934.GA2903@us.ibm.com>
References: <m3my7hv7w8.fsf@pobox.com>
	<Pine.LNX.4.64.0907061902530.15941@takamine.ncl.cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0907061902530.15941-CXF6herHY6ykSYb+qCZC/1i27PF6R63G9nwVQlTi/Pw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> On Mon, 6 Jul 2009, Nathan Lynch wrote:
> 
> > Hi Oren,
> > 
> > With ckpt-v17-rc1 (as well as ckpt-v16-dev) the powerpc build is broken:
> > 
> > In file included from include/linux/checkpoint.h:28,
> >                  from kernel/exit.c:53:
> > include/linux/checkpoint_hdr.h:42:32: error: asm/checkpoint_hdr.h: No such file or directory
> > In file included from include/linux/checkpoint.h:28,
> >                  from kernel/exit.c:53:
> > include/linux/checkpoint_hdr.h:410: error: 'CKPT_ARCH_NSIG' undeclared here (not in a function)
> > make[1]: *** [kernel/exit.o] Error 1
> > 
> > 
> > It appears that any architecture which does not supply
> > asm/checkpoint_hdr.h is broken in the same way.
> > 
> > Either all architectures need to supply asm/checkpoint_hdr.h (and define
> > CKPT_ARCH_NSIG), or there needs to be some other fix which allows
> > as-yet-unsupported arches to build..
> > 
> 
> I see... well - maybe it's time to resend the powerpc port :p

arm, sh, etc.

> Until then, this patch worked for me to compile without c/r

That isn't enough bc a lot of files are including <linux/checkpoint_hdr.h> and
_types.h.

The following patch enables compilation on powerpc, and it still works on
s390.

-serge

From 14eb1922d4bb3b01aa5f729022edf843b354ec97 Mon Sep 17 00:00:00 2001
From: root <root-JJi412eHaPLkOmf+N4b0O9FgqiXiwxn+0E9HWUfgJXw@public.gmane.org>
Date: Mon, 6 Jul 2009 16:22:29 -0700
Subject: [PATCH] cr: enable compile on architectures without asm/checkpoint_hdr.h

ifdef out the contents of linux/checkpoint.h if !CONFIG_CHECKPOINT.
For all files which were including one of the other checkpoint*.h
files, include linux/checkpoint.h instead, which will #include
those.

Signed-off-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 fs/pipe.c                  |    1 -
 include/linux/checkpoint.h |    2 ++
 ipc/shm.c                  |    1 -
 ipc/util.h                 |    2 +-
 kernel/capability.c        |    4 +++-
 mm/filemap.c               |    2 --
 mm/mmap.c                  |    2 --
 mm/shmem.c                 |    2 --
 8 files changed, 6 insertions(+), 10 deletions(-)

diff --git a/fs/pipe.c b/fs/pipe.c
index 5d4c1c8..18c22eb 100644
--- a/fs/pipe.c
+++ b/fs/pipe.c
@@ -24,7 +24,6 @@
 #include <asm/ioctls.h>
 
 #include <linux/checkpoint.h>
-#include <linux/checkpoint_hdr.h>
 
 /*
  * We use a start+len construction, which provides full use of the 
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index c47e796..9d82082 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -10,6 +10,7 @@
  *  distribution for more details.
  */
 
+#ifdef CONFIG_CHECKPOINT
 #define CHECKPOINT_VERSION  1
 
 /* checkpoint user flags */
@@ -301,4 +302,5 @@ extern unsigned long ckpt_debug_level;
 
 #endif /* __KERNEL__ */
 
+#endif
 #endif /* _LINUX_CHECKPOINT_H_ */
diff --git a/ipc/shm.c b/ipc/shm.c
index 0991134..516b179 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -40,7 +40,6 @@
 #include <linux/mount.h>
 #include <linux/ipc_namespace.h>
 #include <linux/ima.h>
-#include <linux/checkpoint_hdr.h>
 #include <linux/checkpoint.h>
 
 #include <asm/uaccess.h>
diff --git a/ipc/util.h b/ipc/util.h
index 48de0a9..1ddfd90 100644
--- a/ipc/util.h
+++ b/ipc/util.h
@@ -12,7 +12,7 @@
 
 #include <linux/unistd.h>
 #include <linux/err.h>
-#include <linux/checkpoint_hdr.h>
+#include <linux/checkpoint.h>
 
 #define SEQ_MULTIPLIER	(IPCMNI)
 
diff --git a/kernel/capability.c b/kernel/capability.c
index 90cc7b4..94328c9 100644
--- a/kernel/capability.c
+++ b/kernel/capability.c
@@ -15,7 +15,7 @@
 #include <linux/syscalls.h>
 #include <linux/pid_namespace.h>
 #include <linux/securebits.h>
-#include <linux/checkpoint_hdr.h>
+#include <linux/checkpoint.h>
 #include <asm/uaccess.h>
 #include "cred-internals.h"
 
@@ -375,6 +375,7 @@ static inline int restore_cap_bset(kernel_cap_t bset, struct cred *cred)
 }
 #endif /* CONFIG_SECURITY_FILE_CAPABILITIES */
 
+#ifdef CONFIG_CHECKPOINT
 static int do_restore_caps(struct ckpt_capabilities *h, struct cred *cred)
 {
 	kernel_cap_t effective, inheritable, permitted, bset;
@@ -428,6 +429,7 @@ int restore_capabilities(struct ckpt_capabilities *h, struct cred *new)
 
 	return ret;
 }
+#endif
 
 /**
  * capable - Determine if the current task has a superior capability in effect
diff --git a/mm/filemap.c b/mm/filemap.c
index 782664d..cd8556d 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -36,8 +36,6 @@
 #include <linux/mm_inline.h> /* for page_is_file_cache() */
 #include "internal.h"
 
-#include <linux/checkpoint_types.h>
-#include <linux/checkpoint_hdr.h>
 #include <linux/checkpoint.h>
 
 /*
diff --git a/mm/mmap.c b/mm/mmap.c
index e60424b..ba0b039 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -35,8 +35,6 @@
 #include <asm/tlb.h>
 #include <asm/mmu_context.h>
 
-#include <linux/checkpoint_types.h>
-#include <linux/checkpoint_hdr.h>
 #include <linux/checkpoint.h>
 
 #include "internal.h"
diff --git a/mm/shmem.c b/mm/shmem.c
index e123ec2..7d80ef8 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -31,8 +31,6 @@
 #include <linux/swap.h>
 #include <linux/ima.h>
 
-#include <linux/checkpoint_types.h>
-#include <linux/checkpoint_hdr.h>
 #include <linux/checkpoint.h>
 
 static struct vfsmount *shm_mnt;
-- 
1.6.2.3
