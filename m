From: jacob.jun.pan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org
Subject: [RFC PATCH 0/2] per cgroup timer slack and freezer duty cycle
Date: Wed,  1 Dec 2010 11:00:10 -0800
Message-ID: <1291230012-9536-1-git-send-email-jacob.jun.pan__19050.3599042588$1291230548$gmane$org@linux.intel.com>
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
To: container cgroup <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Ar
Cc: Jacob Pan <jacob.jun.pan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
List-Id: containers.vger.kernel.org

From: Jacob Pan <jacob.jun.pan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>

Hi,

These are two cgroup related patches for supporting power friendly
behavior of batch jobs in a cgroup.
The main usage is for managing background applications where more
relaxed timer rounding effect and reduced CPU time are desired.

Thanks,

Jacob

Jacob Pan (2):
  cgroup: add per cgroup timer_slack_ns
  cgroup/freezer: add per freezer duty ratio control

 include/linux/cgroup.h    |    1 +
 include/linux/init_task.h |    3 +-
 kernel/cgroup.c           |   43 ++++++++++++
 kernel/cgroup_freezer.c   |  157 ++++++++++++++++++++++++++++++++++++++++++++-
 4 files changed, 201 insertions(+), 3 deletions(-)
