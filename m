From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [GIT PULL] nsfd fixes
Date: Tue, 21 Jun 2011 15:07:02 -0700
Message-ID: <m162nyn8jd.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org


Linus,

When looking over my namespace file descriptor code I realized I goofed
in the implementation.  I missed the addition of d_set_d_op, and
painfully I badly placed the ptrace_may_read permission checks with the
result that the dcache could cache things and bypass the checks.

The fixes are available at.
git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/linux-2.6-nsfd.git


Eric W. Biederman (2):
      proc: Use d_set_d_op in the namespace file descriptor code
      proc: Fix the proc access checks to namespace files.

 fs/proc/inode.c      |    6 +-
 fs/proc/namespaces.c |  160 +++++++++++++++++++++++++++++++++++++++++++-------
 2 files changed, 142 insertions(+), 24 deletions(-)


commit 7e05c935c50ab5c9ee488c411252076825ec2919
Author: Eric W. Biederman <ebiederm@xmission.com>
Date:   Sat Jun 18 17:48:18 2011 -0700

    proc: Fix the proc access checks to namespace files.
    
    Access to namespace files needs to be restricted with
    ptrace_may_read in proc to avoid unecessary information leaks
    about processes and to avoid processes that could not otherwise
    extend the lifetime of a namespace from opening a namespace file
    and extending that lifetime.
    
    Add magic symlinks to the namespace files, so that we won't cache
    the dentries for the namespace files in a way that can bypass the
    ptrace_may_access checks.
    
    Remove the accident of the initial implementation that made
    namespace files depend on pids and tasks, and change the
    namespace files to be their own entities with their own dentry
    and inode operations. The new namespace dentry operations
    specify a policy of not caching namespace dentries when not in
    use.  Not caching unused namespace dentries makes it easy to
    verify the dcache won't keep namespaces alive longer than
    necessary.
    
    Change the owner of namespace files to root as derving the
    ownership of namespace files from a process is no longer possible
    as namespace files are no longer implemented as per process
    entities.  Namespace files being read only as root is safe and
    changes nothing in practice as the kernel interfaces that take
    namespace file descriptors require root capabilities.
    
    Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>

commit b20c223833c931700f88ec53a54e2f95d0e01052
Author: Eric W. Biederman <ebiederm@xmission.com>
Date:   Sat Jun 18 23:34:09 2011 -0700

    proc: Use d_set_d_op in the namespace file descriptor code
    
    Without this none of the pid_dentry_operations methods will
    be called and we can slowly leak namespace file descriptors.
    
    Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
