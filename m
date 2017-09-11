From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [GIT PULL] namespace updates for 4.14-rc1
Date: Mon, 11 Sep 2017 12:21:54 -0500
Message-ID: <87mv61cfrh.fsf__37861.3098910593$1505326953$gmane$org@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: linux-arch-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org


Linus,

Please pull the for-linus branch from the git tree:

   git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/user-namespace.git for-linus

   HEAD: 076a9bcacfc7ccbc2b3fdf3bd490718f6b182419 signal/mips: Remove FPE_FIXME usage from mips

Life has been busy and I have not gotten half as much done this round as
I would have liked.  I delayed it so that a minor conflict resolution
with the mips tree could spend a little time in linux-next before I sent
this pull request.

This pull request includes two long delayed user namespace changes from
Kirill Tkhai.  It also includes a very useful change from Serge Hallyn
that allows the security capability attribute to be used inside of user
namespaces.  The practical effect of this is people can now untar
tarballs and install rpms in user namespaces.  It had been suggested to
generalize this and encode some of the namespace information information
in the xattr name.  Upon close inspection that makes the things that
should be hard easy and the things that should be easy more expensive.

Then there is my bugfix/cleanup for signal injection that removes
the magic encoding of the siginfo union member from the kernel internal
si_code.  The mips folks reported the case where I had used FPE_FIXME me
is impossible so I have remove FPE_FIXME from mips, while at the same
time including a return statement in that case to keep gcc from
complaining about unitialized variables.

I almost finished the work to get make copy_siginfo_to_user a trivial
copy to user.  The code is available at:
   git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/user-namespace.git neuter-copy_siginfo_to_user-v3
But I did not have time/energy to get the code posted and reviewed before
the merge window opened.

I was able to see that the security excuse for just copying fields that
we know are initialized doesn't work in practice there are buggy
initializations that don't initialize the proper fields in siginfo.  So
we still sometimes copy unitialized data to userspace.

Eric W. Biederman (11):
      signal/alpha: Document a conflict with SI_USER for SIGTRAP
      signal/ia64: Document a conflict with SI_USER with SIGFPE
      signal/sparc: Document a conflict with SI_USER with SIGFPE
      signal/mips: Document a conflict with SI_USER with SIGFPE
      signal/testing: Don't look for __SI_FAULT in userspace
      userns,pidns: Verify the userns for new pid namespaces
      fcntl: Don't use ambiguous SIG_POLL si_codes
      signal: Remove kernel interal si_code magic
      signal: Fix sending signals with siginfo
      mips/signal: In force_fcr31_sig return in the impossible case
      signal/mips: Remove FPE_FIXME usage from mips

Kirill Tkhai (2):
      security: Use user_namespace::level to avoid redundant iterations in cap_capable()
      prctl: Allow local CAP_SYS_ADMIN changing exe_file

Serge E. Hallyn (1):
      Introduce v3 namespaced file capabilities


 arch/alpha/include/uapi/asm/siginfo.h         |  14 ++
 arch/alpha/kernel/traps.c                     |   6 +-
 arch/arm64/kernel/signal32.c                  |  23 +--
 arch/blackfin/include/uapi/asm/siginfo.h      |  30 ++-
 arch/frv/include/uapi/asm/siginfo.h           |   2 +-
 arch/ia64/include/uapi/asm/siginfo.h          |  21 +-
 arch/ia64/kernel/signal.c                     |  17 +-
 arch/ia64/kernel/traps.c                      |   4 +-
 arch/mips/include/uapi/asm/siginfo.h          |   4 +-
 arch/mips/kernel/signal32.c                   |  19 +-
 arch/mips/kernel/traps.c                      |   2 +-
 arch/parisc/kernel/signal32.c                 |  31 ++-
 arch/powerpc/kernel/signal_32.c               |  20 +-
 arch/s390/kernel/compat_signal.c              |  32 ++-
 arch/sparc/include/uapi/asm/siginfo.h         |   9 +-
 arch/sparc/kernel/signal32.c                  |  16 +-
 arch/sparc/kernel/traps_32.c                  |   2 +-
 arch/sparc/kernel/traps_64.c                  |   2 +-
 arch/tile/include/uapi/asm/siginfo.h          |   4 +-
 arch/tile/kernel/compat_signal.c              |  18 +-
 arch/tile/kernel/traps.c                      |   2 +-
 arch/x86/kernel/signal_compat.c               |  21 +-
 fs/fcntl.c                                    |  13 +-
 fs/signalfd.c                                 |  22 +-
 fs/xattr.c                                    |   6 +
 include/linux/capability.h                    |   2 +
 include/linux/security.h                      |   2 +
 include/linux/signal.h                        |  22 ++
 include/linux/user_namespace.h                |   9 +-
 include/uapi/asm-generic/siginfo.h            | 115 +++++------
 include/uapi/linux/capability.h               |  22 +-
 kernel/exit.c                                 |   4 +-
 kernel/pid_namespace.c                        |   4 +
 kernel/ptrace.c                               |   6 +-
 kernel/signal.c                               |  72 +++++--
 kernel/sys.c                                  |   8 +-
 kernel/user_namespace.c                       |  20 +-
 security/commoncap.c                          | 277 ++++++++++++++++++++++++--
 tools/testing/selftests/x86/mpx-mini-test.c   |   3 +-
 tools/testing/selftests/x86/protection_keys.c |  13 +-
 40 files changed, 622 insertions(+), 297 deletions(-)

Eric
