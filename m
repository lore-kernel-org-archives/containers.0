From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH 1/4] cgroup debug: show correct file mode
Date: Mon, 02 Mar 2009 10:13:50 +0800
Message-ID: <49AB40DE.4090704@cn.fujitsu.com>
References: <49AB40BF.4030706@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <49AB40BF.4030706-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

All control files in debug subsystem are read-only.

Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 kernel/cgroup_debug.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/kernel/cgroup_debug.c b/kernel/cgroup_debug.c
index daca620..2ba54c6 100644
--- a/kernel/cgroup_debug.c
+++ b/kernel/cgroup_debug.c
@@ -71,25 +71,30 @@ static struct cftype files[] =  {
 	{
 		.name = "cgroup_refcount",
 		.read_u64 = cgroup_refcount_read,
+		.mode = 0444,
 	},
 	{
 		.name = "taskcount",
 		.read_u64 = taskcount_read,
+		.mode = 0444,
 	},
 
 	{
 		.name = "current_css_set",
 		.read_u64 = current_css_set_read,
+		.mode = 0444,
 	},
 
 	{
 		.name = "current_css_set_refcount",
 		.read_u64 = current_css_set_refcount_read,
+		.mode = 0444,
 	},
 
 	{
 		.name = "releasable",
 		.read_u64 = releasable_read,
+		.mode = 0444,
 	},
 };
 
-- 1.5.4.rc3 
