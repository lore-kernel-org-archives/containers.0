From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: lxc: linux container tools 0.6.3 release
Date: Fri, 24 Jul 2009 17:35:09 +0200
Message-ID: <4A69D4AD.4050508@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753240AbZGXPfa@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: LXC Development <lxc-devel@lists.sourceforge.net>, Linux Containers <containers@lists.osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Cc: Guido Trotter <ultrotter@debian.org>, "Michael K. Johnson" <johnsonm@rpath.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Jiri Slaby <jslaby@suse.cz>
List-Id: containers.vger.kernel.org

http://lxc.sourceforge.net/lxc.html

Release Name: lxc-0.6.3

Notes:
  * daemonize the container with the command 'lxc-start -d'
  * improved the 'lxc-ps' command
  * and a lot of fixes, cleanup and small improvements

Thanks to:
 * Michel Normand who did a *lot* of fixes and improvements
 * Ryousei Takano for fixing the rpmbuild for a non root user
 * Filippo Giunchedi for updating the documentation and fixed the compilation
 * Christophe Quintard for reworking the pts section documentation
 * Matty for fixing some problems with the lxc-fedora script


ChangeLog:

commit c159cb963868d4646cf415abb064d8fd4b6ee848
Author: Daniel Lezcano <dlezcano@fr.ibm.com>
Date:   Fri Jul 24 16:41:27 2009 +0200

    fix the document according the current version
    
    Remove the comment about sharing /dev and fix the lxc-ps option
    format.
    
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit 72439b9f8b5cc6cea67b67cdc5aba3ff01c0597d
Author: Michel Normand <normand@fr.ibm.com>
Date:   Fri Jul 24 15:25:45 2009 +0200

    close also inherited fd in lxc-execute
    
    This is a complement of previous patches d983b93c3ad860fa22ef760ae27a944d6000e35a
    and af795875875de1855ee251ba530fbe2b53463f6e about inherited fd.
    
    Here this is required for the lxc-execute that have a specific
    lxc-init procress.
    
    Signed-off-by: Michel Normand <normand@fr.ibm.com>
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit c8c9ce7a2b5bc4bf2615d83d71614829f36e51c4
Author: Daniel Lezcano <dlezcano@fr.ibm.com>
Date:   Fri Jul 24 15:25:45 2009 +0200

    display an explicit warning when netlink headers are missing
    
    "netlink headers not found" implicitely means we have to install the
    kernel headers. Make this explicit.
    
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit 1ac470c02ad23fef754e1e4d6dfdbf4e1446cc3b
Author: Daniel Lezcano <dlezcano@fr.ibm.com>
Date:   Fri Jul 24 15:25:45 2009 +0200

    add some traces in the code for the logger
    
    Add some traces in the code, so we are able to follow the execution
    of the start command with the logger.
    
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit f5d186114c424255dca4b2713805c877dd9d0878
Author: Daniel Lezcano <dlezcano@fr.ibm.com>
Date:   Fri Jul 24 15:25:44 2009 +0200

    fix cgroup trace
    
    The trace is displayed either if the setting fails, change that by
    displaying the trace when the setting is successful.
    
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit f49d83e90fb1f09b7ac223ad03506fe8c14367d1
Author: Daniel Lezcano <dlezcano@fr.ibm.com>
Date:   Fri Jul 24 15:25:43 2009 +0200

    change version to 0.6.3
    
    Increment to the 0.6.3 version.
    
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit cd830f336a43913d80ada90082378a7c9f11e9eb
Author: Daniel Lezcano <daniel.lezcano@free.fr>
Date:   Wed Jul 22 19:39:18 2009 +0200

    Specify in the debian script an extra fstab file
    
    Allow the user to specify an extra fstab file to be added in the
    debian configuration. So some optimisations can be done for sharing
    objects.
    
    eg: /var/cache/apt/archives mounted in <rootfs>/var/cache/apt/archives
    
    Signed-of-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit 246091b903900a338fc5de309054892ff6852667
Author: Daniel Lezcano <dlezcano@fr.ibm.com>
Date:   Wed Jul 22 19:39:18 2009 +0200

    add clone2 for ia64
    
    Added clone2 for container creation on ia64.
    Not tested as I don't have such architecture.
    
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit cd54d859da6af560e4c34e165e146e7a0e746dcc
Author: Daniel Lezcano <daniel.lezcano@free.fr>
Date:   Wed Jul 22 19:39:17 2009 +0200

    make use of the logging facility and add some traces
    
    Now we have a logging facility, let's use it and add some traces in
    the code.
    
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit 958f5c9e83ffac81aa711a803d13bd713550c341
Author: Daniel Lezcano <dlezcano@fr.ibm.com>
Date:   Mon Jul 20 17:57:31 2009 +0200

    isolate the shmfs for the container
    
    The /dev/shm is not isolated for application container, so mount it in
    the container.
    
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit af795875875de1855ee251ba530fbe2b53463f6e
Author: Daniel Lezcano <dlezcano@fr.ibm.com>
Date:   Mon Jul 20 17:57:31 2009 +0200

    fix closed fd when they are inherited
    
    This patch fix a problem with the commit d983b93c3ad860fa22ef760ae27a944d6000e35a
    When the lxc daemonize, it closes fd 0, 1 and 2. But these ones are coming from
    inherited fd and they are already in the inherited list of fd. When lxc creates
    some file descriptors, they have the number of the previous inherited file
    descriptor, so they are closed when we close all the inherited file descriptors.
    
    In order to fix that, the lxc_close_inherited_fd function has been implemented
    to close an inherited fd and remove it from the list.
    
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit 0dd4566ecadfa4a42529250513dc68b6aed4ce92
Author: Daniel Lezcano <dlezcano@fr.ibm.com>
Date:   Thu Jul 16 16:38:15 2009 +0200

    Remove the a previous cgroup
    
    As a previous run may have created a cgroup but died unexpectedly,
    the cgroup can be still there when we try to launch the container
    again with the same name. This patch removes the directory if it is
    present, if this one is not owned by caller or it is in use (that should
    not happen), the rmdir will fail with the corresponding errno.
    
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit 3a0f472d9dcf1d343dcec1d6d644a8d925fa3ce7
Author: Daniel Lezcano <dlezcano@fr.ibm.com>
Date:   Thu Jul 16 16:38:15 2009 +0200

    encapsulate lxc_handler
    
    Move the lxc_handler structure definition in the body file and
    dynamically allocate it.
    
    lxc_handler becomes an opaque structure for the user.
    
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit cdfeda48d2f112cef5f300538e77e5b81b8c80a4
Author: Daniel Lezcano <dlezcano@fr.ibm.com>
Date:   Thu Jul 16 16:38:15 2009 +0200

    Remove useless initialization
    
    The structure is cleared by the lxc_init function.
    
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit d983b93c3ad860fa22ef760ae27a944d6000e35a
Author: Michel Normand <normand@fr.ibm.com>
Date:   Wed Jul 15 23:48:22 2009 +0200

    lxc-start should not hold inheritited fds
    
    This patch makes the intermediate lxc processes to close the
    inherited file descriptor. The child process will inherit these fd
    in any case and that will be up to it to handle them.
    
    Signed-off-by: Michel Normand <normand@fr.ibm.com>

