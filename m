From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 0/7] checkpoint: Kconfig cleanup, powerpc support
Date: Mon, 30 Mar 2009 10:57:09 -0400
Message-ID: <49D0DDC5.2030601@cs.columbia.edu>
References: <1238022166-13422-1-git-send-email-ntl@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1238022166-13422-1-git-send-email-ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
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


Thanks, Nathan.

I added these to the patch-set for the next version.


Nathan Lynch wrote:
> The following series, based on Oren's ckpt-v14 branch, improves the
> Kconfig situation wrt architecture support and adds the powerpc
> implementation.
> 
> Nathan Lynch (7):
>   s390: enable checkpoint support in Kconfig
>   x86: enable checkpoint support in Kconfig
>   make CONFIG_CHECKPOINT depend on CONFIG_CHECKPOINT_SUPPORT
>   powerpc: provide APIs for validating and updating DABR
>   powerpc: checkpoint/restart implementation
>   powerpc: wire up checkpoint and restart syscalls
>   powerpc: enable checkpoint support in Kconfig
> 
>  arch/powerpc/Kconfig                      |    3 +
>  arch/powerpc/include/asm/checkpoint_hdr.h |   15 +
>  arch/powerpc/include/asm/ptrace.h         |    7 +
>  arch/powerpc/include/asm/systbl.h         |    2 +
>  arch/powerpc/include/asm/unistd.h         |    4 +-
>  arch/powerpc/kernel/ptrace.c              |   88 ++++--
>  arch/powerpc/mm/Makefile                  |    1 +
>  arch/powerpc/mm/checkpoint.c              |  481 +++++++++++++++++++++++++++++
>  arch/s390/Kconfig                         |    4 +
>  arch/x86/Kconfig                          |    4 +
>  checkpoint/Kconfig                        |    2 +-
>  11 files changed, 580 insertions(+), 31 deletions(-)
>  create mode 100644 arch/powerpc/include/asm/checkpoint_hdr.h
>  create mode 100644 arch/powerpc/mm/checkpoint.c
> 
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
> 
