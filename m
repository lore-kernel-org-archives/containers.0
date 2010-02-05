From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: c/r rebase to 2.6.33-rc5
Date: Thu, 4 Feb 2010 19:40:09 -0600
Message-ID: <20100205014009.GA5474@us.ibm.com>
References: <4B6B04E7.9080704@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4B6B04E7.9080704-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> 
> I rebased the most recent patchset to 2.6.33, and pushed to
> ckpt-v19-rc2.10. only x86-32 is (lightly) tested.
> 
> it does not include patches from 1/27 and on. working on it
> now.
> 
> please review:
> 
> * arch-specific parts that I didn't screw up anything.
> btw, I moved checkpoint code from mm/ to kernel/
> 
> * [dan] network: net/checkpoint.c now uses sock_alloc_file();
> there may or may not be a leak of sock_hold().
> 
> * [serge] selinux now auto-generates some include files, see
> the changes to classmap.h
> 
> Oren.

For x86-64, I needed the following patch.  With this patch, only
the fileio and futex tests failed.  Suka is looking into the fileio
failure - Matt you might check the futex tests on whatever arch
you have available...

For s390, I of course still need
"fix 31-bit s390 checkpoint/restart wrappers" for compile with
CONFIG_COMPAT to succeed.

-serge

From 983e6674a72f0f911caddb3304c5d6a8e2e5d354 Mon Sep 17 00:00:00 2001
From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date: Thu, 4 Feb 2010 13:35:15 -0600
Subject: [PATCH 1/1] fix x86-64 checkpoint and restart syscall numbers

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 arch/x86/include/asm/unistd_64.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/x86/include/asm/unistd_64.h b/arch/x86/include/asm/unistd_64.h
index fbac07d..17bacfd 100644
--- a/arch/x86/include/asm/unistd_64.h
+++ b/arch/x86/include/asm/unistd_64.h
@@ -665,9 +665,9 @@ __SYSCALL(__NR_perf_event_open, sys_perf_event_open)
 __SYSCALL(__NR_recvmmsg, sys_recvmmsg)
 #define __NR_eclone                   		300
 __SYSCALL(__NR_eclone, stub_eclone)
-#define __NR_checkpoint                   	300
+#define __NR_checkpoint                   	301
 __SYSCALL(__NR_checkpoint, stub_checkpoint)
-#define __NR_restart                   		301
+#define __NR_restart                   		302
 __SYSCALL(__NR_restart, stub_restart)
 
 #ifndef __NO_STUBS
-- 
1.6.0.6
