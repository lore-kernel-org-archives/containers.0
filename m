From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 0/9] [RFC] CGroup Hierarchy Extensions
Date: Wed, 01 Jul 2009 19:10:52 -0700
Message-ID: <20090702020624.14469.47066.stgit__16782.1085233756$1246500702$gmane$org@menage.mtv.corp.google.com>
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
To: lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

The following series adds support for:

- named cgroup hierarchies
- cgroup hierarchies with no bound subsystems
- cgroup subsystems that can be bound to multiple hierarchies

This allows more flexibility when constructing/mounting cgroups
hierarchies, and allows functionality that's not tied to specific
external resources to be made available on multiple cgroups
hierarchies rather than just one.

A few simple example cgroups subsystems that are multi-bindable are
included in the patch series.

---

Paul Menage (9):
      [RFC] Support named cgroups hierarchies
      [RFC] Move the cgroup debug subsys into cgroup.c to access internal state
      [RFC] Add a back-pointer from struct cg_cgroup_link to struct cgroup
      [RFC] Allow cgroup hierarchies to be created with no bound subsystems
      [RFC] Remove cgroup_subsys.root pointer
      [RFC] Remove the cgroup_subsys.bind callback
      [RFC] Support multiply-bindable cgroup subsystems
      [RFC] Example multi-bindable subsystem: a per-cgroup notes field
      [RFC] Example multi-bindable subsystem: a max-depth controller


 Documentation/cgroups/cgroups.txt |    8 
 include/linux/cgroup.h            |   55 ++
 include/linux/cgroup_subsys.h     |   14 +
 init/Kconfig                      |   17 +
 kernel/Makefile                   |    3 
 kernel/cgroup.c                   |  905 +++++++++++++++++++++++++++----------
 kernel/cgroup_debug.c             |  105 ----
 kernel/info_cgroup.c              |  133 +++++
 kernel/maxdepth_cgroup.c          |   80 +++
 9 files changed, 938 insertions(+), 382 deletions(-)
 delete mode 100644 kernel/cgroup_debug.c
 create mode 100644 kernel/info_cgroup.c
 create mode 100644 kernel/maxdepth_cgroup.c