commit af06a4bf9447a52c86c5578be7ef0e52bad54044
Author: Daniel Lezcano <daniel.lezcano@free.fr>
Date:   Wed Jul 15 23:48:22 2009 +0200

    use the lxc arguments dup in lxc_execute
    
    Now we have a helper to dup the arguments, let's use it.
    The code gains in clarity.
    
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit fa7eddbbbbaf493268941bb013ed7477a5cc25b1
Author: Daniel Lezcano <daniel.lezcano@free.fr>
Date:   Wed Jul 15 23:48:22 2009 +0200

    add a helper to dup the lxc arguments
    
    Add a helper to dup the lxc_arguments, so the code making
    the copy of the arguments will be more clear.
    
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit e46ac651751e726648de898dcdca823d3ae045f5
Author: Daniel Lezcano <daniel.lezcano@free.fr>
Date:   Wed Jul 15 23:48:22 2009 +0200

    cleanup lxc-init
    
    Make some cleanup around the parameters of lxc-init.
    The option mount procfs is not needed as we want to do that
    all the time.
    
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit 0d9f8e188c1c4832e4f6b9de646478947ae86877
Author: Daniel Lezcano <daniel.lezcano@free.fr>
Date:   Mon Jul 13 23:12:10 2009 +0200

    detect a cgroup named 'lxc'
    
    This patch makes lxc to detect a specific cgroup dedicated to lxc
    which is mounted with the lxc name. That allows to mount different
    cgroup in different places with different options (aka subsystems)
    and assign one to be used by lxc. If no such mount point is found,
    the first cgroup mount point is used.
    
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit 2b31f553fab7daa0d62dea9e6e50c7aab2aca0ab
Author: Michel Normand <normand@fr.ibm.com>
Date:   Mon Jul 13 23:12:09 2009 +0200

    lxc-execute or lxc-start to fail if cgroup not mounted
    
    Before this patch a container was able to be started
    without mounted cgroup. (only a warning was logged)
    But the lxc-ps is using the /proc/<pid>/cgroup to identify
    the lxc container in which pid is running.
    So to be consistent between all lxc command I force an error
    if cgroup is not mounted at time of lxc-execute or lxc-start.
    
    Signed-off-by: Michel Normand <normand@fr.ibm.com>
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit 74741dcc9e4a30a57cd30fdf938ae94d14a23734
Author: Daniel Lezcano <daniel.lezcano@free.fr>
Date:   Fri Jul 10 08:58:27 2009 +0200

    create the lxc directory with lxc-setcap
    
    There are several cases:
     * we run the lxc-create as root, the @path@/var/lib/lxc will be created
     * we run the lxc-create as non-root, the creation of the directory will
       fail with "permission denied", so we should call lxc-setcap before
     * we run lxc-setcap (always as root), we create the directory and set
       the permission for everyone.
    
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit 92fc52d3db7df485bae1d62a6a6c9af5bf2d07cf
Author: Daniel Lezcano <daniel.lezcano@free.fr>
Date:   Fri Jul 10 08:58:27 2009 +0200

    don't create the lxc directory at rpm installation
    
    Don't create the directory when we install the lxc package.
    This is handled by lxc-create.
    
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit 3e3bf8aee6df8247e80953ae8d9eb603dc8ba5f3
Author: Ryousei Takano <takano-ryousei@aist.go.jp>
Date:   Fri Jul 10 08:58:27 2009 +0200

    Remove install-exec-local rule
    
    Hi Daniel and all,
    
    I am trying to run LXC on the CentOS 5.3 and the Linux kernel 2.6.30.
    I found a problem with running the rpmbuild command.  The error message
    is shown below:
    
    $ rpmbuild -bb lxc.spec
    	<snip>
     /usr/bin/install -c 'lxc-setcap' '/var/tmp/lxc-0.6.2-build/usr/bin/lxc-setcap'
     /usr/bin/install -c 'lxc-version' '/var/tmp/lxc-0.6.2-build/usr/bin/lxc-version'
    mkdir: cannot create directory `/var/lib/lxc': Permission denied
    make[3]: *** [install-exec-local] Error 1
    make[3]: Leaving directory `/home/ryousei/rpm/BUILD/lxc-0.6.2/src/lxc'
    make[2]: *** [install-am] Error 2
    make[2]: Leaving directory `/home/ryousei/rpm/BUILD/lxc-0.6.2/src/lxc'
    make[1]: *** [install-recursive] Error 1
    make[1]: Leaving directory `/home/ryousei/rpm/BUILD/lxc-0.6.2/src'
    make: *** [install-recursive] Error 1
    error: Bad exit status from /var/tmp/rpm-tmp.26914 (%install)
    
    RPM build errors:
        Bad exit status from /var/tmp/rpm-tmp.26914 (%install)
    
    This patch removes 'install-exec-local' rule in Makefile.  It is not necessary,
    and it causes rpmbuild failure on the CentOS 5.3.
    
    Signed-off-by: Ryousei Takano <takano-ryousei@aist.go.jp>
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit cb0395643b86e56ecd2a22974b826f08bd33d229
Author: Daniel Lezcano <daniel.lezcano@free.fr>
Date:   Tue Jul 7 22:53:05 2009 +0200

    remove fork_ns code
    
    This code is no longer used, remove it.
    
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit 50e98013d518a3b6c57d0288887590af96689998
Author: Daniel Lezcano <daniel.lezcano@free.fr>
Date:   Tue Jul 7 22:51:18 2009 +0200

    replace fork_ns by lxc_clone
    
    Make use of the lxc_clone function and do no longer
    use the fork_ns function.
    
    The lxc-unshare utility has been changed to always do a fork.
    
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit 5bb3ba8acd29d11c92845b06a1f0852b642f02c7
Author: Daniel Lezcano <daniel.lezcano@free.fr>
Date:   Tue Jul 7 22:51:18 2009 +0200

    use glibc clone instead of clone syscall
    
    This patch replaces the clone syscall by the glibc clone making
    the code not tied with the syscalls number declaration.
    
    The unshare syscall has been removed as it is not interesting.
    
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit b3cb3272900526b25004173fceb127203563a2e0
Author: Daniel Lezcano <dlezcano@fr.ibm.com>
Date:   Fri Jul 3 15:25:45 2009 +0200

    Fix missing capability fowner to manipulate /dev/pts/ptmx
    
    This file may be without any permission
    
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit ac30d6a43245e0c50aad9e2ebfb88d80aaeea691
Author: Filippo Giunchedi <filippo@esaurito.net>
Date:   Thu Jul 2 15:42:18 2009 +0200

    Add file capabilities to kernel options
    
    Point users in documentation to also enable POSIX capability for
    dropping CAP_BOOT.
    
    Signed-off-by: Filippo Giunchedi <filippo@esaurito.net>
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit dba277c9417fb239f0c5030bd5e5dd0aca9142ba
Author: Filippo Giunchedi <filippo@esaurito.net>
Date:   Thu Jul 2 15:42:18 2009 +0200

    Add check for CONFIG_SECURITY_FILE_CAPABILITIES
    
    This might result in more evident lack of support for POSIX capabilities
    enabled as pointed in documentation
    
    Signed-off-by: Filippo Giunchedi <filippo@esaurito.net>
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit 8747655790610f3505b6370a5393704c33f13637
Author: Filippo Giunchedi <filippo@esaurito.net>
Date:   Thu Jul 2 15:42:18 2009 +0200

    Clarify setcap advice/warning messages
    
    Probably a mention to libcap-2 is worth keeping, though it might be
    clearer to point to setcap binary directly.
    
    Signed-off-by: Filippo Giunchedi <filippo@esaurito.net>
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit e90b69740e009ba96f6fbf4b7cb40e6f9a14e243
Author: Filippo Giunchedi <filippo@esaurito.net>
Date:   Thu Jul 2 15:42:18 2009 +0200

    Include /sbin in PATH for setcap
    
    Rationale: some distributions don't include /sbin in PATH for regular
    users, thus setcap might not be found during configure
    
    Signed-off-by: Filippo Giunchedi <filippo@esaurito.net>
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit 0478642a4349846ab8e76e318909886e795df92d
Author: Filippo Giunchedi <filippo@esaurito.net>
Date:   Thu Jul 2 15:42:18 2009 +0200

    Update kernel config options location
    
    These options appear in 2.6.29 in different locations, update the sgml
    accordingly
    
    Signed-off-by: Filippo Giunchedi <filippo@esaurito.net>
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit 9f78081ae0b20141ae6d3e4230b7ec401b174c3c
Author: christophe.quintard@fr.ibm.com <christophe.quintard@fr.ibm.com>
Date:   Thu Jul 2 15:42:17 2009 +0200

    Rewriting the pts section man for lxc.conf
    
    I think this explanation is better.
    
    Signed-off-by: Christophe Quintard <christophe.quintard@fr.ibm.com>
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit 8f0024d85af3aa23e76dc17adad3e80ee93000b4
Author: Michel Normand <normand@fr.ibm.com>
Date:   Wed Jul 1 11:58:41 2009 +0200

    update the lxc-ps man page after previous code change
    
    this is the man page update following the
    previous git commit 7cbfc4e4411b6effc6a64fd83a8cb37ffc9c7155
    
    Signed-off-by: Michel Normand <normand@fr.ibm.com>
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit 8e9d77106f110895bc6e817d64156afacb24e5ee
Author: Daniel Lezcano <dlezcano@fr.ibm.com>
Date:   Wed Jul 1 11:58:41 2009 +0200

    fix compilation warning with malloc
    
    Add missing include stdlib.h
    
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit 37c3dfc9c974a6c42716c66e8d3c286f2441da44
Author: Michel Normand <normand@fr.ibm.com>
Date:   Thu Jun 25 11:21:56 2009 +0200

    lxc-execute to return exit code of its child not others
    
    lxc-execute has to return the exit code of it's child not others
    as today's code would return the exit code of the last child.
    We need to track the first process we launched and store its
    exit status when it exits. In order to avoid to detect the exit
    of this pid several time if the pids number wrap, we put an extra
    flag saying the process group is orhpan.
    
    Signed-off-by: Michel Normand <normand@fr.ibm.com>
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit 7cbfc4e4411b6effc6a64fd83a8cb37ffc9c7155
Author: Michel Normand <normand@fr.ibm.com>
Date:   Thu Jun 25 11:10:40 2009 +0200

    replace the lxc-ps bash script by a perl script
    
    Implement the lxc-ps script with perl script.
    
    Signed-off-by: Michel Normand <normand@fr.ibm.com>
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit acc8694126c270f7d3a237f965304ec9f78a6c85
Author: Michel Normand <normand@fr.ibm.com>
Date:   Thu Jun 25 11:10:40 2009 +0200

    another place where readlink to be null terminated
    
    I did this one change by reading the code
    but did not tried to run it.
    
    Signed-off-by: Michel Normand <normand@fr.ibm.com>
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit 2b4e286d251f0add75a23c57ba361c326d945c10
Author: Michel Normand <normand@fr.ibm.com>
Date:   Thu Jun 25 11:10:40 2009 +0200

    the lxc_unlink_nsgroup may fail on ppc. V2
    
    the lxc_unlink_nsgroup may fail on ppc
    where the stack is not zeroed by default
    and because the readlink function do not add trailing null character.
    
    Signed-off-by: Michel Normand <normand@fr.ibm.com>
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit 47ad75f88da3a68347a709f5474289311d6c0ff9
Author: Michel Normand <normand@fr.ibm.com>
Date:   Thu Jun 25 11:10:39 2009 +0200

    update the help of lxc-checkpoint and lxc-restart
    
    Update the checkpoint and restart regarding the statefile parameter.
    
    Signed-off-by: Michel Normand <normand@fr.ibm.com>
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit 4f3f0d4b015af0b1021e22dd3b6a5f2fffbff0d2
Author: Matty <matty91@gmail.com>
Date:   Wed Jun 24 13:13:18 2009 +0200

    lxc-fedora fixes
    
    Howdy,
    
    I was playing around with LXC containers this past weekend, and
    noticed a couple of issues with the lxc-fedora script:
    
    #1: Line 96 should be ${ROOTFS}/etc/sysconfig/network instead of
    ${ROOTFS}/sysconfig/network
    
    #2 Line 249 contains a reference to $PKG, which isn't used in the
    program. I adjusted the variable to point to the correct package, and
    use this in the calls to yumdownloader:
    
        PKG="${DISTRO}-release.noarch.rpm"
                       .....
        yumdownloader --destdir="${CACHE}/partial" "${PKG}"
    
    #3 The $CACHE/partial path is escaped unnecessarily:
    
       RPM="rpm --root \"${CACHE}/partial\""
    
    #4 The program assumes yumdownloader will work, which isn't always the
    case. I added an if statement to check the return code:
    
    
       echo "Downloading distribution release file ${PKG}"
       yumdownloader --destdir="${CACHE}/partial" "${PKG}"
       RESULT=$?
    
       if [ "${RESULT}" != "0" ]; then
           echo "Enable to download the distribution release file"
           exit 1
       fi
    
    #5 The package name passed to yumdownloader is incorrect:
    
       yumdownloader --destdir="${CACHE}/partial" "${DISTRO}-release.noarch.rpm"
    
       On Fedora 10 and 11, this evaluates to:
    
       fedora-release.noarch.rpm
    
       When we need it to evaluate to:
    
       fedora-{RELEASE_VER}.release.noarch
    
       This is fixed in the PKG variable listed above.
    
    A patch that addresses these issues is attached.
    
    Thanks,
    - Ryan
    
    Signed-off-by: Matty <matty91@gmail.com>
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit 1ea6db2923761b45b4400c32810b17f58785057a
Author: Daniel Lezcano <dlezcano@fr.ibm.com>
Date:   Fri Jun 12 16:02:14 2009 +0200

    unshare the utsname in all the cases
    
    The current code implies we have to define a utsname in order
    to unshare it. This problematic in case of system container because
    we want them to set their hostname. As the utsname namespace is
    a COW, we can safely unshare it in all the cases.
    
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit ddceb1f9fa9cedec49f7cd4c04a640cf3a529b87
Author: Daniel Lezcano <dlezcano@fr.ibm.com>
Date:   Fri Jun 12 16:02:14 2009 +0200

    fix capability.h compilation problem
    
    The capability.h header is broken on fedora 11.
    The workaround is to include <sys/types.h> before <sys/capability.h>.
    
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit dbbf8b4ecb95f3f55327b12d66e1727d2c559270
Author: Daniel Lezcano <dlezcano@fr.ibm.com>
Date:   Wed Jun 10 19:04:41 2009 +0200

    remove pkg-config dependency from lxc
    
    Stupid me, we don't want to add a dependency to an external
    tool as the library has to be standalone.
    
    Just let lxc to define a .pc file, so the upper layer will
    find the needed informations to use it.
    
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit 287745ca251787c50ee48b2c905e81fa8369fb5e
Author: Daniel Lezcano <dlezcano@fr.ibm.com>
Date:   Wed Jun 10 19:04:41 2009 +0200

    remove lxc-config file
    
    Remove this file as it is not used.
    
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit bcd952a11e98e1da5cb28b31c52a65c71f1375c0
Author: Daniel Lezcano <dlezcano@fr.ibm.com>
Date:   Wed Jun 10 18:49:16 2009 +0200

    rename lxc-config to lxc-version
    
    Rename lxc-config to lxc-version in order to avoid the confusion
    with what looks like a container configuration tool.
    
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit 3eae9733be0e89b1badb36d96bb60704f291ffc0
Author: Daniel Lezcano <dlezcano@fr.ibm.com>
Date:   Wed Jun 10 18:21:48 2009 +0200

    replace lxc-version by lxc-config
    
    As we have the correct informations with pkg-config we can
    write a script which will collect the informations and we get
    rid of the C program.
    
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit b6345ba1b39ada371caa24ec3c105694604caa76
Author: Daniel Lezcano <dlezcano@fr.ibm.com>
Date:   Wed Jun 10 18:21:48 2009 +0200

    add pkg-config for lxc
    
    Add the pkg-config information for lxc.
    
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit 3b9246c4aae3f7602c0ad64f5b1204eb559e5b07
Author: Daniel Lezcano <daniel.lezcano@free.fr>
Date:   Sun Jun 7 21:48:46 2009 +0200

    don't remove the autoconf generated files
    
    Don't clean up the sgml which are generated by configure, otherwise
    at the next make, the documentation generation will complain about
    missing files.
    
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit b8f57738b44d9ed8e67d90db72fe89a652f8450d
Author: Daniel Lezcano <daniel.lezcano@free.fr>
Date:   Sun Jun 7 21:48:46 2009 +0200

    log the container console when it is daemonized and the log is enabled
    
    When we daemonize the container and we specify the log file,
    the container will use the log file to write the console output.
    
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit c36583c3034ca430c98fc0b5afe6e8f0c6511258
Author: Daniel Lezcano <dlezcano@fr.ibm.com>
Date:   Sun Jun 7 21:48:46 2009 +0200

    Make possible to daemonize lxc-start
    
    If needed the container can be launched in background
    with a specific option -d.
    
    That will make mute the container, the logs can help
    to check what went wrong.
    
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit f8e09a0b769d185e66dc488796fc027abd46266d
Author: Daniel Lezcano <daniel.lezcano@free.fr>
Date:   Sun Jun 7 21:48:46 2009 +0200

    save/restore the tty
    
    Save the tty configuration before calling lxc_start and
    restore it right after it has been changed.
    
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit d4fca29f0175a25efe82f4dddc7e724752797686
Author: Filippo Giunchedi <filippo@esaurito.net>
Date:   Sun Jun 7 21:48:46 2009 +0200

    Ignore test/ binaries
    
    Hi,
    as per subject, this ignores binaries generated in test/
    
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit 7e610d7f1de2bfb8dcc4118419294cda2ee60004
Author: Filippo Giunchedi <filippo@esaurito.net>
Date:   Sun Jun 7 21:48:45 2009 +0200

    test/: update API usage
    
    Hi,
    I've been playing with lxc, though with --enable-test the test/ directory
    doesn't compile, the following patch ought to fix this.
    I've not tested tests throughly but seems straightforward enough.
    
    Update the API usage in test/ as to make tests compile
    
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit 1490112767ea6e06ea78e80d905b9dad41051798
Author: Daniel Lezcano <dlezcano@fr.ibm.com>
Date:   Fri May 29 14:43:39 2009 +0200

    Add missing file to the repository
    
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit 10fba81b9d0221b8e47aa1e0b43236413b7d28df
Author: Michel Normand <normand@fr.ibm.com>
Date:   Thu May 28 15:32:30 2009 +0200

    change man pages to use a common file for common options
    
    the common options of lxc commands
    are now described in one file "common_options.sgml.in"
    
    Signed-off-by: Michel Normand <normand@fr.ibm.com>
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit 99e4008cad9e959b683c6f48411fcf15a92be3b5
Author: Michel Normand <normand@fr.ibm.com>
Date:   Thu May 28 15:32:29 2009 +0200

    change man pages to use a seealso file for references
    
    the common references to lxc man pages
    are now placed in one file "see_also.sgml.in"
    
    Note that the few man pages that refer to man
    pages that are not lxc ones have two "See Also" paragraph.
    
    Signed-off-by: Michel Normand <normand@fr.ibm.com>
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit 439358bfe473a222ef64bf98efd29b1c35853605
Author: Michel Normand <normand@fr.ibm.com>
Date:   Thu May 28 15:32:29 2009 +0200

    avoid two times error msg about invalid state
    
    remove an error message in lxc_wait.c that duplicate
    an already existing error message in state.c
    
    Signed-off-by: Michel Normand <normand@fr.ibm.com>
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit 549153a7cf44b9c3da201ac9b6a6be56f88991e8
Author: Michel Normand <normand@fr.ibm.com>
Date:   Thu May 28 15:32:29 2009 +0200

    lxc-wait to check if container already in requested state
    
    Without this patch the lxc_wait may wait forever
    if container is already in requested state.
    
    Note that this patch avoids also to be hang if container do not exist yet.
    
    Signed-off-by: Michel Normand <normand@fr.ibm.com>
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit 2c396e124b92f4d24fffaf86de3ceb74c5c76afe
Author: Michel Normand <normand@fr.ibm.com>
Date:   Thu May 28 15:32:29 2009 +0200

    add an error message if more than one monitor
    
    the change introduced by commit 31c53c2e1afc6c81ce4aad5ef4cb982cd2fea365
    do not allow anymore to have more than one monitor.
    
    The purpose of this patch is to add an error message
    when such a condition is identified, eg:
    ===
    lxc-monitor: bind : Address already in use
    ===
    
    Signed-off-by: Michel Normand <normand@fr.ibm.com>
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit 018ef5201be79a5f8cd2c4e1ddf0da0519268a03
Author: Daniel Lezcano <dlezcano@fr.ibm.com>
Date:   Thu May 28 12:10:51 2009 +0200

    choose a default network interface name
    
    When no name is specified in the configuration file for an interface,
    let the system to choose one nice name like "eth".
    
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit f8af8e239ed6dc586f6a6b8035f6fab95e55e998
Author: Daniel Lezcano <dlezcano@fr.ibm.com>
Date:   Thu May 28 12:10:51 2009 +0200

    Fix lxc-netstat
    
    The lxc-unshare cli has changed, fix the call to lxc-unshare
    in lxc-netstat.
    
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit 3f8b55d5cccd8826e7710d98dd5680637791a481
Author: Daniel Lezcano <dlezcano@fr.ibm.com>
Date:   Thu May 28 12:10:50 2009 +0200

    save the config file in the statefile directory
    
    Save the configuration file in the statefile directory so it
    can be re-created at restart time.
    
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit 6b201d02b05f1d275a21259a734b3f0ad82f7c57
Author: Daniel Lezcano <dlezcano@fr.ibm.com>
Date:   Thu May 28 12:10:50 2009 +0200

    add a statefile directory parameter
    
    add a statefile directory parameter in order to save some
    lxc informations a checkpoint.
    
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit d7efa8fcbf0911f93c83dc06a708e7d73833dce3
Author: Daniel Lezcano <dlezcano@fr.ibm.com>
Date:   Thu May 28 12:10:50 2009 +0200

    copy the configuration file in the conf repo
    
    When creating the container, copy the configuration file to the
    configuration tree.
    
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit 4fcc0112bd5f3b7aaa26b1d734d7e7229eee738d
Author: Daniel Lezcano <dlezcano@fr.ibm.com>
Date:   Thu May 28 12:10:50 2009 +0200

    create the container with an empty configuration
    
    Fix the code to not fail when the specified configuration file
    is empty.
    
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit 6203de18eb7d623692080a71622547ee0dc9da41
Author: Daniel Lezcano <dlezcano@fr.ibm.com>
Date:   Thu May 28 12:10:50 2009 +0200

    rename the ns_cgroup with the container name
    
    It is not easy to follow the cgroup name associated with a container,
    so right after the container is created, I rename the cgroup which
    is the pid of the creator by the container name.
    
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit 920dfa346cf63cd501192dafe9a64a615147fedc
Author: Daniel Lezcano <dlezcano@fr.ibm.com>
Date:   Thu May 28 12:10:50 2009 +0200

    change the checkpoint/restart function api
    
    As the checkpoint/restart is expected to be sequential,
    I pass the file descriptor to checkpoint and restart, so
    that will be up to the caller to open the file descriptor
    which can be a pipe, socket, file, etc ...
    
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit 34c66a6980bebf1ca9b7da87e627fc507a6c139a
Author: Daniel Lezcano <dlezcano@fr.ibm.com>
Date:   Thu May 28 12:10:50 2009 +0200

    Remove old code to destroy the network
    
    Removed this unused code.
    
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit 3f739da8b51d141b0147b2da8502d1a2b885f878
Author: Daniel Lezcano <dlezcano@fr.ibm.com>
Date:   Thu May 28 12:10:50 2009 +0200

    remove checkpoint / restart code
    
    The checkpoint / restart code is too experimental regarding
    the current implementation in the kernel.
    As there are several implementation and we don't know which
    one will be merged upstream, I remove the code and add a few
    parameters to checkpoint.
    
    The checkpoint/restart function will be plugins in order to choose
    the CR solutions. This approach will allow to switch from one
    implementation to another without breaking anything.
    
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit 64e1ae63ebfeefd41ddf6857296742d02fecc30a
Author: Daniel Lezcano <dlezcano@fr.ibm.com>
Date:   Thu May 28 12:10:50 2009 +0200

    make use of the copy file function
    
    Now we have specific function to copy the files, make use of it
    and remove the old code.
    
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit e3642c43e6599fb1bfdd2e763e034c5c46299a46
Author: Daniel Lezcano <dlezcano@fr.ibm.com>
Date:   Thu May 28 12:10:50 2009 +0200

    make a "copy file" function
    
    Create a specific function to copy a file from a location to
    another location.
    
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit 7cee8789514fb42d6a48d50b904e24284f5526e3
Author: Michel Normand <normand@fr.ibm.com>
Date:   Mon May 18 22:30:39 2009 +0200

    remove lxc_error_t enum that is now useless
    
    There is no more need of the LXC_ERROR defines
    and related lxc_strerror function.
    
    Signed-off-by: Michel Normand <normand@fr.ibm.com>
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit 95b5ffafae852dd4fa2c8a17ac4791fb13fcd048
Author: Michel Normand <normand@fr.ibm.com>
Date:   Mon May 18 22:30:39 2009 +0200

    remove LXC_ERROR_* usage in src/lxc/conf.c as not required
    
    This is useless because error is already reported by the functions
    
    Signed-off-by: Michel Normand <normand@fr.ibm.com>
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit 75b1e1981dd936d8a1e5549d168cde5075177646
Author: Michel Normand <normand@fr.ibm.com>
Date:   Mon May 18 22:27:36 2009 +0200

    lxc-monitor and lxc-wait to return 255 in case of error
    
    to have same exit code for all lxc commands
    
    Signed-off-by: Michel Normand <normand@fr.ibm.com>
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit 272bc5af96da4c4768083500ac9b15826ac55166
Author: Michel Normand <normand@fr.ibm.com>
Date:   Mon May 18 22:27:36 2009 +0200

    lxc-cgroup to return 255 in case of error
    
    to have same exit code for all lxc commands
    
    Signed-off-by: Michel Normand <normand@fr.ibm.com>
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit 2ea004b8c6dec1bcacb0fd07b382dde806be70fd
Author: Michel Normand <normand@fr.ibm.com>
Date:   Mon May 18 22:27:36 2009 +0200

    lxc-console to return 255 in case of error
    
    to have same exit code for all lxc commands
    
    Signed-off-by: Michel Normand <normand@fr.ibm.com>
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit a30284df84bd32db0eedafdaff44203ab317e176
Author: Michel Normand <normand@fr.ibm.com>
Date:   Mon May 18 22:27:36 2009 +0200

    lxc-checkpoint ad lxc-restart to return 255 in case of error
    
    to have same exit code for all lxc commands
    
    Note that the lxc-restart is not yet reporting
    the error of restarted application as done with lxc-start.
    
    Signed-off-by: Michel Normand <normand@fr.ibm.com>
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit c8f55b0eff9386b52c21830c59c728d144dbb660
Author: Michel Normand <normand@fr.ibm.com>
Date:   Mon May 18 22:27:36 2009 +0200

    lxc-freeze and lxc-unfreeze to return 255 in case of error
    
    to have same exit code for all lxc commands
    
    Signed-off-by: Michel Normand <normand@fr.ibm.com>
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit f4072342e0b6f1d9ce40fa8e6ecaad60be9ddd78
Author: Michel Normand <normand@fr.ibm.com>
Date:   Mon May 18 22:27:35 2009 +0200

    correct error reporting for lxc_setstate
    
    there was a missing init of local variable
    
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
    Signed-off-by: Michel Normand <normand@fr.ibm.com>

