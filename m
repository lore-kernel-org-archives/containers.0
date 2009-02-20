From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: lxc : linux containers tool 0.6.0 release
Date: Fri, 20 Feb 2009 16:04:19 +0100
Message-ID: <499EC673.8020808@fr.ibm.com>
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
To: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi All,

A new version of the liblxc has been released, lxc-0.6.0.

This version provides a new set of features:

  * take into account the devpts new instance
  * we can log to the container with the tty, lxc-console
  * we can use a directory or a block device as a rootfs
  * lxc-debian script build a lenny debian
  * various fix and improvement

One important information:
==========================

*** lxc will no longer need a patched kernel, all the kernel features 
are available in the 2.6.29 kernel ***

Thanks for the contributions and the feedbacks.

Below a detailed log of the modifications:



2009-02-20 15:13  dlezcano

	* scripts/lxc-debian.in: Add the pts configuration for lxc-debian
	  From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>

	  Add the pts configuration when creating a debian container.

	  Signed-off-by: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>

2009-02-16 12:25  dlezcano

	* src/lxc/: parse.c, parse.h: Add missing files to CVS

2009-02-16 11:22  dlezcano

	* src/lxc/: Makefile.am, lxc_conf.c, lxc_config.c, lxc_unshare.c:
	  Factor out some code From: Daniel Lezcano
	  <daniel.lezcano-GANU6spQydw@public.gmane.org>

	  Factor out some code and especially the parsing of text file
	  functions.

	  Signed-off-by: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>

2009-02-16 11:21  dlezcano

	* src/lxc/lxc_conf.c: Support block device for the rootfs From:
	  Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>

	  Allow to specify a block device as the rootfs. The creation of
	  the container will try with brute force to determine the file
	  system type.

	  Signed-off-by: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>

2009-02-16 11:19  dlezcano

	* lxc.spec.in, src/lxc/Makefile.am: Add more capabilities From:
	  Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>

	  lxc-execute and lxc-create need capability to mount.

	  Signed-off-by: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>

2009-02-16 11:14  dlezcano

	* src/lxc/lxc_conf.c: Make use of realpath From: Daniel Lezcano
	  <daniel.lezcano-GANU6spQydw@public.gmane.org>

	  The realpath function is more convenient to build the absolute
	  path of the rootfs.

	  Signed-off-by: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>

2009-02-16 11:13  dlezcano

	* src/lxc/lxc_conf.c: Mount bind the rootfs directory From: Daniel
	  Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>

	  Instead of using a symlink to the rootfs, just mount bind the
	  rootfs directory.

	  Signed-off-by: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>

2009-02-16 11:11  dlezcano

	* scripts/lxc-debian.in: Remove some pointless debian services
	  From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>

	  Remove some debian services because they don't have sense in a
	  container, like the hw clock or the unmount of the file systems.

	  Signed-off-by: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>

2009-02-12 15:48  dlezcano

	* doc/lxc.conf.sgml.in: Update the man according new devpts
	  instance From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>

	  Update the man page with the new devpts instance option.

	  Signed-off-by: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>

2009-02-12 15:48  dlezcano

	* src/lxc/lxc_conf.c: setup the new pts instance From: Daniel
	  Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>

	  The pts new instance is setup conforming the documentation in the
	  kernel sources, Documentation/filesystems/devpts.txt.

	  Signed-off-by: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>

2009-02-12 15:47  dlezcano

	* src/lxc/: error.c, error.h, lxc_conf.c, lxc_conf.h, lxc_config.c:
	  add the new pts instance configuration From: Daniel Lezcano
	  <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>

	  This patch adds the configuration for a new pts instance.

	  Signed-off-by: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>

2009-02-12 15:47  dlezcano

	* src/lxc/lxc_conf.c: build a set of flags for the different
	  enabled subsystems From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>

	  When we want to check if a subsystem is enabled, we look at the
	  presence of a file/directory in the configuration tree files.
	  That works until we chroot into the rootfs. Some subsystem should
	  be preferably setup after the chrootfs, making the code simpler
	  and easier to read. So before setup the different subsystem, I
	  build a flags set and reuse it later to check if the subsystem is
	  enabled or not.

	  Signed-off-by: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>

2009-02-12 15:46  dlezcano

	* TODO: Add a TODO file

	  From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>

	  The TODO file should be filled.

	  Signed-off-by: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>

2009-02-09 18:11  dlezcano

	* scripts/lxc-debian.in: add missing ifupdown package to
	  debootstrap From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>

	  Add the ifupdown missing package.

	  Signed-off-by: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>

2009-02-09 18:10  dlezcano

	* scripts/lxc-debian.in: Update lxc-debian to use the lenny release

	  From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

	  With the release of lenny nearing this patch may soon be useful.

	  Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> Signed-off-by:
	  Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>

