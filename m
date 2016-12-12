From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [GIT PULL] namespace related changes for 4.10-rc1
Date: Mon, 12 Dec 2016 13:27:19 +1300
Message-ID: <87wpf6t2jc.fsf@xmission.com>
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org


Linus,

Please pull the for-linus branch from the git tree:

   git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/user-namespace.git for-linus

   HEAD: 19339c251607a3defc7f089511ce8561936fee45 Revert "evm: Translate user/group ids relative to s_user_ns when computing HMAC"


After a lot of discussion and work we have finally reachanged a basic
understanding of what is necessary to make unprivileged mounts safe in
the presence of EVM and IMA xattrs which the last commit in this series
reflects.  While technically it is a revert the comments it adds are
important for people not getting confused in the future.  Clearing up
that confusion allows us to seriously work on unprivileged mounts of
fuse in the next development cycle.

The rest of the fixes in this set are in the intersection of user
namespaces, ptrace, and exec.  I started with the first fix which
started a feedback cycle of finding additional issues during review
and fixing them.  Culiminating in a fix for a bug that has been present
since at least Linux v1.0.

Potentially these fixes were candidates during for being merged during
the rc cycle, and are certainly backport candidates but enough little
things turned up during review and testing that I decided they should be
handled as part of the normal development process just to be certain
there were not any great surprises when it came time to backport some of
these fixes.

Eric W. Biederman (5):
      mm: Add a user_ns owner to mm_struct and fix ptrace permission checks
      ptrace: Capture the ptracer's creds not PT_PTRACE_CAP
      ptrace: Don't allow accessing an undumpable mm
      exec: Ensure mm->user_ns contains the execed files
      Revert "evm: Translate user/group ids relative to s_user_ns when computing HMAC"


 arch/alpha/kernel/ptrace.c          |  2 +-
 arch/blackfin/kernel/ptrace.c       |  4 +--
 arch/cris/arch-v32/kernel/ptrace.c  |  2 +-
 arch/ia64/kernel/ptrace.c           |  2 +-
 arch/mips/kernel/ptrace32.c         |  4 +--
 arch/powerpc/kernel/ptrace32.c      |  4 +--
 fs/exec.c                           | 21 +++++++++--
 include/linux/capability.h          |  2 ++
 include/linux/mm.h                  |  2 ++
 include/linux/mm_types.h            |  1 +
 include/linux/ptrace.h              |  4 ++-
 include/linux/sched.h               |  1 +
 kernel/capability.c                 | 36 +++++++++++++++++--
 kernel/fork.c                       |  9 +++--
 kernel/ptrace.c                     | 70 ++++++++++++++++++++++++++-----------
 mm/init-mm.c                        |  2 ++
 mm/memory.c                         |  2 +-
 mm/nommu.c                          |  2 +-
 security/integrity/evm/evm_crypto.c | 12 +++++--
 19 files changed, 139 insertions(+), 43 deletions(-)

Eric