commit 79507e493e7a6d2c2d80b34b90b03d00edcc4f1c
Author: Michel Normand <normand@fr.ibm.com>
Date:   Mon May 18 22:27:35 2009 +0200

    lxc-destroy return 255 in case of error
    
    to have same exit code for all lxc commands
    
    Signed-off-by: Michel Normand <normand@fr.ibm.com>
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit 7f8306138afadb81b6794815637a6851f44519a8
Author: Michel Normand <normand@fr.ibm.com>
Date:   Mon May 18 22:27:35 2009 +0200

    lxc-create to return 255 in case of error
    
    to have same exit code for all lxc commands
    
    Signed-off-by: Michel Normand <normand@fr.ibm.com>
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit 23075e69dc219c2a955a2c30c8600aacd0b68651
Author: Michel Normand <normand@fr.ibm.com>
Date:   Mon May 18 22:27:35 2009 +0200

    lxc-stop to return 255 in case of error
    
    to have same exit code for all lxc commands
    
    Signed-off-by: Michel Normand <normand@fr.ibm.com>
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit b0ed5e6423ca1f0b74f8c0ad12901c845e3ffbd1
Author: Michel Normand <normand@fr.ibm.com>
Date:   Mon May 18 22:27:35 2009 +0200

    lxc-execute to report exit code of started application
    
    The exit code of the application as reported by lxc-execute is:
    0-126       exit code of the application itself
    128+n       signal n received by the application
    255         lxc error
    
    Note that this is the same type of changes as done
    for lxc-start command line.
    
    Signed-off-by: Michel Normand <normand@fr.ibm.com>
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit 8559e7039c60be8a91a372541ed4ca30ca398530
Author: Michel Normand <normand@fr.ibm.com>
Date:   Mon May 18 22:27:35 2009 +0200

    add support of lxc log file to lxc-init
    
    pass to lxc-init the log options given to lxc-execute
    (in fact logfile logpriority and quiet)
    
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
    Signed-off-by: Michel Normand <normand@fr.ibm.com>

