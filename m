From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 0/4] CGroup: Support for named and empty hierarchies
Date: Wed, 22 Jul 2009 12:50:24 -0700
Message-ID: <20090722194644.7481.47805.stgit@menage.mtv.corp.google.com>
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
To: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

The following series implements support for named cgroup hierarchies,
and for cgroup hierarchies that have no bound subsystems.

This is a subset of the patch series that I sent out as an RFC earlier
in the month; I'm not pushing the additional support for
multiply-bound hierarchies at this point.

Signed-off-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

---

Paul Menage (4):
      Support named cgroups hierarchies
      Move the cgroup debug subsys into cgroup.c to access internal state
      Add a back-pointer from struct cg_cgroup_link to struct cgroup
      Allow cgroup hierarchies to be created with no bound subsystems


 Documentation/cgroups/cgroups.txt |   19 +
 kernel/Makefile                   |    1 
 kernel/cgroup.c                   |  660 +++++++++++++++++++++++++++++--------
 kernel/cgroup_debug.c             |  105 ------
 4 files changed, 533 insertions(+), 252 deletions(-)
 delete mode 100644 kernel/cgroup_debug.c
