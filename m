From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH] devcgroup: remove unused variable
Date: Mon, 25 Aug 2008 10:22:22 +0800
Message-ID: <48B2175E.3070407__30890.7026578256$1219631352$gmane$org@cn.fujitsu.com>
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
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org


Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 security/device_cgroup.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/security/device_cgroup.c b/security/device_cgroup.c
index 9c625f6..d5c15a7 100644
--- a/security/device_cgroup.c
+++ b/security/device_cgroup.c
@@ -355,7 +355,7 @@ static int devcgroup_update_access(struct dev_cgroup *devcgroup,
 	struct dev_cgroup *cur_devcgroup;
 	const char *b;
 	char *endp;
-	int retval = 0, count;
+	int count;
 	struct dev_whitelist_item wh;
 
 	if (!capable(CAP_SYS_ADMIN))
@@ -432,7 +432,6 @@ static int devcgroup_update_access(struct dev_cgroup *devcgroup,
 	}
 
 handle:
-	retval = 0;
 	switch (filetype) {
 	case DEVCG_ALLOW:
 		if (!parent_has_perm(devcgroup, &wh))
-- 
1.5.4.rc3
