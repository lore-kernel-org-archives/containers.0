From: Zhao Lei <zhaolei-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH v2 0/3] Make core_pattern support namespace
Date: Fri, 18 Mar 2016 20:48:32 +0800
Message-ID: <cover.1458305141.git.zhaolei@cn.fujitsu.com>
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
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

We discussed patch titled:
 [PATCH] Make core_pattern support namespace
before.

Above patch can solve half problem of custom core_dump pattern
in container, but there are also another problem that limit
custom core_pattern in container, it is the pipe-type core_pattern
will write core dump into host's filesystem.
(See discussion of that patch for detail)

Now we can solve the second problem by [PATCH 2/3], I send
the origional patch with it.

Changelog v1->v2:
1: Fix compile fail in xtensa which is reported by
   kbuild test robot <lkp-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
2: Use a wapper to avoid calling _do_fork() outside kernel/fork.c,
   suggested by: Kamezawa Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>

Zhao Lei (3):
  Make _do_fork support return to caller's code
  Run dump pipe in container's namespace
  Make core_pattern support namespace

 arch/alpha/kernel/process.c         |  4 +-
 arch/arc/kernel/process.c           |  4 +-
 arch/arm/kernel/process.c           |  4 +-
 arch/arm64/kernel/process.c         |  5 ++-
 arch/avr32/kernel/process.c         |  5 ++-
 arch/blackfin/kernel/process.c      |  5 ++-
 arch/c6x/kernel/process.c           |  5 ++-
 arch/cris/arch-v10/kernel/process.c |  4 +-
 arch/cris/arch-v32/kernel/process.c |  4 +-
 arch/frv/kernel/process.c           |  4 +-
 arch/h8300/kernel/process.c         |  4 +-
 arch/hexagon/kernel/process.c       |  4 +-
 arch/ia64/kernel/process.c          |  4 +-
 arch/m32r/kernel/process.c          |  4 +-
 arch/m68k/kernel/process.c          |  4 +-
 arch/metag/kernel/process.c         |  5 ++-
 arch/microblaze/kernel/process.c    |  4 +-
 arch/mips/kernel/process.c          |  4 +-
 arch/mn10300/kernel/process.c       |  4 +-
 arch/nios2/kernel/process.c         |  5 ++-
 arch/openrisc/kernel/process.c      |  4 +-
 arch/parisc/kernel/process.c        |  5 ++-
 arch/powerpc/kernel/process.c       |  5 ++-
 arch/s390/kernel/process.c          |  4 +-
 arch/score/kernel/process.c         |  4 +-
 arch/sh/kernel/process_32.c         |  4 +-
 arch/sh/kernel/process_64.c         |  4 +-
 arch/sparc/kernel/process_32.c      |  4 +-
 arch/sparc/kernel/process_64.c      |  4 +-
 arch/tile/kernel/process.c          |  4 +-
 arch/um/kernel/process.c            | 22 ++++++-----
 arch/unicore32/kernel/process.c     |  4 +-
 arch/x86/kernel/process_32.c        |  5 ++-
 arch/x86/kernel/process_64.c        |  5 ++-
 arch/xtensa/kernel/process.c        |  5 ++-
 fs/coredump.c                       | 79 ++++++++++++++++++++++---------------
 include/linux/pid_namespace.h       |  2 +
 include/linux/sched.h               | 12 +++---
 kernel/fork.c                       | 30 +++++++++-----
 kernel/pid.c                        |  1 +
 kernel/pid_namespace.c              |  3 ++
 kernel/sysctl.c                     | 22 ++++++++---
 42 files changed, 187 insertions(+), 131 deletions(-)

-- 
1.8.5.1
