From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [RFC][PATCH 4/4] checkpoint/restart: simplify cr_scan_fds()
Date: Tue, 02 Dec 2008 10:57:42 -0800
Message-ID: <20081202185742.CB0FDECC@kernel>
References: <20081202185734.F740150C@kernel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20081202185734.F740150C@kernel>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org


I think having all the allocations in one place, plus the
reduction in the number of lines speaks for itself.  In
any case, this is last in the series and can be dropped if
you don't like it.

---

 linux-2.6.git-dave/checkpoint/ckpt_file.c |   13 ++++---------
 1 file changed, 4 insertions(+), 9 deletions(-)

diff -puN checkpoint/ckpt_file.c~fix-cr_scan_fds-realloc checkpoint/ckpt_file.c
--- linux-2.6.git/checkpoint/ckpt_file.c~fix-cr_scan_fds-realloc	2008-12-02 10:26:53.000000000 -0800
+++ linux-2.6.git-dave/checkpoint/ckpt_file.c	2008-12-02 10:26:53.000000000 -0800
@@ -38,6 +38,7 @@ int cr_scan_fds(struct files_struct *fil
 	int i, n = 0;
 	int tot = CR_DEFAULT_FDTABLE;
 
+retry:
 	fds = kmalloc(tot * sizeof(*fds), GFP_KERNEL);
 	if (!fds)
 		return -ENOMEM;
@@ -55,18 +56,12 @@ int cr_scan_fds(struct files_struct *fil
 		if (!fcheck_files(files, i))
 			continue;
 		if (n == tot) {
-			/*
-			 * fcheck_files() is safe with drop/re-acquire
-			 * of the lock, because it tests:  fd < max_fds
-			 */
+			/* we undershot the size of fds[] */
 			spin_unlock(&files->file_lock);
 			rcu_read_unlock();
 			tot *= 2;	/* won't overflow: kmalloc will fail */
-			fds = krealloc(fds, tot * sizeof(*fds), GFP_KERNEL);
-			if (!fds)
-				return -ENOMEM;
-			rcu_read_lock();
-			spin_lock(&files->file_lock);
+			kfree(fds);
+			goto retry;
 		}
 		fds[n++] = i;
 	}
_
