From: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
Subject: [PATCH v4 0/4] cgroups: support for module-loadable subsystems
Date: Thu, 31 Dec 2009 00:10:50 -0500
Message-ID: <20091231051050.GA714__36946.055890485$1262236321$gmane$org@andrew.cmu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org
List-Id: containers.vger.kernel.org

[This is a revision of http://lkml.org/lkml/2009/12/21/211 ]

This patch series implements support for building, loading, and
unloading subsystems as modules, both within and outside the kernel
source tree. It provides an interface cgroup_load_subsys() and
cgroup_unload_subsys() which modular subsystems can use to register and
depart during runtime. The net_cls classifier subsystem serves as the
example for a subsystem which can be converted into a module using these
changes.

Patch #1 sets up the subsys[] array so its contents can be dynamic as
modules appear and (eventually) disappear. Iterations over the array are
modified to handle when subsystems are absent, and the dynamic section
of the array is protected by cgroup_mutex.

Patch #2 implements an interface for modules to load subsystems, called
cgroup_load_subsys, similar to cgroup_init_subsys, and adds a module
pointer in struct cgroup_subsys.

Patch #3 adds a mechanism for unloading modular subsystems, which
includes a more advanced rework of the rudimentary reference counting
introduced in patch 2.

Patch #4 modifies the net_cls subsystem, which already had some module
declarations, to be configurable as a module, which also serves as a
simple proof-of-concept.

Part of implementing patches 2 and 4 involved updating css pointers in
each css_set when the module appears or leaves. In doing this, it was
discovered that css_sets always remain linked to the dummy cgroup,
regardless of whether or not any subsystems are actually bound to it
(i.e., not mounted on an actual hierarchy). The subsystem loading and
unloading code therefore should keep in mind the special cases where the
added subsystem is the only one in the dummy cgroup (and therefore all
css_sets need to be linked back into it) and where the removed subsys
was the only one in the dummy cgroup (and therefore all css_sets should
be unlinked from it) - however, as all css_sets always stay attached to
the dummy cgroup anyway, these cases are ignored. Any fix that addresses
this issue should also make sure these cases are addressed in the
subsystem loading and unloading code.

-- bblum

---
 Documentation/cgroups/cgroups.txt |    9
 include/linux/cgroup.h            |   18 +
 kernel/cgroup.c                   |  388 +++++++++++++++++++++++++++++++++-----
 net/sched/Kconfig                 |    5
 net/sched/cls_cgroup.c            |   36 ++-
 5 files changed, 400 insertions(+), 56 deletions(-)
