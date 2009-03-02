From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH 3/4] devcgroup: show correct file mode
Date: Mon, 02 Mar 2009 10:15:31 +0800
Message-ID: <49AB4143.9050704__3326.2743884281$1235960283$gmane$org@cn.fujitsu.com>
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
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

devices.allow and devices.deny are write-only, and devices.list is read-only.

Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 security/device_cgroup.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/security/device_cgroup.c b/security/device_cgroup.c
index 3aacd0f..b13fbb8 100644
--- a/security/device_cgroup.c
+++ b/security/device_cgroup.c
@@ -439,16 +439,19 @@ static struct cftype dev_cgroup_files[] = {
 		.name = "allow",
 		.write_string  = devcgroup_access_write,
 		.private = DEVCG_ALLOW,
+		.mode = 0200,
 	},
 	{
 		.name = "deny",
 		.write_string = devcgroup_access_write,
 		.private = DEVCG_DENY,
+		.mode = 0200,
 	},
 	{
 		.name = "list",
 		.read_seq_string = devcgroup_seq_read,
 		.private = DEVCG_LIST,
+		.mode = 0444,
 	},
 };
 
-- 1.5.4.rc3 
