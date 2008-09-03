From: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/9] Introduce trivial sys_checkpoint and sys_restore
	system	calls
Date: Wed, 03 Sep 2008 13:44:05 +0200
Message-ID: <48BE7885.3070609__26520.1780865484$1220442426$gmane$org@fr.ibm.com>
References: <1220439476-16465-1-git-send-email-major@openvz.org>
	<1220439476-16465-2-git-send-email-major@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1220439476-16465-2-git-send-email-major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Andrey Mirkin wrote:
> Right now they just return -ENOSYS. Later they will provide functionality
> to checkpoint and restart a container.
> 
> Both syscalls take as arguments a file descriptor and flags.
> Also sys_checkpoint take as the first argument a PID of container's init
> (later it will be container ID); sys_restart takes as the first argument
> a container ID (right now it will not be used).
> 
> Signed-off-by: Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
> ---
>  Makefile                           |    2 +-
>  arch/x86/kernel/syscall_table_32.S |    2 +
>  cpt/Makefile                       |    1 +
>  cpt/sys_core.c                     |   38 ++++++++++++++++++++++++++++++++++++
>  include/asm-x86/unistd_32.h        |    2 +
>  5 files changed, 44 insertions(+), 1 deletions(-)
>  create mode 100644 cpt/Makefile
>  create mode 100644 cpt/sys_core.c
> 
> diff --git a/Makefile b/Makefile
> index ea413fa..1dee5c0 100644
> --- a/Makefile
> +++ b/Makefile
> @@ -619,7 +619,7 @@ export mod_strip_cmd
>  
>  
>  ifeq ($(KBUILD_EXTMOD),)
> -core-y		+= kernel/ mm/ fs/ ipc/ security/ crypto/ block/
> +core-y		+= kernel/ mm/ fs/ ipc/ security/ crypto/ block/ cpt/
>  
>  vmlinux-dirs	:= $(patsubst %/,%,$(filter %/, $(init-y) $(init-m) \
>  		     $(core-y) $(core-m) $(drivers-y) $(drivers-m) \
> diff --git a/arch/x86/kernel/syscall_table_32.S b/arch/x86/kernel/syscall_table_32.S
> index fd9d4f4..4a0d7fb 100644
> --- a/arch/x86/kernel/syscall_table_32.S
> +++ b/arch/x86/kernel/syscall_table_32.S
> @@ -333,3 +333,5 @@ ENTRY(sys_call_table)
>  	.long sys_pipe2
>  	.long sys_inotify_init1
>  	.long sys_hijack
> +	.long sys_checkpoint
> +	.long sys_restart		/* 335 */

this patchset is based on top of :

git://git.kernel.org/pub/scm/linux/kernel/git/daveh/linux-2.6-lxc.git

right ?

C.
