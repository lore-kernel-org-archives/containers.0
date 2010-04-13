From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 4/4] cr_tests: futex: pi: Set the FUTEX_WAITERS bit.
Date: Tue, 13 Apr 2010 15:25:15 -0700
Message-ID: <64e4bbbd602fbad76bafdff1946b93818c7ed26a.1271197507.git.matthltc@us.ibm.com>
References: <2925834e94ea965d668717d0c993b6bc02697799.1271197507.git.matthltc@us.ibm.com>
	<fb0d102d20653e6715ae7229e3d07263f98456ce.1271197507.git.matthltc@us.ibm.com>
	<4b62b2004556809368f788e9baaf39c529dc3d80.1271197507.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4b62b2004556809368f788e9baaf39c529dc3d80.1271197507.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
In-Reply-To: <2925834e94ea965d668717d0c993b6bc02697799.1271197507.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
References: <2925834e94ea965d668717d0c993b6bc02697799.1271197507.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Need to indicate to the kernel that we're waiting on the futex.
(See kernel source Documentation/pi-futex.txt).

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 futex/pi.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/futex/pi.c b/futex/pi.c
index a39964d..695eb0a 100644
--- a/futex/pi.c
+++ b/futex/pi.c
@@ -271,6 +271,7 @@ int do_lock_contended_pi_futex(int retries)
 {
 	int do_print = 1;
 
+	__sync_or_and_fetch(&pi_futex->counter, FUTEX_WAITERS);
 again:
 	if (futex(&pi_futex->counter, FUTEX_LOCK_PI, atomic_read(pi_futex),
 	      NULL, NULL, 0) == 0)
-- 
1.6.3.3
