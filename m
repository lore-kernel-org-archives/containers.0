From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: lxc : linux container tools 0.6.2 release
Date: Wed, 29 Apr 2009 17:46:23 +0200
Message-ID: <49F8764F.5070906@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
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
To: LXC Development <lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Guido Trotter <ultrotter-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Jiri Slaby <jslaby-AlSwsSmVLrQ@public.gmane.org>, "Michael K. Johnson" <johnsonm-bTnYInOZY08AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org


http://lxc.sourceforge.net/lxc.html

Release Name: lxc-0.6.2

Notes:
  * fixed autogen.sh and reconfigure problem reported by Michael K Johnson

* Guido Trotter fixed the localstate directory to the right path

  * Michel Normand fixed O_CLOEXEC definition for distro with older =

glibc (eg. redhat 5)

  * Michel Normand fixed libtool copy problem when compiling in a =

directory different from the source tree

  * Daniel Lezcano cleaned up some code and improve container creation

  * Cedric Le Goater added a new logging facility

  * M=F4she van der Sterre fixed inherited tty fd in the container

  * Daniel Lezcano added the mtu size option to fit the jumbo frame =

size, benchmarking was done by Ryousei Takano

  * Ryousei Takano added support for various mount options

Changes:
commit 6b9f39176cc9d898d339f8344291b922bfde19a8
Author: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>

     Revert "make the log fd thread safe"

commit f8dafdbb1591b545edb6a4b6bda889819d619a87
Author: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>

     rename configure.in to configure.ac

commit 8db2cb8e0d1ee9e6edb0b5e9bd158c8789a5e5b6
Author: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>

     remove m4 dir usage

commit ccf1319832ffeb8e07fcef9bfe67e96e283fead7
Author: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>

     add aclocal include in makefile

commit 5b2b6e7e2d5c9b8b28f9ec3864ff5dde223a3669
Author: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>

     inc the minor version

commit 01f3fe315625c625abd28742cc7a604e75f44c02
Author: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>

     Setting execution permission for the file

commit 91e1b53961680a77faef97ad00a49adca2cf78d8
Author: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>

     swap doc compilation order

commit 8cdca6725329850ea5f5574cab472331fc602fab
Author: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>

     add the autogen script in the dist tarball

commit ba5b25827947a33ce615a177f0a2afb2798da60a
Author: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>

     rename bootstrap to autogen.sh

commit e0b4037dfad4676d977c147426657fc1406efd2f
Author: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>

     add the missing header in the log file

commit eabbb2f0c0cc1c0fe15efef514cc37e4c60725ae
Author: Michel Normand <normand-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>

     locally define O_CLOEXEC

commit 2c9bd0073f29573181dc16a840c674dacc8a33fd
Author: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>

     make the log fd thread safe

commit dcb7355b2fa4bd63c1d015a943b3d54264709083
Author: Cedric Le Goater <legoater-GANU6spQydw@public.gmane.org>

     lxc: cleanup log

commit 36eb9bdef1123a93f9e441a5df386c4bd0168f27
Author: Cedric Le Goater <legoater-GANU6spQydw@public.gmane.org>

     lxc: use new logging system

commit cb8c5720bdd14249e66060cda0e0f5d2f95c0ecd
Author: Cedric Le Goater <legoater-GANU6spQydw@public.gmane.org>

     lxc: introduce log4c style logging

commit a57cf79e58fa5c28f3d9ea566c4d833db9b91e8b
Author: Michel Normand <normand-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>

     exclude generated tarball from git managed files

commit 4f916514e8b8f9a79f8b36af11c55515df70d92b
Author: Michel Normand <normand-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>

     make the libtoolize files to be copy not

commit 998ac6763fa12758ad9bda568ddd29d592e0fc19
Author: Ryousei Takano <takano-ryousei-XSdjUN4cZ6fPDbFq/vQRIQ@public.gmane.org>

     Add support for various mount options

commit b035ad62e6f5f8a706c8e8c21405b5ef6b4d58d6
Author: M=F4she van der Sterre <me-A/3C56C7qwM@public.gmane.org>

     prevent tty fd to be inherited in the container

commit 8de09ef5560c418d055a531efeabc5adee345ace
Author: M=F4she van der Sterre <moshevds-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

     check multiple devpts instance

commit f6235d06350d4c58e54a1c1bc478b2da2ecbc119
Author: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>

     don't remove init file in the stop function

commit 34e7030e83eff25f66bfd6505f2f479a41a4d3b6
Author: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>

     speed container creation/destruction

commit 3f21c11481b50030bc073a279c8cbe8f03f57138
Author: Ryousei Takano <takano-ryousei-XSdjUN4cZ6fPDbFq/vQRIQ@public.gmane.org>

     Fix compile warnings

commit abf424cf20ee2e3261abf95d17df08ff2a723640
Author: Guido Trotter <ultrotter-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

     $(localstatedir) !=3D $(prefix)/var

commit 85a3182189e9f8eca79a925618e157774e0e8617
Author: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>

     add error.h header

commit 089cd8b878d1d2ac78a6ab13878c61cb23213971
Author: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>

     move lxc_conf_init to conf.c

commit a871ff6bdf3925e7a13f7a1b5ea40ca936654537
Author: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>

     cleanup config.h

commit 35d2c3e71d5e7ada9878e9cb8f6039f0b02b3458
Author: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>

     cleanup state.h

commit 951cc719a3e71a3ac98c92b343f2391af400e830
Author: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>

     cleanup list.h

commit 731cc33fb7e75085e4281f295c6c9d806f8d3ad5
Author: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>

     cleanup log.h

commit 13954cce6335d9a642ebd9859c60a2f01c4513ec
Author: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>

     cleanup conf.h

commit 170d528eeac7c9d5440a6fb6b97c7c24862bee73
Author: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>

     cleanup cgroup.h

commit c6d1536e2b96229cd7935c380c3de2c9e93fb94a
Author: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>

     cleanup lock.h

commit 61ba7fe64ad8f06b6a836bd5d3eddb15dc7c194a
Author: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>

     cleanup namespace.h

commit e65b846976ddacdce5774bb0ba11c7738e896cf1
Author: Ryousei Takano <takano-ryousei-XSdjUN4cZ6fPDbFq/vQRIQ@public.gmane.org>

     Use 'uname -m' instead of arch

commit b44cb779a10c6c58fbdc4a28990edcd150e9770b
Author: Ryousei Takano <takano-ryousei-XSdjUN4cZ6fPDbFq/vQRIQ@public.gmane.org>

     Add mtu option setting for lxc-fedora

commit 81f6a40acf9a13bb1c5869a8b820a78e4c3ecccc
Author: Ryousei Takano <takano-ryousei-XSdjUN4cZ6fPDbFq/vQRIQ@public.gmane.org>

     Add mtu option setting for lxc-debian

commit eb14c10a414bcbb39cc29ebc82f5299aa36b6c30
Author: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>

     set the mtu before attaching to the bridge

commit 497353b66b504f12cf8b6e166bba7cb309486dc3
Author: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>

     change the api to export the network functions

commit b35f75882eed5fc40e0a0fb2ae2aeaf66c11df0e
Author: Ryousei Takano <takano-ryousei-XSdjUN4cZ6fPDbFq/vQRIQ@public.gmane.org>

     Fix trivial stuff for mtu option setting
