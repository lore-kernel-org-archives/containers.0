From: Ben Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH v2 0/3] CGroups: cgroup member list enhancement/fix
Date: Fri, 10 Jul 2009 16:01:49 -0700
Message-ID: <20090710230043.16778.29656.stgit@hastromil.mtv.corp.google.com>
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
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

(This is a revision of the patch series in http://lkml.org/lkml/2009/7/2/464 )

The following series adds a "cgroup.procs" file to each cgroup that reports
unique tgids rather than pids, and fixes a pid namespace bug in the existing
"tasks" file that could cause readers in different namespaces to interfere
with one another.

This patch series implements a superset of the functionality of (and was
written at the same time as) Li Zefan's pid namespace bugfix patch (from
http://lkml.org/lkml/2009/7/1/559 ). These patches can either be rewritten to
be applied on top of Li's patch, or be applied as they are with Li's patch
reversed.

---

Ben Blum (3):
      Quick vmalloc vs kmalloc fix to the case where array size is too large
      Ensures correct concurrent opening/reading of pidlists across pid namespaces
      Adds a read-only "procs" file similar to "tasks" that shows only unique tgids


 include/linux/cgroup.h |   46 +++++-
 kernel/cgroup.c        |  378 ++++++++++++++++++++++++++++++++++--------------
 2 files changed, 309 insertions(+), 115 deletions(-)
