From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH 0/8] signal: Fix sending signals with siginfo
Date: Fri, 30 Jun 2017 07:36:16 -0500
Message-ID: <87bmp5y7nj.fsf_-___46637.6608972952$1498826618$gmane$org@xmission.com>
References: <87lgot2loq.fsf@xmission.com> <87zid90vye.fsf_-_@xmission.com>
	<20170615225426.GP31671@ZenIV.linux.org.uk>
	<87poe4zrs1.fsf@xmission.com>
	<CA+55aFxpv+gchzs7AYgSC8feAOV=B6mjFgBVm4Kx+83J2CNE-w@mail.gmail.com>
	<87poe3vsa9.fsf@xmission.com>
	<CALCETrX=SquyR8JZqHDNx=_FQKQo-0u9AxfdUwJs_hujVO2A-g@mail.gmail.com>
	<87h8zfua59.fsf@xmission.com>
	<CALCETrWPBn31Dye=81r2ZMainNOnDy5c_QxbU2uRjnJs0ie=Zg@mail.gmail.com>
	<87r2yjsuwl.fsf@xmission.com> <20170616191602.GA10675@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20170616191602.GA10675-K+wRfnb2/UA@public.gmane.org> (Willy Tarreau's message of "Fri,
	16 Jun 2017 21:16:02 +0200")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: linux-arch-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrei Vagin <avagin-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>, Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Pavel Emelyanov <xemul-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, Andy Lutomirski <luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Cyrill Gorcunov <gorcunov-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Willy Tarreau <w@1wt.eu>, Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org


Today sending a signal with rt_sigqueueinfo and receving it on
a signalfd does not work reliably.  The issue is that reading
a signalfd instead of returning a siginfo returns a signalfd_siginfo and
the kernel must convert from one to the other.

The kernel does not currently have the code to deduce which union
members of struct siginfo are in use.

In this patchset I fix that by introducing a new function siginfo_layout
that can look at a siginfo and report which union member of struct
nnsiginfo is in use.  Before that I clean up how we populate struct
siginfo.

The siginfo structure has two key members si_signo and si_code.  Some
si_codes are signal specific and for those it takes si_signo and si_code
to indicate the members of siginfo that are valid.  The rest of the
si_code values are signal independent like SI_USER, SI_KERNEL, SI_QUEUE,
and SI_TIMER and only si_code is needed to indicate which members of
siginfo are valid.

At least that is how POSIX documents them, and how common sense would
indicate they should function.  In practice we have been rather sloppy
about maintaining the ABI in linux and we have some exceptions.  We have
a couple of buggy architectures that make SI_USER mean something
different when combined with SIGFPE or SIGTRAP.  Worse we have
fcntl(F_SETSIG) which results in the si_codes POLL_IN, POLL_OUT,
POLL_MSG, POLL_ERR, POLL_PRI, POLL_HUP being sent with any arbitrary
signal, while the values are in a range that overlaps the signal
specific si_codes.

Thankfully the ambiguous cases are for things no sane persion would do
that so we can rectify the situtation.  AKA no one cares so we won't
cause a regression fixing it.

As part of fixing this I stop leaking the __SI_xxxx codes to userspace
and stop storing them in the high 16bits of si_code.  Making the kernel
code fundamentally simpler.  We have already confirmed that the one
application that would see this difference in kernel behavior CRIU won't
be affected by this change as it copies values verbatim from one kernel
interface to another.

Eric

Eric W. Biederman (8):
      signal/alpha: Document a conflict with SI_USER for SIGTRAP
      signal/ia64: Document a conflict with SI_USER with SIGFPE
      signal/sparc: Document a conflict with SI_USER with SIGFPE
      signal/mips: Document a conflict with SI_USER with SIGFPE
      signal/testing: Don't look for __SI_FAULT in userspace
      signal/x86: Fix SIGSYS handling in copy_siginfo_to_user32
      fcntl: Don't use ambiguous SIG_POLL si_codes
      signal: Remove kernel interal si_code magic

 arch/alpha/include/uapi/asm/siginfo.h         |   5 ++
 arch/alpha/kernel/traps.c                     |   6 +-
 arch/arm64/kernel/signal32.c                  |  23 +++---
 arch/blackfin/include/uapi/asm/siginfo.h      |  30 +++++---
 arch/frv/include/uapi/asm/siginfo.h           |   2 +-
 arch/ia64/include/uapi/asm/siginfo.h          |  19 ++---
 arch/ia64/kernel/signal.c                     |  17 ++---
 arch/ia64/kernel/traps.c                      |   4 +-
 arch/mips/include/uapi/asm/siginfo.h          |   9 ++-
 arch/mips/kernel/signal32.c                   |  19 +++--
 arch/mips/kernel/traps.c                      |   2 +-
 arch/parisc/kernel/signal32.c                 |  31 ++++----
 arch/powerpc/kernel/signal_32.c               |  20 +++--
 arch/s390/kernel/compat_signal.c              |  32 ++++----
 arch/sparc/include/uapi/asm/siginfo.h         |   7 +-
 arch/sparc/kernel/signal32.c                  |  16 ++--
 arch/sparc/kernel/traps_32.c                  |   2 +-
 arch/sparc/kernel/traps_64.c                  |   2 +-
 arch/tile/include/uapi/asm/siginfo.h          |   4 +-
 arch/tile/kernel/compat_signal.c              |  18 ++---
 arch/tile/kernel/traps.c                      |   1 -
 arch/x86/kernel/signal_compat.c               |  22 +++---
 fs/fcntl.c                                    |  13 +++-
 fs/signalfd.c                                 |  22 ++----
 include/asm-generic/siginfo.h                 |  22 +++---
 include/linux/signal.h                        |   8 ++
 include/uapi/asm-generic/siginfo.h            | 104 ++++++++++++--------------
 kernel/compat.c                               |   2 -
 kernel/exit.c                                 |   6 +-
 kernel/ptrace.c                               |   6 +-
 kernel/signal.c                               |  72 +++++++++++++-----
 tools/testing/selftests/x86/mpx-mini-test.c   |   3 +-
 tools/testing/selftests/x86/protection_keys.c |  13 ++--
 33 files changed, 302 insertions(+), 260 deletions(-)
