From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [RFC v16][PATCH 35/43] c/r (ipc): export interface from ipc/shm.c to
	delete ipc shm
Date: Wed, 27 May 2009 13:33:01 -0400
Message-ID: <1243445589-32388-36-git-send-email-orenl__16366.9872018092$1243446343$gmane$org@cs.columbia.edu>
References: <1243445589-32388-1-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1243445589-32388-1-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Linus Torvalds <torvalds-3NddpPZAyC0@public.gmane.org>, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Export shmctl_down() which will be used in the next patch during
restart to delete an ipc shm (the shm is mapped already, so it
won't be lost).

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 include/linux/shm.h |    4 ++++
 ipc/shm.c           |    4 ++--
 2 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/include/linux/shm.h b/include/linux/shm.h
index eca6235..ec36e99 100644
--- a/include/linux/shm.h
+++ b/include/linux/shm.h
@@ -118,6 +118,10 @@ static inline int is_file_shm_hugepages(struct file *file)
 }
 #endif
 
+struct ipc_namespace;
+extern int shmctl_down(struct ipc_namespace *ns, int shmid, int cmd,
+		       struct shmid_ds __user *buf, int version);
+
 #endif /* __KERNEL__ */
 
 #endif /* _LINUX_SHM_H_ */
diff --git a/ipc/shm.c b/ipc/shm.c
index 7dd5f0c..8aba22f 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -598,8 +598,8 @@ static void shm_get_stat(struct ipc_namespace *ns, unsigned long *rss,
  * to be held in write mode.
  * NOTE: no locks must be held, the rw_mutex is taken inside this function.
  */
-static int shmctl_down(struct ipc_namespace *ns, int shmid, int cmd,
-		       struct shmid_ds __user *buf, int version)
+int shmctl_down(struct ipc_namespace *ns, int shmid, int cmd,
+		struct shmid_ds __user *buf, int version)
 {
 	struct kern_ipc_perm *ipcp;
 	struct shmid64_ds shmid64;
-- 
1.6.0.4