commit e043236e2a35948aeeb3cf85feab7c2f1e2b1fd1
Author: Michel Normand <normand@fr.ibm.com>
Date:   Mon May 18 22:27:34 2009 +0200

    lxc-start to report exit code of started application
    
    The exit code of the application as reported by lxc-start is:
    0-126       exit code of the application itself
    128+n       signal n received by the application
    255         lxc error
    
    Signed-off-by: Michel Normand <normand@fr.ibm.com>
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit 41cfbac9dd3e449dfda6fd908f8e13cc4ec40990
Author: Michel Normand <normand@fr.ibm.com>
Date:   Mon May 18 22:11:46 2009 +0200

    add long options step4
    
    add the long options to the remaining lxc_*.c files
    that need changes in struct lxc_arguments.
    
    Signed-off-by: Michel Normand <normand@fr.ibm.com>
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit 4237c6ca1f44de0345fbd63acc762401aaf49c68
Author: Michel Normand <normand@fr.ibm.com>
Date:   Mon May 18 22:11:46 2009 +0200

    add long options step3
    
    add the long options to remaining lxc_*.c  files
    that do not impact the struct lxc_arguments
    
    Signed-off-by: Michel Normand <normand@fr.ibm.com>
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit 9618063c87c64f9d8b154ef539c644c7ec382339
Author: Michel Normand <normand@fr.ibm.com>
Date:   Mon May 18 22:11:45 2009 +0200

    add long options step2
    
    add the long options to lxc-start
    with a small change in lxc_start proto to avoid compilation warning
    
    Signed-off-by: Michel Normand <normand@fr.ibm.com>
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit cda02a28c0f41feb359ebbddd68ed5f1dcd4930e
Author: Michel Normand <normand@fr.ibm.com>
Date:   Mon May 18 22:11:45 2009 +0200

    add long options step1
    
    add the long options to lxc-execute as an exemple
    of usage of the new functions added in src/lxc/arguments.*
    
    Signed-off-by: Michel Normand <normand@fr.ibm.com>
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit 441e49639508dce2a3fd94dabe5f40fead110ebf
Author: Michel Normand <normand@fr.ibm.com>
Date:   Mon May 18 22:11:45 2009 +0200

    add quiet option
    
    This added quiet option allow to disable
    the reporting via stderr of the lxc error messages.
    
    Note that the usage function is still printing in case of error,
    but will be removed by later patches
    
    Signed-off-by: Michel Normand <normand@fr.ibm.com>
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit fcffb59fc8d806252ccbf188c3dbd08cc1a68172
Author: Michel Normand <normand@fr.ibm.com>
Date:   Mon May 18 22:11:45 2009 +0200

    in lxc-unshare remove log options
    
    remove the -o and -l log options in src/lxc-unshared.c
    because these are useless for such a basic test command.
    It is sufficient to report the error to stderr.
    
    Signed-off-by: Michel Normand <normand@fr.ibm.com>
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit 4c200d12e0ef2236cd1f99831a04713faa951a75
Author: Michel Normand <normand@fr.ibm.com>
Date:   Sun May 17 13:43:51 2009 +0200

    report error in lxc_get_lock
    
    report error in lxc_get_lock and remove the call to lxc_strerror
    that become useless for these errors.
    
    Signed-off-by: Michel Normand <normand@fr.ibm.com>
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit 305dbab7e69c94f9abe2f343f9398b48c7c900d8
Author: Michel Normand <normand@fr.ibm.com>
Date:   Sun May 17 13:43:51 2009 +0200

    create a new lxc_check_lock function
    
    added in src/lock.c to replace call to lxc_get_lock and lxc_put_lock,
    when only need to check if container is active or not.
    
    Signed-off-by: Michel Normand <normand@fr.ibm.com>
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit d737c0749582e05e29a6da8c177cc21515ddb50e
Author: Michel Normand <normand@fr.ibm.com>
Date:   Fri May 15 10:47:08 2009 +0200

    add a default stderror log appender
    
    This is adding a stderror log appender that is used as default one.
    
    Signed-off-by: Michel Normand <normand@fr.ibm.com>
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit 5fd8380be601c9f82708096a90a554d37f07b949
Author: Michel Normand <normand@fr.ibm.com>
Date:   Fri May 15 10:43:51 2009 +0200

    properly handle va_list in log_append functions
    
    the support of multiple appenders need to associate
    one va_list per appender.
    This is the purpose of this patch to copy the va_list
    before to call the appender.
    
    Signed-off-by: Michel Normand <normand@fr.ibm.com>
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit 31c53c2e1afc6c81ce4aad5ef4cb982cd2fea365
Author: Daniel Lezcano <daniel.lezcano@free.fr>
Date:   Thu May 14 21:28:27 2009 +0200

    Replace netlink by abstract unix socket
    
    Instead of messing with the netlink messages, let's
    use the abstract unix socket and assume we will have
    a single receiver and multiple sender.
    
    With this patch mcr-wait and mcr-monitor are mutually
    exclusive... for the moment.
    
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit 8b92dc3ab676044871f920841447cceb707cff7e
Author: Michel Normand <normand@fr.ibm.com>
Date:   Thu May 14 16:27:29 2009 +0200

    change lxc_cgroup_set/get functions to return -1
    
    and report error message as soon as detected error in these two functions
    
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
    Signed-off-by: Michel Normand <normand@fr.ibm.com>

