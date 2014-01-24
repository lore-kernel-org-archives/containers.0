From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [GIT PULL] user namespaces work for 3.14-rc1
Date: Fri, 24 Jan 2014 14:58:45 -0800
Message-ID: <8761p9rnq2.fsf@xmission.com>
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

   HEAD: f58437f1f9161847c636e4fed5569ed5b908af36 MIPS: VPE: Remove vpe_getuid and vpe_getgid

The work to convert the kernel to use kuid_t and kgid_t has been
finished since 3.12 so it is time to remove the scaffolding that allowed
the work to progress incrementally.

The first patch on this branch just removes the scaffolding, ensuring we
will always get compile errors if people accidentally try the userspace
and the kernel uid and gid types.  The second patch an overlooked and
unused chunk of mips code that that fails to build after the first
patch.

The code hasn't been in linux-next for long (as I was out of it and could
not sheppared the cold properly) but the patch has been around for a
long time just waiting for the day when I had finished the uid/gid
conversions.  Putting the code in linux-next did find the compile
failure on mips so I took the time to get that fix reviewed and
included.  Beyond that I am not too worried about errors because all
these two patches do is delete a modest amount of code.

Eric


Eric W. Biederman (2):
      userns:  userns: Remove UIDGID_STRICT_TYPE_CHECKS
      MIPS: VPE: Remove vpe_getuid and vpe_getgid

 arch/mips/include/asm/vpe.h |    2 --
 arch/mips/kernel/vpe.c      |   28 ----------------------------
 include/linux/posix_acl.h   |    3 ---
 include/linux/projid.h      |   15 ---------------
 include/linux/uidgid.h      |   22 ----------------------
 init/Kconfig                |   11 -----------
 6 files changed, 0 insertions(+), 81 deletions(-)
