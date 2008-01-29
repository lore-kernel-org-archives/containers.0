From: pierre.peiffer-6ktuUTfB/bM@public.gmane.org
Subject: [PATCH 2.6.24-rc8-mm1 04/15] IPC/semaphores: move the rwmutex
	handling inside semctl_down
Date: Tue, 29 Jan 2008 17:02:33 +0100
Message-ID: <20080129161727.317911992__19774.0351352424$1201623717$gmane$org@bull.net>
References: <20080129160229.612172683@bull.net>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline;
	filename=ipc_move_rwmutex_handling_inside_semctl_down.patch
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

semctl_down is called with the rwmutex (the one which protects the
list of ipcs) taken in write mode.
This patch moves this rwmutex taken in write-mode inside semctl_down.
This has the advantages of reducing a little bit the window during
which this rwmutex is taken, clarifying sys_semctl, and finally of
having a coherent behaviour with [shm|msg]ctl_down

Signed-off-by: Pierre Peiffer <pierre.peiffer-6ktuUTfB/bM@public.gmane.org>
Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---

 ipc/sem.c |   24 +++++++++++++-----------
 1 file changed, 13 insertions(+), 11 deletions(-)

Index: b/ipc/sem.c
===================================================================
--- a/ipc/sem.c
+++ b/ipc/sem.c
@@ -877,6 +877,11 @@ static inline unsigned long copy_semid_f
 	}
 }
 
+/*
+ * This function handles some semctl commands which require the rw_mutex
+ * to be held in write mode.
+ * NOTE: no locks must be held, the rw_mutex is taken inside this function.
+ */
 static int semctl_down(struct ipc_namespace *ns, int semid, int semnum,
 		int cmd, int version, union semun arg)
 {
@@ -889,9 +894,12 @@ static int semctl_down(struct ipc_namesp
 		if(copy_semid_from_user (&setbuf, arg.buf, version))
 			return -EFAULT;
 	}
+	down_write(&sem_ids(ns).rw_mutex);
 	sma = sem_lock_check_down(ns, semid);
-	if (IS_ERR(sma))
-		return PTR_ERR(sma);
+	if (IS_ERR(sma)) {
+		err = PTR_ERR(sma);
+		goto out_up;
+	}
 
 	ipcp = &sma->sem_perm;
 
@@ -917,26 +925,22 @@ static int semctl_down(struct ipc_namesp
 	switch(cmd){
 	case IPC_RMID:
 		freeary(ns, ipcp);
-		err = 0;
-		break;
+		goto out_up;
 	case IPC_SET:
 		ipcp->uid = setbuf.uid;
 		ipcp->gid = setbuf.gid;
 		ipcp->mode = (ipcp->mode & ~S_IRWXUGO)
 				| (setbuf.mode & S_IRWXUGO);
 		sma->sem_ctime = get_seconds();
-		sem_unlock(sma);
-		err = 0;
 		break;
 	default:
-		sem_unlock(sma);
 		err = -EINVAL;
-		break;
 	}
-	return err;
 
 out_unlock:
 	sem_unlock(sma);
+out_up:
+	up_write(&sem_ids(ns).rw_mutex);
 	return err;
 }
 
@@ -970,9 +974,7 @@ asmlinkage long sys_semctl (int semid, i
 		return err;
 	case IPC_RMID:
 	case IPC_SET:
-		down_write(&sem_ids(ns).rw_mutex);
 		err = semctl_down(ns,semid,semnum,cmd,version,arg);
-		up_write(&sem_ids(ns).rw_mutex);
 		return err;
 	default:
 		return -EINVAL;

-- 
Pierre Peiffer
