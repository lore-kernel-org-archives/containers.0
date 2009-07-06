From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: build breaks when checkpoint unimplemented by arch
Date: Mon, 6 Jul 2009 19:04:19 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0907061902530.15941@takamine.ncl.cs.columbia.edu>
References: <m3my7hv7w8.fsf@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m3my7hv7w8.fsf-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, 6 Jul 2009, Nathan Lynch wrote:

> Hi Oren,
> 
> With ckpt-v17-rc1 (as well as ckpt-v16-dev) the powerpc build is broken:
> 
> In file included from include/linux/checkpoint.h:28,
>                  from kernel/exit.c:53:
> include/linux/checkpoint_hdr.h:42:32: error: asm/checkpoint_hdr.h: No such file or directory
> In file included from include/linux/checkpoint.h:28,
>                  from kernel/exit.c:53:
> include/linux/checkpoint_hdr.h:410: error: 'CKPT_ARCH_NSIG' undeclared here (not in a function)
> make[1]: *** [kernel/exit.o] Error 1
> 
> 
> It appears that any architecture which does not supply
> asm/checkpoint_hdr.h is broken in the same way.
> 
> Either all architectures need to supply asm/checkpoint_hdr.h (and define
> CKPT_ARCH_NSIG), or there needs to be some other fix which allows
> as-yet-unsupported arches to build..
> 

I see... well - maybe it's time to resend the powerpc port :p

Until then, this patch worked for me to compile without c/r

Oren.


diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index c47e796..b8f99be 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -19,6 +19,7 @@
 #define RESTART_TASKSELF	0x1
 
 #ifdef __KERNEL__
+#ifdef CONFIG_CHECKPOINT
 
 #include <linux/sched.h>
 #include <linux/nsproxy.h>
@@ -299,6 +300,7 @@ extern unsigned long ckpt_debug_level;
 
 #endif /* CONFIG_CHECKPOINT_DEBUG */
 
+#endif /* CONFIG_CHECKPOINT */
 #endif /* __KERNEL__ */
 
 #endif /* _LINUX_CHECKPOINT_H_ */