2009-02-09 18:10  dlezcano

	* bootstrap: Create the m4 directory if it does not exist From:
	  Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>

	  Create the m4 directory if it does not exist

	  Reported-by: Dietmar Maurer <dietmar-YTcQvvOqK21BDgjK7y7TUQ@public.gmane.org> Signed-off-by:
	  Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>

2009-02-05 13:03  dlezcano

	* scripts/lxc-debian.in: handle interruption/failure of lxc-debian
	  more gracefully

	  From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

	  If lxc-debian fails or is interrupted during debootstrap then the
	  next invocation of lxc-debian breaks because it only checks for
	  the existence of the directory. This forces the user to remove
	  the cache by hand to retry the create step.

	  Let's allow the user to re-run lxc-debian to resume/retry. Store
	  the cache in a partial-$ARCH directory until debootstrap
	  succeeds. Then move the valid cache to its final destination.

	  Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> Signed-off-by:
	  Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>

2009-02-02 15:50  dlezcano

	* configure.in, src/lxc/start.c: Add signalfd function definition

	  From: Dietmar Maurer <dietmar-YTcQvvOqK21BDgjK7y7TUQ@public.gmane.org>

	  The signalfd function prototype and the signalfd header file is
	  not defined in the debian Lenny. We want to use this debian
	  version with a newer kernel.

	  This patch gives the signalfd function prototype, because the
	  function is available in the glibc-2.7 which is the version
	  coming with debian Lenny.

	  Signed-off-by: Dietmar Maurer <dietmar-YTcQvvOqK21BDgjK7y7TUQ@public.gmane.org>
	  Signed-off-by: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>

2009-01-29 11:50  dlezcano

	* scripts/lxc-debian.in: Complete use of autoconf prefix in
	  lxc-debian

	  From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

	  The lxc-debian script does not consistently address the lxc lock
	  as @LOCALSTATEDIR@/lock/subsys/lxc. Make consistent use of the
	  autotools substitution to completely enable configure --prefixes.

	  I also added a comment explaining why some of the paths didn't
	  need autoconf substitutions for anyone who wants to understand
	  the script.  Also, to separate it from the container contents
	  proper, I moved the CACHE variable initialization above the
	  container-internal path variables.

	  Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> Signed-off-by:
	  Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>

2009-01-28 17:33  dlezcano

	* src/lxc/lxc_conf.c: From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>

	  This modification removes the tty configuration file and makes
	  the tty to be usable with the local tty.

	  Signed-off-by: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
	  Signed-off-by: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>

2009-01-26 20:43  dlezcano

	* lxc.spec.in, src/lxc/lxc_cgroup.c, src/lxc/lxc_checkpoint.c,
	  src/lxc/lxc_console.c, src/lxc/lxc_destroy.c,
	  src/lxc/lxc_execute.c, src/lxc/lxc_freeze.c, src/lxc/lxc_info.c,
	  src/lxc/lxc_monitor.c, src/lxc/lxc_priority.c,
	  src/lxc/lxc_restart.c, src/lxc/lxc_start.c, src/lxc/lxc_stop.c,
	  src/lxc/lxc_unfreeze.c, src/lxc/lxc_unshare.c,
	  src/lxc/lxc_wait.c: Fixed bad variable type

	  From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>

	  Fixed the type of the opt variable. On the powerpc architecture,
	  that leads to an infinite loop in the getopt inspection because
	  getopt returns 255 instead of -1 as expected. The opt variable
	  should be an int and not a char.

	  Signed-off-by: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
	  Signed-off-by: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>

2009-01-26 09:33  dlezcano

	* Makefile.am: From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>

	  Removed usage of the release script.

	  Signed-off-by: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
	  Signed-off-by: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>

2009-01-26 09:31  dlezcano

	* release.sh: Remove the release script

	  From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>

	  Removed the release.sh script which is not in the right place in
	  this source tree.

	  Signed-off-by: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
	  Signed-off-by: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>

2009-01-26 09:25  dlezcano

	* lxc.spec.in: Fixed type in the spec file

	  From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>

	  Removed typo.

	  Signed-off-by: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
	  Signed-off-by: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>

2009-01-26 00:29  dlezcano

	* configure.in, config/acinclude.m4: Check the kernel feature

	  From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>

	  The virtual devices are automatically destroyed when the network
	  namespace dies for the kernel version >= 2.6.29. Until this
	  version the network devices have to be destroyed by lxc. This
	  modification checks the version of the kernel to make lxc to
	  destroy the network devices or not.

	  Signed-off-by: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
	  Signed-off-by: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>

2009-01-26 00:27  dlezcano

	* lxc.spec.in: Reduce spec file

	  From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>

	  Simplified the spec file

	  Signed-off-by: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
	  Signed-off-by: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>

