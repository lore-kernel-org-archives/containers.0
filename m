From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 0/9] powerpc checkpoint/restart kernel support
Date: Wed, 16 Sep 2009 11:11:04 -0400
Message-ID: <4AB10008.8040401@librato.com>
References: <1253091418-14807-1-git-send-email-ntl@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1253091418-14807-1-git-send-email-ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
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

Thanks Nathan,

I'll apply the general fixes right away.

I'm about to push ckpt-v18-rc1 today. Would you like that to include
the remaining patches as well ?

Oren.


Nathan Lynch wrote:
> Patches 1-3 fix general issues and can be applied immediately.
> 
> Patches 4-8 implement the checkpoint and restart syscalls and
> architecture callbacks.
> 
> Patch 9 implements the clone_with_pids syscall, but I think the shape
> of that interface is yet to be finalized, so I guess it's FYI for now.
> 
> Simple single task checkpoint and restart work, as does
> clone_with_pids, apparently.  Multiple task restart fails; the
> coordinator task appears to be receiving a signal during
> wait_all_tasks_finish() -> wait_for_completion_interruptible() for
> some reason I am still trying to tracking down.
> 
> Nathan Lynch (9):
>   checkpoint: fix integer-pointer conversion warnings
>   fix trivial build breaks in compat code
>   futex.h: fix compat builds
>   powerpc: reserve checkpoint arch identifiers
>   powerpc: provide APIs for validating and updating DABR
>   powerpc: checkpoint/restart implementation
>   powerpc: wire up checkpoint and restart syscalls
>   powerpc: enable checkpoint support in Kconfig
>   powerpc: clone_with_pids implementation
> 
>  arch/powerpc/Kconfig                      |    3 +
>  arch/powerpc/include/asm/Kbuild           |    1 +
>  arch/powerpc/include/asm/checkpoint_hdr.h |   22 ++
>  arch/powerpc/include/asm/ptrace.h         |    7 +
>  arch/powerpc/include/asm/syscalls.h       |    4 +
>  arch/powerpc/include/asm/systbl.h         |    3 +
>  arch/powerpc/include/asm/unistd.h         |    5 +-
>  arch/powerpc/kernel/entry_32.S            |    8 +
>  arch/powerpc/kernel/entry_64.S            |    5 +
>  arch/powerpc/kernel/process.c             |   18 +
>  arch/powerpc/kernel/ptrace.c              |   88 ++++--
>  arch/powerpc/mm/Makefile                  |    1 +
>  arch/powerpc/mm/checkpoint.c              |  531 +++++++++++++++++++++++++++++
>  checkpoint/process.c                      |   14 +-
>  include/linux/checkpoint_hdr.h            |    2 +
>  include/linux/futex.h                     |    4 +
>  16 files changed, 679 insertions(+), 37 deletions(-)
>  create mode 100644 arch/powerpc/include/asm/checkpoint_hdr.h
>  create mode 100644 arch/powerpc/mm/checkpoint.c
> 
