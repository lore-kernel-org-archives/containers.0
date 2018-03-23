From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [REVIEW][PATCH 05/11] shm: Move struct shmid_kernel into ipc/shm.c
Date: Fri, 23 Mar 2018 14:16:08 -0500
Message-ID: <20180323191614.32489-5-ebiederm__45953.037220943$1521832576$gmane$org@xmission.com>
References: <87vadmobdw.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87vadmobdw.fsf_-_-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Cc: esyr-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jannh-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, khlebnikov-XoJtRXgx1JseBXzfvpsJ4g@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, prakash.sangappa-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Nagarathnam Muthusamy <nagarathnam.muthusamy-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

All of the users are now in ipc/shm.c so make the definition local to
that file to make code maintenance easier.  AKA to prevent rebuilding
the entire kernel when struct shmid_kernel changes.

Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 include/linux/shm.h | 23 -----------------------
 ipc/shm.c           | 22 ++++++++++++++++++++++
 2 files changed, 22 insertions(+), 23 deletions(-)

diff --git a/include/linux/shm.h b/include/linux/shm.h
index 2bbafacfbfc9..c7cb18405ad7 100644
--- a/include/linux/shm.h
+++ b/include/linux/shm.h
@@ -3,32 +3,9 @@
 #define _LINUX_SHM_H_
 
 #include <linux/list.h>
-#include <asm/page.h>
 #include <uapi/linux/shm.h>
 #include <asm/shmparam.h>
 
-struct shmid_kernel /* private to the kernel */
-{	
-	struct kern_ipc_perm	shm_perm;
-	struct file		*shm_file;
-	unsigned long		shm_nattch;
-	unsigned long		shm_segsz;
-	time64_t		shm_atim;
-	time64_t		shm_dtim;
-	time64_t		shm_ctim;
-	pid_t			shm_cprid;
-	pid_t			shm_lprid;
-	struct user_struct	*mlock_user;
-
-	/* The task created the shm object.  NULL if the task is dead. */
-	struct task_struct	*shm_creator;
-	struct list_head	shm_clist;	/* list by creator */
-} __randomize_layout;
-
-/* shm_mode upper byte flags */
-#define	SHM_DEST	01000	/* segment will be destroyed on last detach */
-#define SHM_LOCKED      02000   /* segment will not be swapped */
-
 #ifdef CONFIG_SYSVIPC
 struct sysv_shm {
 	struct list_head shm_clist;
diff --git a/ipc/shm.c b/ipc/shm.c
index 387a786e7be1..0565669ebe5c 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -48,6 +48,28 @@
 
 #include "util.h"
 
+struct shmid_kernel /* private to the kernel */
+{
+	struct kern_ipc_perm	shm_perm;
+	struct file		*shm_file;
+	unsigned long		shm_nattch;
+	unsigned long		shm_segsz;
+	time64_t		shm_atim;
+	time64_t		shm_dtim;
+	time64_t		shm_ctim;
+	pid_t			shm_cprid;
+	pid_t			shm_lprid;
+	struct user_struct	*mlock_user;
+
+	/* The task created the shm object.  NULL if the task is dead. */
+	struct task_struct	*shm_creator;
+	struct list_head	shm_clist;	/* list by creator */
+} __randomize_layout;
+
+/* shm_mode upper byte flags */
+#define SHM_DEST	01000	/* segment will be destroyed on last detach */
+#define SHM_LOCKED	02000   /* segment will not be swapped */
+
 struct shm_file_data {
 	int id;
 	struct ipc_namespace *ns;
-- 
2.14.1
