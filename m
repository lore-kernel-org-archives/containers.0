From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: Re: build breaks when checkpoint unimplemented by arch
Date: Mon, 06 Jul 2009 18:54:39 -0500
Message-ID: <m3bpnxv03k.fsf@pobox.com>
References: <m3my7hv7w8.fsf@pobox.com>
	<Pine.LNX.4.64.0907061902530.15941@takamine.ncl.cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <Pine.LNX.4.64.0907061902530.15941-CXF6herHY6ykSYb+qCZC/1i27PF6R63G9nwVQlTi/Pw@public.gmane.org>
	(Oren Laadan's message of "Mon\, 6 Jul 2009 19\:04\:19 -0400 \(EDT\)")
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

Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org> writes:

> On Mon, 6 Jul 2009, Nathan Lynch wrote:
>
>> Hi Oren,
>> 
>> With ckpt-v17-rc1 (as well as ckpt-v16-dev) the powerpc build is broken:
>> 
>> In file included from include/linux/checkpoint.h:28,
>>                  from kernel/exit.c:53:
>> include/linux/checkpoint_hdr.h:42:32: error: asm/checkpoint_hdr.h: No such file or directory
>> In file included from include/linux/checkpoint.h:28,
>>                  from kernel/exit.c:53:
>> include/linux/checkpoint_hdr.h:410: error: 'CKPT_ARCH_NSIG' undeclared here (not in a function)
>> make[1]: *** [kernel/exit.o] Error 1
>> 
>> 
>> It appears that any architecture which does not supply
>> asm/checkpoint_hdr.h is broken in the same way.
>> 
>> Either all architectures need to supply asm/checkpoint_hdr.h (and define
>> CKPT_ARCH_NSIG), or there needs to be some other fix which allows
>> as-yet-unsupported arches to build..
>> 
>
> I see... well - maybe it's time to resend the powerpc port :p

I'm working on that, but the powerpc port won't be of any help to the
twenty-odd other architectures that are broken.


> Until then, this patch worked for me to compile without c/r
>
> diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
> index c47e796..b8f99be 100644
> --- a/include/linux/checkpoint.h
> +++ b/include/linux/checkpoint.h
> @@ -19,6 +19,7 @@
>  #define RESTART_TASKSELF	0x1
>  
>  #ifdef __KERNEL__
> +#ifdef CONFIG_CHECKPOINT
>  
>  #include <linux/sched.h>
>  #include <linux/nsproxy.h>
> @@ -299,6 +300,7 @@ extern unsigned long ckpt_debug_level;
>  
>  #endif /* CONFIG_CHECKPOINT_DEBUG */
>  
> +#endif /* CONFIG_CHECKPOINT */
>  #endif /* __KERNEL__ */

I think something like the following could be a better approach.

It needs to be split into separate patches with good commit messages,
but the gist is that asm/checkpoint_hdr.h should be included only by
files built when CONFIG_CHECKPOINT=y.

And linux/checkpoint_hdr.h doesn't really need it: all architectures
provide a sigset_t definition.

 arch/x86/mm/checkpoint.c       |    1 +
 checkpoint/checkpoint.c        |    1 +
 checkpoint/restart.c           |    1 +
 include/linux/checkpoint_hdr.h |    6 ++----
 4 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/arch/x86/mm/checkpoint.c b/arch/x86/mm/checkpoint.c
index 68432c8..3d21989 100644
--- a/arch/x86/mm/checkpoint.c
+++ b/arch/x86/mm/checkpoint.c
@@ -17,6 +17,7 @@
 
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
+#include <asm/checkpoint_hdr.h>
 
 /*
  * helpers to encode/decode/validate registers/segments/eflags
diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index 2d4923c..6e90755 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -26,6 +26,7 @@
 #include <linux/hrtimer.h>
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
+#include <asm/checkpoint_hdr.h>
 
 /* unique checkpoint identifier (FIXME: should be per-container ?) */
 static atomic_t ctx_count = ATOMIC_INIT(0);
diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index 7982a03..afe2e1c 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -22,6 +22,7 @@
 #include <linux/elf.h>
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
+#include <asm/checkpoint_hdr.h>
 
 /**
  * _ckpt_read_objref - dispatch handling of a shared object
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index b5243e1..a2872a4 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -12,6 +12,7 @@
 
 #include <linux/types.h>
 #include <linux/utsname.h>
+#include <asm/signal.h>
 
 /*
  * To maintain compatibility between 32-bit and 64-bit architecture flavors,
@@ -39,9 +40,6 @@ struct ckpt_hdr {
 } __attribute__((aligned(8)));
 
 
-#include <asm/checkpoint_hdr.h>
-
-
 /* header types */
 enum {
 	CKPT_HDR_HEADER = 1,
@@ -407,7 +405,7 @@ struct ckpt_hdr_pgarr {
 
 /* signals */
 struct ckpt_hdr_sigset {
-	__u8 sigset[CKPT_ARCH_NSIG / 8];
+	sigset_t sigset;
 } __attribute__((aligned(8)));
 
 struct ckpt_hdr_sigaction {
