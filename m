From: "Kirill A. Shutsemov" <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
Subject: [PATCH, v3 0/2] Timer slack cgroup subsystem
Date: Wed,  2 Feb 2011 22:47:34 +0200
Message-ID: <1296679656-31163-1-git-send-email-kirill__31329.6442888261$1296679954$gmane$org@shutemov.name>
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
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: jacob.jun.pan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Arjan van de Ven <arjan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
List-Id: containers.vger.kernel.org

From: Kirill A. Shutemov <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>

Changelog:
v3: 
 - rework interface
 - s/EXPORT_SYMBOL/EXPORT_SYMBOL_GPL/
v2:
 - fixed with CONFIG_CGROUP_TIMER_SLACK=y
v1:
 - initial revision

Kirill A. Shutemov (2):
  cgroups: export cgroup_iter_{start,next,end}
  cgroups: introduce timer slack subsystem

 include/linux/cgroup_subsys.h |    6 +
 include/linux/init_task.h     |    4 +-
 init/Kconfig                  |   10 ++
 kernel/Makefile               |    1 +
 kernel/cgroup.c               |    3 +
 kernel/cgroup_timer_slack.c   |  242 +++++++++++++++++++++++++++++++++++++++++
 kernel/sys.c                  |   24 +++-
 7 files changed, 283 insertions(+), 7 deletions(-)
 create mode 100644 kernel/cgroup_timer_slack.c

-- 
1.7.3.5
