From: Marian Marinov <mm-108MBtLGafw@public.gmane.org>
Subject: [PATCH] IPC initialize shmmax and shmall from the current value not
	the default
Date: Sun, 04 May 2014 01:48:29 +0300
Message-ID: <5365723D.7030303@1h.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
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
To: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, davidlohr-VXdhtT5mjnY@public.gmane.org, n-horiguchi-PaJj6Psr51x8UrSeD/g0lQ@public.gmane.org, Greg KH <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>, manfred-nhLOkwUX5cPe2c5cEj3t2g@public.gmane.org, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

When we are creating new IPC namespace that should be cloned from the current namespace it is a good idea to copy the 
values of the current shmmax and shmall to the new namespace.

Copying the values of the init_ipc_ns would allow us to create new ipc namespaces with different values without granting 
them privileges to change those values.

Here is the proposed patch:

---
  ipc/shm.c | 9 +++++++--
  1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/ipc/shm.c b/ipc/shm.c
index 7a51443..b7a4728 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -74,8 +74,13 @@ static int sysvipc_shm_proc_show(struct seq_file *s, void *it);

  void shm_init_ns(struct ipc_namespace *ns)
  {
-       ns->shm_ctlmax = SHMMAX;
-       ns->shm_ctlall = SHMALL;
+       if (ns == &init_ipc_ns) {
+               ns->shm_ctlmax = SHMMAX;
+               ns->shm_ctlall = SHMALL;
+       } else {
+               ns->shm_ctlmax = init_ipc_ns.shm_ctlmax;
+               ns->shm_ctlall = init_ipc_ns.shm_ctlall;
+       }
         ns->shm_ctlmni = SHMMNI;
         ns->shm_rmid_forced = 0;
         ns->shm_tot = 0;
-- 
1.8.4

-- 
Marian Marinov
Founder & CEO of 1H Ltd.
Jabber/GTalk: hackman-/eSpBmjxGS4dnm+yROfE0A@public.gmane.org
ICQ: 7556201
Mobile: +359 886 660 270
