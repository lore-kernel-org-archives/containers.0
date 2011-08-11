From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: [PATCH 0/2] Send a SIGCHLD to the init's pid namespace parent when
	reboot
Date: Thu, 11 Aug 2011 22:23:59 +0200
Message-ID: <1313094241-3674-1-git-send-email-daniel.lezcano__22068.559859372$1313094508$gmane$org@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, bonbons-ud5FBsm0p/xEiooADzr8i9i2O/JbrIOy@public.gmane.org, oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>

In the case of a VPS, when we shutdown/halt/reboot the container, the
reboot utility will invoke the sys_reboot syscall which has the bad
effect to reboot the host. The way to fix that is to drop the
CAP_SYS_REBOOT capability in the container.

In this case, the container shutdowns correctly but, at the end, the
init process is waiting indefinitely and we have the containers stuck
with one process (the init process).

In order to fix that, we used a hypervisor process, parent of the
container's init process, watching for the container's utmp file and
detecting when the runlevel changes. When this runlevel change is
detected we wait for the container to have one process left and then we
kill the container's init.

That works well if we modify the distro configuration files, we make
/var/run to not be a tmpfs and we remove all the files inside this
directory when the container boots. *But* as soon as we upgrade the
container distro, all the tweaks are lost. So this method works but at
the cost of tweaking the containers configuration files again and again,
each time there is an update, which is not tolerable in a production
environment.

This patchset solves the problem by send a SIGCHLD signal to the process
parent of the init process of the child pid namespace. By this way, we know
when a pid namespace wanted to reboot/halt/shutdown and we can take advantage
of that to kill, restart or suspend the container.

Daniel Lezcano (2):
  add SA_CLDREBOOT flag
  Notify container-init parent a 'reboot' occured

 arch/alpha/include/asm/signal.h   |    2 +
 arch/arm/include/asm/signal.h     |    2 +
 arch/avr32/include/asm/signal.h   |    2 +
 arch/cris/include/asm/signal.h    |    2 +
 arch/h8300/include/asm/signal.h   |    2 +
 arch/ia64/include/asm/signal.h    |    2 +
 arch/m32r/include/asm/signal.h    |    2 +
 arch/m68k/include/asm/signal.h    |    2 +
 arch/mips/include/asm/signal.h    |    2 +
 arch/mn10300/include/asm/signal.h |    2 +
 arch/parisc/include/asm/signal.h  |    2 +
 arch/powerpc/include/asm/signal.h |    2 +
 arch/s390/include/asm/signal.h    |    2 +
 arch/sparc/include/asm/signal.h   |    2 +-
 arch/x86/include/asm/signal.h     |    2 +
 arch/xtensa/include/asm/signal.h  |    2 +
 include/asm-generic/siginfo.h     |    3 +-
 include/asm-generic/signal.h      |    2 +
 include/linux/sched.h             |    1 +
 kernel/signal.c                   |   40 +++++++++++++++++++++++++++++++++++++
 kernel/sys.c                      |   20 ++++++++++++++++-
 21 files changed, 94 insertions(+), 4 deletions(-)

-- 
1.7.4.1