commit 69c3910d1565bf8686ad9d693e8fbf5f823728b5
Author: Michel Normand <normand@fr.ibm.com>
Date:   Thu May 14 16:27:28 2009 +0200

    SYSERROR not to add end of line character
    
    I assume this is a typo error.
    
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
    Signed-off-by: Michel Normand <normand@fr.ibm.com>

commit 51cab6315f1500af5105cfbf56cc03b2ceefa0d9
Author: Michel Normand <normand@fr.ibm.com>
Date:   Thu May 14 15:52:03 2009 +0200

    add support of a lxc log file to cli
    
    this is adding -o and -l options to all cli of lxc
    
    Signed-off-by: Michel Normand <normand@fr.ibm.com>
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit 3ab87b66af0fd1ac967683a75278ea39fe554a70
Author: Michel Normand <normand@fr.ibm.com>
Date:   Thu May 14 15:52:03 2009 +0200

    remove fprintf to stderr and replace by ERROR call when needed
    
    do it in all cli, except:
    * the usage functions that will be removed by another patch
    * the lxc_init that need more work
    * the lxc_priority that is not used anymore
    
    Signed-off-by: Michel Normand <normand@fr.ibm.com>
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit 2e714984224cab00d2d420b820dcc013cea0dfb8
Author: Michel Normand <normand@fr.ibm.com>
Date:   Thu May 14 15:23:30 2009 +0200

    add error log in lxc_file_for_each_line
    
    this is required to log error where needed
    and to to avoid additionnal log later on.
    
    Signed-off-by: Michel Normand <normand@fr.ibm.com>
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit 487f4ee9f8a617ddcb6559d7870fca18d8342984
Author: Michel Normand <normand@fr.ibm.com>
Date:   Thu May 14 15:23:30 2009 +0200

    change lxc-cgroup parameter checking
    
    required to support either:
    lxc-cgroup -n foo subsystem value
    lxc-cgroup -nfoo  subsystem value
    
    Signed-off-by: Michel Normand <normand@fr.ibm.com>
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit a4255c0807cbdd7354a5244af79b65e1efb9e245
Author: Michel Normand <normand@fr.ibm.com>
Date:   Thu May 14 15:11:40 2009 +0200

    change lxc-unshare options
    
    replace the specific clone options by a -s option
    with the Ored list of namespaces to be cloned.
    
    take the opportunity of this change to have
    the -u <uid> option to not automatically set
    the clone flag to CLONE_NEWUSER but to be dependant
    of the new -s USER option.
    
    Signed-off-by: Michel Normand <normand@fr.ibm.com>
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit d00184d36137ca2aae2f7e868bb529cf68f08371
Author: Michel Normand <normand@fr.ibm.com>
Date:   Thu May 14 15:11:40 2009 +0200

    replace fprintf by ERROR call in lxc_unshare.c
    
    Do it except for the usage functions that will be removed by another patch
    
    This is a follow on a previous patch that treated
    all src/lxc/lxc_*.c but this file.
    
    Signed-off-by: Michel Normand <normand@fr.ibm.com>
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit 1615dc39e21bb11a3ec812515815749f0e28e3a9
Author: Michel Normand <normand@fr.ibm.com>
Date:   Thu May 14 15:11:39 2009 +0200

    avoid segfault on git-unshare
    
    avoid segfault when invalid parameter
    git-unshare -u 666666
    
    and improve error reporting
    
    Signed-off-by: Michel Normand <normand@fr.ibm.com>
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit be43f17e5863a532cfe1647dcd077a3712243d6b
Author: Daniel Lezcano <dlezcano@fr.ibm.com>
Date:   Thu May 7 19:36:33 2009 +0200

    autoassign tty number
    
    When no tty number is specified in the command line,
    let the tty service to provide choose one available
    tty and provide this one.
    
    The documentation is updated wrt this modification and
    I did a little fix to generate the date of the documentation.
    
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit 1bc5cc8c0bf725d2baa518db1e2df80cbdff5bd8
Author: Daniel Lezcano <dlezcano@fr.ibm.com>
Date:   Wed Apr 29 17:49:04 2009 +0200

    export-fine-grain-api-for-start
    
    Export the fine grain api of lxc to be usable for external
    component which wants to have more control on the container.
    
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit 59eb99bad452c25fd25817e3e4783a9fe4c57c68
Author: Daniel Lezcano <dlezcano@fr.ibm.com>
Date:   Wed Apr 29 17:49:04 2009 +0200

    encapsulate the lxc code
    
    Make the lxc code more modular and use it for lxc_start
    function.
    
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

commit ca5f79263d3c78f4fb997d720fc546ba157ba4c4
Author: Daniel Lezcano <dlezcano@fr.ibm.com>
Date:   Wed Apr 29 17:49:04 2009 +0200

    define a handler to manage a container
    
    Define a handler to store the resource informations for the container.
    That allows to factor out some code and will help to encapsulate a
    little more the 'start' code which is too big.
    
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
