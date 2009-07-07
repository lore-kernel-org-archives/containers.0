From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: build breaks when checkpoint unimplemented by arch
Date: Tue, 7 Jul 2009 08:33:35 -0500
Message-ID: <20090707133335.GA7686@us.ibm.com>
References: <m3my7hv7w8.fsf@pobox.com>
	<Pine.LNX.4.64.0907061902530.15941@takamine.ncl.cs.columbia.edu>
	<m3bpnxv03k.fsf@pobox.com>
	<Pine.LNX.4.64.0907070039360.22105@takamine.ncl.cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0907070039360.22105-CXF6herHY6ykSYb+qCZC/1i27PF6R63G9nwVQlTi/Pw@public.gmane.org>
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
> > Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org> writes:
> > 
> > > On Mon, 6 Jul 2009, Nathan Lynch wrote:
> > >
> > >> Hi Oren,
> > >> 
> > >> With ckpt-v17-rc1 (as well as ckpt-v16-dev) the powerpc build is broken:
> > >> 
> > >> In file included from include/linux/checkpoint.h:28,
> > >>                  from kernel/exit.c:53:
> > >> include/linux/checkpoint_hdr.h:42:32: error: asm/checkpoint_hdr.h: No such file or directory
> > >> In file included from include/linux/checkpoint.h:28,
> > >>                  from kernel/exit.c:53:
> > >> include/linux/checkpoint_hdr.h:410: error: 'CKPT_ARCH_NSIG' undeclared here (not in a function)
> > >> make[1]: *** [kernel/exit.o] Error 1
> > >> 
> > >> 
> > >> It appears that any architecture which does not supply
> > >> asm/checkpoint_hdr.h is broken in the same way.
> > >> 
> > >> Either all architectures need to supply asm/checkpoint_hdr.h (and define
> > >> CKPT_ARCH_NSIG), or there needs to be some other fix which allows
> > >> as-yet-unsupported arches to build..
> > >> 
> > >
> > > I see... well - maybe it's time to resend the powerpc port :p
> > 
> > I'm working on that, but the powerpc port won't be of any help to the
> > twenty-odd other architectures that are broken.
> > 
> 
> [...]
> 
> That's what I tried initially, but the problem is that sigset_t may
> be defined differently for userspace - see /usr/include/asm/sigset_t.h.
> In fact, for x86_32, it it is different, defined as 'unsigned long' 
> (and NSIG defined as 32, so only 32 bits).
> 
> Moreover, if you include <asm/sigset.h> in checkpoint_hdr.h, which is
> also included by userspace, you get lots of compilations warnings,
> because of other stuff included from the kernel's asm/sigset.h that
> isn't supposed to be included by userspace.
> 
> So the introduction of CKPT_ARCH_NSIG is a workaround that.
> 
> And back to the other problem - I agree, kernel should only include
> <linux/checkpoint.h>, which in turn will include <checkpoint_hdr.h>
> if defined CONFIG_CHECKPOINT.
> 
> Can you try this patch:

(Which looks exactly like my patch from yesterday.)

> (Hallyn: note that there is some checkpoint-related code within
> kerbel/capability.c that should be inside #ifdef CONFIG_CHECKPOINT).

Yup, the patch i sent yesterday took care of that.

So if that's the route we want to take, then again I can
confirm it did compile on ppc, and compile and boot on
s390.

> Oren.
> 
> 
> diff --git a/fs/pipe.c b/fs/pipe.c
> index 5d4c1c8..68fdab4 100644
> --- a/fs/pipe.c
> +++ b/fs/pipe.c
> @@ -19,12 +19,11 @@
>  #include <linux/pagemap.h>
>  #include <linux/audit.h>
>  #include <linux/syscalls.h>
> +#include <linux/checkpoint.h>
> 
>  #include <asm/uaccess.h>
>  #include <asm/ioctls.h>
> 
> -#include <linux/checkpoint.h>
> -#include <linux/checkpoint_hdr.h>
> 
>  /*
>   * We use a start+len construction, which provides full use of the 
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
> 
>  #endif /* _LINUX_CHECKPOINT_H_ */
> diff --git a/ipc/shm.c b/ipc/shm.c
> index 0991134..516b179 100644
> --- a/ipc/shm.c
> +++ b/ipc/shm.c
> @@ -40,7 +40,6 @@
>  #include <linux/mount.h>
>  #include <linux/ipc_namespace.h>
>  #include <linux/ima.h>
> -#include <linux/checkpoint_hdr.h>
>  #include <linux/checkpoint.h>
> 
>  #include <asm/uaccess.h>
> diff --git a/kernel/capability.c b/kernel/capability.c
> index 90cc7b4..4f58454 100644
> --- a/kernel/capability.c
> +++ b/kernel/capability.c
> @@ -15,7 +15,7 @@
>  #include <linux/syscalls.h>
>  #include <linux/pid_namespace.h>
>  #include <linux/securebits.h>
> -#include <linux/checkpoint_hdr.h>
> +#include <linux/checkpoint.h>
>  #include <asm/uaccess.h>
>  #include "cred-internals.h"
> 
> @@ -375,6 +375,7 @@ static inline int restore_cap_bset(kernel_cap_t bset, struct cred *cred)
>  }
>  #endif /* CONFIG_SECURITY_FILE_CAPABILITIES */
> 
> +#ifdef CONFIG_CHECKPOINT
>  static int do_restore_caps(struct ckpt_capabilities *h, struct cred *cred)
>  {
>  	kernel_cap_t effective, inheritable, permitted, bset;
> @@ -428,6 +429,7 @@ int restore_capabilities(struct ckpt_capabilities *h, struct cred *new)
> 
>  	return ret;
>  }
> +#endif /* CONFIG_CHECKPOINT */
> 
>  /**
>   * capable - Determine if the current task has a superior capability in effect
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 782664d..202bd74 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -34,11 +34,9 @@
>  #include <linux/hardirq.h> /* for BUG_ON(!in_atomic()) only */
>  #include <linux/memcontrol.h>
>  #include <linux/mm_inline.h> /* for page_is_file_cache() */
> +#include <linux/checkpoint.h>
>  #include "internal.h"
> 
> -#include <linux/checkpoint_types.h>
> -#include <linux/checkpoint_hdr.h>
> -#include <linux/checkpoint.h>
> 
>  /*
>   * FIXME: remove all knowledge of the buffer layer from the core VM
> diff --git a/mm/mmap.c b/mm/mmap.c
> index e60424b..4c01a90 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -29,16 +29,13 @@
>  #include <linux/rmap.h>
>  #include <linux/mmu_notifier.h>
>  #include <linux/perf_counter.h>
> +#include <linux/checkpoint.h>
> 
>  #include <asm/uaccess.h>
>  #include <asm/cacheflush.h>
>  #include <asm/tlb.h>
>  #include <asm/mmu_context.h>
> 
> -#include <linux/checkpoint_types.h>
> -#include <linux/checkpoint_hdr.h>
> -#include <linux/checkpoint.h>
> -
>  #include "internal.h"
> 
>  #ifndef arch_mmap_check
> diff --git a/mm/shmem.c b/mm/shmem.c
> index e123ec2..9334810 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -30,9 +30,6 @@
>  #include <linux/module.h>
>  #include <linux/swap.h>
>  #include <linux/ima.h>
> -
> -#include <linux/checkpoint_types.h>
> -#include <linux/checkpoint_hdr.h>
>  #include <linux/checkpoint.h>
> 
>  static struct vfsmount *shm_mnt;
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
