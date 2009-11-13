From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] eclone: fix do_alloc_pidmap bogosity on -EAGAIN
Date: Fri, 13 Nov 2009 15:05:13 -0600
Message-ID: <20091113210513.GA28117@us.ibm.com>
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
To: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

do_alloc_pidmap must not return 0 if it failed to find a pid.
Without this patch, doing eclone and choosing a pid which is in
use results in a massive chain of oopses.

(This applies on top of the v13 eclone patchset)

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 kernel/pid.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/kernel/pid.c b/kernel/pid.c
index 3ee52cd..8ad7b04 100644
--- a/kernel/pid.c
+++ b/kernel/pid.c
@@ -164,6 +164,7 @@ static int do_alloc_pidmap(struct pid_namespace *pid_ns, int last, int min,
 		rc = alloc_pidmap_page(map);
 		if (rc)
 			break;
+		rc = -EAGAIN;
 
 		if (likely(atomic_read(&map->nr_free))) {
 			do {
@@ -189,10 +190,8 @@ static int do_alloc_pidmap(struct pid_namespace *pid_ns, int last, int min,
 		} else {
 			map = &pid_ns->pidmap[0];
 			offset = min;
-			if (unlikely(last == offset)) {
-				rc = -EAGAIN;
+			if (unlikely(last == offset))
 				break;
-			}
 		}
 		pid = mk_pid(pid_ns, map, offset);
 	}
-- 
1.6.1
