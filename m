From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 18/30] cr: restore vDSO on i386/x86_64
Date: Thu, 16 Apr 2009 10:27:39 -0500
Message-ID: <20090416152739.GA19712__1731.6865305931$1239895840$gmane$org@us.ibm.com>
References: <20090410023752.GS27788@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090410023752.GS27788-2ev+ksY9ol182hYKe6nXyg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Alexey Dobriyan (adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org):
> FIXME: check VMA has same parameters.
> FIXME: abort if target kernel has vDSO disabled (?)
> FIXME: restore pages, vDSO is writable after all.
> 
> Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
> 
>  arch/x86/vdso/vdso32-setup.c |    6 ++
>  include/linux/cr.h           |   11 +++++
>  include/linux/mm.h           |    5 +-
>  kernel/cr/cr-mm.c            |   87 +++++++++++++++++++++++++++++++++++++++++++
>  mm/mmap.c                    |    3 +
>  5 files changed, 110 insertions(+), 2 deletions(-)
> 
> --- a/arch/x86/vdso/vdso32-setup.c
> +++ b/arch/x86/vdso/vdso32-setup.c
> @@ -328,6 +328,10 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, unsigned long start,
> 
>  	map_compat_vdso(compat);
> 
> +	if (start) {
> +		addr = start;
> +		goto map;
> +	}

Hmm, is there any safety to be gained by using
	arch_get_unmapped_area(NULL, start, PAGE_SIZE, 0, 0);
so as to make sure there is a free page?

>  	if (compat)
>  		addr = VDSO_HIGH_BASE;
>  	else {
> @@ -337,7 +341,7 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, unsigned long start,
>  			goto up_fail;
>  		}
>  	}
> -
> +map:
>  	if (compat_uses_vma || !compat) {
>  		/*
>  		 * MAYWRITE to allow gdb to COW and set breakpoints

thanks,
-serge