2009-01-25 22:52  dlezcano

	* configure.in, doc/Makefile.am, doc/lxc-console.sgml.in,
	  doc/lxc.conf.sgml.in, doc/lxc.sgml.in, scripts/lxc-debian.in,
	  src/lxc/Makefile.am, src/lxc/af_unix.c, src/lxc/af_unix.h,
	  src/lxc/checkpoint.c, src/lxc/console.c, src/lxc/create.c,
	  src/lxc/destroy.c, src/lxc/error.c, src/lxc/error.h,
	  src/lxc/lxc.h, src/lxc/lxc_conf.c, src/lxc/lxc_conf.h,
	  src/lxc/lxc_config.c, src/lxc/lxc_console.c, src/lxc/lxc_init.c,
	  src/lxc/lxc_lock.c, src/lxc/lxc_start.c, src/lxc/mainloop.c,
	  src/lxc/mainloop.h, src/lxc/restart.c, src/lxc/start.c,
	  src/lxc/stop.c: From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>

	  Console support for the system container.

	  Signed-off-by: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
	  Signed-off-by: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>

2009-01-25 22:15  dlezcano

	* lxc.spec.in: From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>

	  Signed-off-by: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
	  Signed-off-by: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>

2009-01-24 23:49  dlezcano

	* scripts/lxc-debian.in, src/lxc/Makefile.am, src/lxc/af_unix.c,
	  src/lxc/af_unix.h, src/lxc/checkpoint.c, src/lxc/console.c,
	  src/lxc/create.c, src/lxc/destroy.c, src/lxc/error.c,
	  src/lxc/error.h, src/lxc/lxc.h, src/lxc/lxc_console.c,
	  src/lxc/lxc_init.c, src/lxc/lxc_lock.c, src/lxc/lxc_start.c,
	  src/lxc/restart.c, src/lxc/start.c, src/lxc/stop.c: From: Daniel
	  Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>

	  Consolidate the tty management.  Permission on the container is
	  checked.  The tty can be re-attached.

	  Signed-off-by: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
	  Signed-off-by: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>

2009-01-18 23:11  dlezcano

	* src/lxc/: Makefile.am, af_unix.c, lxc_conf.c, lxc_conf.h,
	  lxc_config.c, lxc_console.c, lxc_init.c, mainloop.c, mainloop.h,
	  start.c: From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>

	  Console code. At this point, we are able in the container to add
	  the ttys in the inittab file. The configuration should specify
	  how many tty we want in the container.

	  Rights are not yet supported - anyone can use the tty of any
	  container.  Resizing of the tty is not supported - and probably
	  won't be.

	  Signed-off-by: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
	  Signed-off-by: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>

2009-01-18 22:49  dlezcano

	* src/lxc/cgroup.c: Remove nsgroup directory when the container
	  dies

	  From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>

	  Remove the nsgroup directory when the container dies, otherwise
	  this will lead to an error when the pids number are recycled

	  Signed-off-by: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
	  Signed-off-by: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>

2009-01-18 22:47  dlezcano

	* scripts/lxc-debian.in: Comment out the script debug mode

	  From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>

	  Suppress debug mode in the script

	  Signed-off-by: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
	  Signed-off-by: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>

2009-01-08 17:56  dlezcano

	* src/lxc/: lxc_conf.c, lxc_conf.h, lxc_config.c, restart.c,
	  start.c: Add the tty configuration

	  From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>

	  Add the number of ttys for the configuration.

	  This modification makes the start to instantiate the pseudo-ttys
	  and to mount the slave side to the tty of the system container.

	  Signed-off-by: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>

2009-01-08 15:41  dlezcano

	* src/lxc/: Makefile.am, error.c, error.h, lxc_conf.c, lxc_conf.h:
	  Create and setup the ttys function

	  From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>

	  Create the function to instantiate the ttys, map them to the root
	  filesystem and to delete them.

	  The create function look at the number of tty wanted by the
	  configuration and will instantiate this number of pseudo-tty.
	  The delete function close the pseudo-ttys and frees the memory.
	  The setup function, map the slave pty on the tty of the root
	  filesystem belonging to the container.

	  Signed-off-by: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>

2009-01-08 11:21  dlezcano

	* src/lxc/: Makefile.am, af_unix.c, af_unix.h: Add af_unix helpers

	  From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>

	  Add a set of wrapper to handle af_unix sockets.  The functions
	  allows to create both traditional or abstract unix socket via a
	  simple "open" call and provide a fd passing facility.

	  Signed-off-by: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>

2009-01-08 09:30  dlezcano

	* src/lxc/create.c: more info on failure to create directory

	  From: Amy Griffis <amy.griffis-VXdhtT5mjnY@public.gmane.org>

	  Add error handling similar to remove_lxc_directory().

	  Signed-off-by: Amy Griffis <amy.griffis-VXdhtT5mjnY@public.gmane.org> Signed-off-by:
	  Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
