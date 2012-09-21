From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [REVIEW][PATCH 00/14] userns: Miscelanous conversions
Date: Thu, 20 Sep 2012 17:26:52 -0700
Message-ID: <87k3vote43.fsf__39789.6494171166$1348187234$gmane$org@xmission.com>
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
To: linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org


The following patchset contains conversion for basic user namespace
support for the security modules and a few miscelaneous other things.

I am placing these patches up for review before I add them to
linux-next.

Please holler if it looks if you see something scary.

The following patchset is against
git.kernel.org/pub/scm/linux/kernel/git/ebiederm/user-namespace.git for-next
which is based on v3.6-rc1

Eric

Eric W. Biederman (14):
      userns: Convert loop to use kuid_t instead of uid_t
      userns: Convert apparmor to use kuid and kgid where appropriate
      userns: Convert tomoyo to use kuid and kgid where appropriate
      userns: Convert selinux to use kuid and kgid where appropriate
      userns: Convert hostfs to use kuid and kgid where appropriate
      userns: Convert EVM to deal with kuids and kgids in it's hmac computation
      userns: Add user namespace support to IMA
      userns: Teach security_path_chown to take kuids and kgids
      userns: Convert binder ipc to use kuids
      userns: Convert s390 hypfs to use kuid and kgid where appropriate
      userns: Convert s390 getting uid and gid system calls to use kuid and kgid
      userns: On ppc convert current_uid from a kuid before printing.
      userns: On ia64 deal with current_uid and current_gid being kuid and kgid
      userns: On alpha modify linux_to_osf_stat to use convert from kuids and kgids

 arch/alpha/kernel/osf_sys.c         |    4 +-
 arch/ia64/kernel/mca_drv.c          |    3 +-
 arch/ia64/kernel/perfmon.c          |   32 +++++++++++++++---------------
 arch/ia64/kernel/signal.c           |    4 +-
 arch/powerpc/mm/fault.c             |    2 +-
 arch/s390/hypfs/inode.c             |   20 +++++++++++++-----
 arch/s390/kernel/compat_linux.c     |   36 +++++++++++++++++++++++-----------
 drivers/block/loop.c                |    4 +-
 drivers/staging/android/binder.c    |   14 ++++++------
 fs/hostfs/hostfs_kern.c             |    8 +++---
 fs/open.c                           |    2 +-
 include/linux/loop.h                |    2 +-
 include/linux/security.h            |    6 ++--
 init/Kconfig                        |   15 --------------
 security/apparmor/domain.c          |    4 +-
 security/apparmor/file.c            |   12 ++++++----
 security/apparmor/include/audit.h   |    2 +-
 security/apparmor/include/file.h    |    4 +-
 security/apparmor/lsm.c             |    2 +-
 security/capability.c               |    2 +-
 security/integrity/evm/evm_crypto.c |    4 +-
 security/integrity/ima/ima_audit.c  |    5 ++-
 security/integrity/ima/ima_policy.c |   14 ++++++------
 security/security.c                 |    2 +-
 security/selinux/selinuxfs.c        |    6 ++--
 security/selinux/ss/services.c      |    2 +-
 security/tomoyo/audit.c             |   23 +++++++++++++++------
 security/tomoyo/common.c            |    4 ++-
 security/tomoyo/common.h            |    4 +-
 security/tomoyo/condition.c         |   20 +++++++++---------
 security/tomoyo/tomoyo.c            |   12 ++++++----
 31 files changed, 148 insertions(+), 126 deletions(-)
