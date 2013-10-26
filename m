From: Daniel Walker <dwalker-zu3NM2574RrQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 3/3] cgroups: remove calls to simple_kstrtoll
Date: Fri, 25 Oct 2013 19:33:13 -0700
Message-ID: <1382754793-8827-3-git-send-email-dwalker__21785.8984055512$1382755382$gmane$org@fifo99.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Signed-off-by: Daniel Walker <dwalker-zu3NM2574RrQT0dZR+AlfA@public.gmane.org>
---
 kernel/cgroup.c | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 41f71c3..bf8b891 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -2276,7 +2276,7 @@ static ssize_t cgroup_write_X64(struct cgroup_subsys_state *css,
 {
 	char buffer[CGROUP_LOCAL_BUFFER_SIZE];
 	int retval = 0;
-	char *end;
+	int ret;
 
 	if (!nbytes)
 		return -EINVAL;
@@ -2287,13 +2287,15 @@ static ssize_t cgroup_write_X64(struct cgroup_subsys_state *css,
 
 	buffer[nbytes] = 0;     /* nul-terminate */
 	if (cft->write_u64) {
-		u64 val = simple_strtoull(strstrip(buffer), &end, 0);
-		if (*end)
+		u64 val;
+		ret = kstrtoull(strstrip(buffer), 0, &val);
+		if (ret != 0)
 			return -EINVAL;
 		retval = cft->write_u64(css, cft, val);
 	} else {
-		s64 val = simple_strtoll(strstrip(buffer), &end, 0);
-		if (*end)
+		s64 val;
+		ret = kstrtoll(strstrip(buffer), 0, &val);
+		if (ret != 0)
 			return -EINVAL;
 		retval = cft->write_s64(css, cft, val);
 	}
-- 
1.8.3.2
