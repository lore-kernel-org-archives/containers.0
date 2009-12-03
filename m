From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] checkpoint: remove clone_with_pids remnants from arch/powerpc
Date: Thu,  3 Dec 2009 13:50:06 -0600
Message-ID: <1259869807-12835-1-git-send-email-ntl@pobox.com>
References: <Pine.LNX.4.64.0912012352420.5665@takamine.ncl.cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <Pine.LNX.4.64.0912012352420.5665-CXF6herHY6ykSYb+qCZC/1i27PF6R63G9nwVQlTi/Pw@public.gmane.org>
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

We have eclone now so this stuff can go (and it doesn't build anyway).

Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
---
 arch/powerpc/include/asm/systbl.h |    1 -
 arch/powerpc/kernel/process.c     |   18 ------------------
 2 files changed, 0 insertions(+), 19 deletions(-)

diff --git a/arch/powerpc/include/asm/systbl.h b/arch/powerpc/include/asm/systbl.h
index 280a2b5..c374cb7 100644
--- a/arch/powerpc/include/asm/systbl.h
+++ b/arch/powerpc/include/asm/systbl.h
@@ -329,4 +329,3 @@ COMPAT_SYS(rt_tgsigqueueinfo)
 PPC_SYS(eclone)
 SYSCALL(checkpoint)
 SYSCALL(restart)
-PPC_SYS(clone_with_pids)
diff --git a/arch/powerpc/kernel/process.c b/arch/powerpc/kernel/process.c
index b9278d8..c1900b3 100644
--- a/arch/powerpc/kernel/process.c
+++ b/arch/powerpc/kernel/process.c
@@ -900,24 +900,6 @@ int sys_clone(unsigned long clone_flags, unsigned long usp,
 	return do_fork(clone_flags, usp, regs, 0, parent_tidp, child_tidp);
 }
 
-int sys_clone_with_pids(unsigned long clone_flags, unsigned long usp,
-	      int __user *parent_tidp, void __user *child_threadptr,
-	      int __user *child_tidp, void __user *upid_setp,
-	      struct pt_regs *regs)
-{
-	CHECK_FULL_REGS(regs);
-	if (usp == 0)
-		usp = regs->gpr[1];
-#ifdef CONFIG_PPC64
-	if (test_thread_flag(TIF_32BIT)) {
-		parent_tidp = TRUNC_PTR(parent_tidp);
-		child_tidp = TRUNC_PTR(child_tidp);
-	}
-#endif
-	return do_fork_with_pids(clone_flags, usp, regs, 0,
-				 parent_tidp, child_tidp, upid_setp);
-}
-
 int sys_eclone(unsigned long clone_flags_low,
 	       struct clone_args __user *uclone_args,
 	       size_t size,
-- 
1.6.0.6
