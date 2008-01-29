From: pierre.peiffer-6ktuUTfB/bM@public.gmane.org
Subject: [PATCH 2.6.24-rc8-mm1 05/15] IPC/semaphores: remove one unused
	parameter from semctl_down()
Date: Tue, 29 Jan 2008 17:02:34 +0100
Message-ID: <20080129161758.154775218__16322.2233568833$1201623729$gmane$org@bull.net>
References: <20080129160229.612172683@bull.net>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline;
	filename=ipc_semctl_down_remove_unused_parameter.patch
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

From: Pierre Peiffer <pierre.peiffer-6ktuUTfB/bM@public.gmane.org>

semctl_down() takes one unused parameter: semnum.
This patch proposes to get rid of it.

Signed-off-by: Pierre Peiffer <pierre.peiffer-6ktuUTfB/bM@public.gmane.org>
Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 ipc/sem.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

Index: b/ipc/sem.c
===================================================================
--- a/ipc/sem.c
+++ b/ipc/sem.c
@@ -882,8 +882,8 @@ static inline unsigned long copy_semid_f
  * to be held in write mode.
  * NOTE: no locks must be held, the rw_mutex is taken inside this function.
  */
-static int semctl_down(struct ipc_namespace *ns, int semid, int semnum,
-		int cmd, int version, union semun arg)
+static int semctl_down(struct ipc_namespace *ns, int semid,
+		       int cmd, int version, union semun arg)
 {
 	struct sem_array *sma;
 	int err;
@@ -974,7 +974,7 @@ asmlinkage long sys_semctl (int semid, i
 		return err;
 	case IPC_RMID:
 	case IPC_SET:
-		err = semctl_down(ns,semid,semnum,cmd,version,arg);
+		err = semctl_down(ns, semid, cmd, version, arg);
 		return err;
 	default:
 		return -EINVAL;

-- 
Pierre Peiffer
