From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: lxc-0.6.1 released
Date: Tue, 24 Mar 2009 19:03:26 +0100
Message-ID: <49C9206E.8030603@fr.ibm.com>
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
To: LXC Development <lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org


* fixes several compilation problems and arch dependant buggy functions.
* adds mtu option setting - Takano, thanks for the benchmarking and the 
analysis :)
* fixes capabilties dilemma by letting the user to set / drop the 
capabilities via 'lxc-setcap'
* fixes bind mounts to be propagated to the container

Thanks all for the patches and the feedbacks !


git-log --pretty=oneline --abbrev-commit lxc_0_6_0..lxc_0_6_1

1b36359... increment minor version number
237315f... Use a specific script to set the capabilities
75d09f8... set mtu for netdev
442cbbe... Add lxc.network.mtu configuration (resend)
dfdcea5... Fix capability setting for lxc-init
bfa3802... Add powerpc signalfd syscall numbers
3619350... CONTRIBUTING: specify where one can send patches
e81c7f2... CONTRIBUTING: fix two typos
dbdab2f... lxc-checkconfig: Allow to override grep and config
84a1564... lxc-checkconfig: look in one more place
a25ba7a... Install lxc-init in libexec dir
d0dfcfb... Add .gitignore and avoid annoying interaction between 
compiled files and git
fdc0332... Use the rbind mount for the rootfs
7e7f51d... lxc-checkconfig fails on a kernel compiled without IKCONFIG_PROC.
30761e8... s390 sys_clone is backwards
47f3833... define s390x signalfd for old headers
8ca6173... define signalfd patch
216061b... liblxc: Remove unused variable
b7f85cc... liblxc: Add username and uid lookup/check.
3cf586a... liblxc: Fix compiler warning
656994b... liblxc: Handle missing PR_CAPBSET_DROP definition
54b1eb6... liblxc: create a fedore template container

git-diff --stats lxc_0_6_0..lxc_0_6_1

 .gitignore                 |   90 ++++++++++
 CONTRIBUTING               |    8
 configure.in               |   20 +-
 lxc.spec.in                |   22 --
 scripts/Makefile.am        |    1
 scripts/lxc-fedora.in      |  404 
+++++++++++++++++++++++++++++++++++++++++++++
 src/lxc/Makefile.am        |   47 +----
 src/lxc/lxc-checkconfig.in |   32 ++-
 src/lxc/lxc-setcap.in      |  103 +++++++++++
 src/lxc/lxc.h              |    2
 src/lxc/lxc_conf.c         |   47 ++++-
 src/lxc/lxc_conf.h         |    1
 src/lxc/lxc_config.c       |   24 ++
 src/lxc/lxc_execute.c      |    2
 src/lxc/lxc_namespace.h    |    4
 src/lxc/lxc_unshare.c      |   37 +++-
 src/lxc/namespace.h        |    4
 src/lxc/network.c          |   48 +++++
 src/lxc/network.h          |    5
 src/lxc/start.c            |   42 ++++
 20 files changed, 849 insertions(+), 94 deletions(-)
