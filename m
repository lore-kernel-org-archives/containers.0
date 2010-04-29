From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] ARM: Added user space support for c/r on ARM
Date: Thu, 29 Apr 2010 16:33:46 -0700
Message-ID: <20100429233346.GZ32490__34503.457012079$1272584072$gmane$org@count0.beaverton.ibm.com>
References: <1269220484-24279-1-git-send-email-christofferdall@christofferdall.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1269220484-24279-1-git-send-email-christofferdall-77OGu6e99YhyO3AAkE1OcX9LOBIZ5rWg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Christoffer Dall <christofferdall-77OGu6e99YhyO3AAkE1OcX9LOBIZ5rWg@public.gmane.org>
Cc: containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, libc-ports <libc-ports-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org>
List-Id: containers.vger.kernel.org

On Sun, Mar 21, 2010 at 09:14:44PM -0400, Christoffer Dall wrote:
> General
> --------
> 
> This is a first attempt to add C/R support for ARM. There are a number
> of annoying changes in the extract-headers.sh and clone.h files due to
> the way syscall numbers are defined on the ARM architecture.

<snip>

> diff --git a/scripts/extract-headers.sh b/scripts/extract-headers.sh
> index 8c8ae69..aacb6af 100755
> --- a/scripts/extract-headers.sh
> +++ b/scripts/extract-headers.sh
> @@ -144,7 +144,25 @@ echo '#endif /* _CHECKPOINT_CKPT_HDR_H_ */' >> "${OUTPUT_INCLUDES}/linux/checkpo
>  # We use ARCH_COND to break up architecture-specific sections of the header.
>  #
>  ARCH_COND='#if'
> -REGEX='[[:space:]]*#[[:space:]]*define[[:space:]]*__NR_(checkpoint|restart|clone_with_pids)[[:space:]]+[0-9]+'

Just a heads up in case there's a merge conflict later:

I think I need to submit a patch which does s/clone_with_pids// since
eclone.h and the respective clone_*.* arch files define NR_eclone anyway.

> +ARM_SYSCALL_BASE="#	define __NR_OABI_SYSCALL_BASE 0x900000\n\
> +#	if defined(__thumb__) || defined(__ARM_EABI__)\n\
> +#		define __NR_SYSCALL_BASE	0\n\
> +#	else\n\
> +#		define __NR_SYSCALL_BASE	__NR_OABI_SYSCALL_BASE\n\
> +#	endif\n"
> +
> +# Get the regular expression for the current architecture
> +function get_unistd_regex()
> +{

You could decompose the regex and make it easy to see what's so special
about ARM syscall nrs:

	local SYS_NR_DEF_REGEX='[[:space:]]*#[[:space:]]*define[[:space:]]*__NR_(checkpoint|restart|clone_with_pids)[[:space:]]+'

> +	case "$1" in
> +	arm)	echo -n '[[:space:]]*#[[:space:]]*define[[:space:]]*__NR_(checkpoint|restart|clone_with_pids)[[:space:]]+'

		echo -n "${SYS_NR_DEF_REGEX}"'\(__NR_SYSCALL_BASE\+[[:space:]]*[0-9]*\)'
> +		;;
> +	*)	echo -n '[[:space:]]*#[[:space:]]*define[[:space:]]*__NR_(checkpoint|restart|clone_with_pids)[[:space:]]+[0-9]+'

		echo -n "${SYS_NR_DEF_REGEX}"'[0-9]+'

> +		;;
> +	esac
> +	return 0
> +}
> 
>  cat - <<-EOFOE
>  /*
> @@ -160,11 +178,13 @@ do_cpp "${KERNELSRC}/include/linux/checkpoint.h" "_LINUX_CHECKPOINT_H_"
>  find "${KERNELSRC}/arch" -name 'unistd*.h' -print | sort | \
>  while read UNISTDH ; do
>  	[ -n "${UNISTDH}" ] || continue
> -	grep -q -E "${REGEX}" "${UNISTDH}" || continue
>  	KARCH=$(echo "${UNISTDH}" | sed -e 's|.*/arch/\([^/]\+\)/.*|\1|')
> +	REGEX="$(get_unistd_regex "${KARCH}")"
> +	grep -q -E "${REGEX}" "${UNISTDH}" || continue
>  	WORDBITS=$(basename "${UNISTDH}" | sed -e 's/unistd_*\([[:digit:]]\+\)\.h/\1/')
>  	CPPARCH="$(karch_to_cpparch "${KARCH}" "${WORDBITS}")"
>  	echo -e "${ARCH_COND} __${CPPARCH}__\\n"
> +	[ "${KARCH}" == "arm" ] && echo -e "${ARM_SYSCALL_BASE}\n"

nit:

I can see what you're trying to do but this introduces arch-specific code
in the middle of nicely arch-generic code. Currently, as you've done with
get_unistd_regex, we've nicely encapsulated those pieces into functions.

Perhaps adding blank lines above and below this is sufficient since I
can't think of an arch-generic function which would be appropriate here.

>  	grep -E "${REGEX}" "${UNISTDH}" | \
>  	sed -e 's/^[ \t]*#[ \t]*define[ \t]*__NR_\([^ \t]\+\)[ \t]\+\([^ \t]\+\).*$/#\tifndef __NR_\1\n#\t\tdefine __NR_\1 \2\n#\tendif\n/'
>  	ARCH_COND='#elif'
> diff --git a/test/Makefile b/test/Makefile
> index cad40e0..516eee8 100644
> --- a/test/Makefile
> +++ b/test/Makefile
> @@ -1,3 +1,9 @@
> +# handle cross-compilation
> +AR = ${CROSS_COMPILE}ar
> +AS = ${CROSS_COMPILE}as
> +CC = ${CROSS_COMPILE}gcc
> +CPP = ${CROSS_COMPILE}cpp
> +LD = ${CROSS_COMPILE}ld

GNU Make nit: I prefer the :=, or simple assignment, operator. Both = and :=
(amongst others) expand the values of variables. However = is "recursive"
and the right-hand side is evaluated multiple times -- I think
everywhere the variable on the left-hand side is used. In contrast the
right-hand side of := is evaluated everywhere the left-hand side is defined
(usually once). This is faster and non-recursive. See
"The Two Flavors of Variables" in the GNU Make info file for a more rigorous
discussion of the differences.

Cheers,
	-Matt Helsley
