From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: [PATCH 0/3][V2] remove the ns_cgroup
Date: Mon, 27 Sep 2010 12:14:10 +0200
Message-ID: <1285582453-6127-1-git-send-email-daniel.lezcano@free.fr>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

The ns_cgroup is a control group interacting with the namespaces.
When a new namespace is created, a corresponding cgroup is 
automatically created too. The cgroup name is the pid of the process
who did 'unshare' or the child of 'clone'.

This cgroup is tied with the namespace because it prevents a
process to escape the control group and use the post_clone callback,
so the child cgroup inherits the values of the parent cgroup.

Unfortunately, the more we use this cgroup and the more we are facing
problems with it:

 (1) when a process unshares, the cgroup name may conflict with a previous
 cgroup with the same pid, so unshare or clone return -EEXIST

 (2) the cgroup creation is out of control because there may have an
 application creating several namespaces where the system will automatically
 create several cgroups in his back and let them on the cgroupfs (eg. a vrf
 based on the network namespace).

 (3) the mix of (1) and (2) force an administrator to regularly check and
 clean these cgroups.

This patchset removes the ns_cgroup by adding a new flag to the cgroup
and the cgroupfs mount option. It enables the copy of the parent cgroup
when a child cgroup is created. We can then safely remove the ns_cgroup as
this flag brings a compatibility. We have now to manually create and add the
task to a cgroup, which is consistent with the cgroup framework.

Changelog:
=========

 * V2 
	Changed the following as Paul Menage suggested:
	* removed the clone_children flag from the cgroupfs_root
	* used the 'top_cgroup' to check if the 'clone_children' or not
	  in the mount option
	* improved the description of the patch 2/3

	* removed CONFIG_CGROUP_NS against new default configs
 * V1 
	initial post

Daniel Lezcano (3):
  cgroup : add clone_children control file
  cgroup : make the mount options parsing more accurate
  cgroup : remove the ns_cgroup

 Documentation/cgroups/cgroups.txt      |   16 ++-
 arch/arm/configs/tegra_defconfig       |    1 -
 arch/mips/configs/bcm47xx_defconfig    |    1 -
 arch/powerpc/configs/ppc6xx_defconfig  |    1 -
 arch/powerpc/configs/pseries_defconfig |    1 -
 arch/s390/defconfig                    |    1 -
 arch/sh/configs/sdk7786_defconfig      |    1 -
 arch/sh/configs/se7206_defconfig       |    1 -
 arch/sh/configs/shx3_defconfig         |    1 -
 arch/sh/configs/urquell_defconfig      |    1 -
 arch/x86/configs/i386_defconfig        |    1 -
 arch/x86/configs/x86_64_defconfig      |    1 -
 include/linux/cgroup.h                 |    7 +-
 include/linux/cgroup_subsys.h          |    6 -
 include/linux/nsproxy.h                |    9 --
 init/Kconfig                           |    9 --
 kernel/Makefile                        |    1 -
 kernel/cgroup.c                        |  243 +++++++++++++-------------------
 kernel/cpuset.c                        |    7 +-
 kernel/fork.c                          |    6 -
 kernel/ns_cgroup.c                     |  110 --------------
 kernel/nsproxy.c                       |    4 -
 22 files changed, 118 insertions(+), 311 deletions(-)
 delete mode 100644 kernel/ns_cgroup.c
