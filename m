From: Pierre Peiffer <Pierre.Peiffer-6ktuUTfB/bM@public.gmane.org>
Subject: [RFC][PATCH 1/2] System V IPC: new kernel API to change an ID
Date: Fri, 28 Sep 2007 16:58:37 +0200
Message-ID: <20070928165837.b267ff1e.Pierre.Peiffer@bull.net>
References: <20070928165459.3b5ca2d8.Pierre.Peiffer@bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20070928165459.3b5ca2d8.Pierre.Peiffer-6ktuUTfB/bM@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org



From: Pierre Peiffer <pierre.peiffer-6ktuUTfB/bM@public.gmane.org>

This patch provides three new API for changing the ID of an existing
System V IPCs.

These APIs are:
	long msg_mvid(struct ipc_namespace *ns, int id, int newid);
	long sem_mvid(struct ipc_namespace *ns, int id, int newid);
	long shm_mvid(struct ipc_namespace *ns, int id, int newid);

They return 0 or an error code in case of failure.

They may be useful for setting a specific ID for an IPC when preparing
a restart operation.

To be successful, the following rules must be respected:
- the IPC exists (of course...)
- the new ID must satisfy the ID computation rule.
- the entry (in the kernel internal table of IPCs) corresponding to the n=
ew
  ID must be free.

Signed-off-by: Pierre Peiffer <pierre.peiffer-6ktuUTfB/bM@public.gmane.org>
---

 include/linux/msg.h |    1 +
 include/linux/sem.h |    1 +
 include/linux/shm.h |    1 +
 ipc/msg.c           |   32 +++++++++++++++++++++++++++
 ipc/sem.c           |   32 +++++++++++++++++++++++++++
 ipc/shm.c           |   30 ++++++++++++++++++++++++++
 ipc/util.c          |   60 +++++++++++++++++++++++++++++++++++++++++++++=
++++++
 ipc/util.h          |    1 +
 8 files changed, 158 insertions(+), 0 deletions(-)

diff --git a/include/linux/msg.h b/include/linux/msg.h
index f1b6074..5a1db95 100644
--- a/include/linux/msg.h
+++ b/include/linux/msg.h
@@ -97,6 +97,7 @@ extern long do_msgsnd(int msqid, long mtype, void __use=
r *mtext,
 			size_t msgsz, int msgflg);
 extern long do_msgrcv(int msqid, long *pmtype, void __user *mtext,
 			size_t msgsz, long msgtyp, int msgflg);
+long msg_mvid(struct ipc_namespace *ns, int id, int newid);
=20
 #endif /* __KERNEL__ */
=20
diff --git a/include/linux/sem.h b/include/linux/sem.h
index 9aaffb0..b5989fb 100644
--- a/include/linux/sem.h
+++ b/include/linux/sem.h
@@ -142,6 +142,7 @@ struct sysv_sem {
=20
 extern int copy_semundo(unsigned long clone_flags, struct task_struct *t=
sk);
 extern void exit_sem(struct task_struct *tsk);
+long sem_mvid(struct ipc_namespace *ns, int id, int newid);
=20
 #else
 static inline int copy_semundo(unsigned long clone_flags, struct task_st=
ruct *tsk)
diff --git a/include/linux/shm.h b/include/linux/shm.h
index ad2e3af..f4ae995 100644
--- a/include/linux/shm.h
+++ b/include/linux/shm.h
@@ -97,6 +97,7 @@ struct shmid_kernel /* private to the kernel */
 #ifdef CONFIG_SYSVIPC
 long do_shmat(int shmid, char __user *shmaddr, int shmflg, unsigned long=
 *addr);
 extern int is_file_shm_hugepages(struct file *file);
+long shm_mvid(struct ipc_namespace *ns, int id, int newid);
 #else
 static inline long do_shmat(int shmid, char __user *shmaddr,
 				int shmflg, unsigned long *addr)
diff --git a/ipc/msg.c b/ipc/msg.c
index a03fcb5..d9d4093 100644
--- a/ipc/msg.c
+++ b/ipc/msg.c
@@ -382,6 +382,38 @@ copy_msqid_from_user(struct msq_setbuf *out, void __=
user *buf, int version)
 	}
 }
=20
+long msg_mvid(struct ipc_namespace *ns, int id, int newid)
+{
+	long err;
+	struct msg_queue *msq;
+
+	mutex_lock(&msg_ids(ns).mutex);
+	msq =3D msg_lock(ns, id);
+
+	err =3D -EINVAL;
+	if (msq =3D=3D NULL)
+			goto out_up;
+
+	err =3D msg_checkid(ns, msq, id);
+	if (err)
+		goto out_unlock_up;
+
+	err =3D ipc_mvid(&msg_ids(ns), id,
+		       newid, ns->msg_ctlmni);
+
+	if (err)
+		goto out_unlock_up;
+
+	msq->q_id =3D newid;
+	msq->q_ctime =3D get_seconds();
+
+out_unlock_up:
+	msg_unlock(msq);
+out_up:
+	mutex_unlock(&msg_ids(ns).mutex);
+	return err;
+}
+
 asmlinkage long sys_msgctl(int msqid, int cmd, struct msqid_ds __user *b=
uf)
 {
 	struct kern_ipc_perm *ipcp;
diff --git a/ipc/sem.c b/ipc/sem.c
index b676fef..606f2e9 100644
--- a/ipc/sem.c
+++ b/ipc/sem.c
@@ -918,6 +918,38 @@ out_unlock:
 	return err;
 }
=20
+long sem_mvid(struct ipc_namespace *ns, int id, int newid)
+{
+	long err;
+	struct sem_array *sma;
+
+	mutex_lock(&sem_ids(ns).mutex);
+	sma =3D sem_lock(ns, id);
+
+	err =3D -EINVAL;
+	if (sma =3D=3D NULL)
+			goto out_up;
+
+	err =3D sem_checkid(ns, sma, id);
+	if (err)
+		goto out_unlock_up;
+
+	err =3D ipc_mvid(&sem_ids(ns), id,
+		       newid, ns->sc_semmni);
+
+	if (err)
+		goto out_unlock_up;
+
+	sma->sem_id =3D newid;
+	sma->sem_ctime =3D get_seconds();
+
+out_unlock_up:
+	sem_unlock(sma);
+out_up:
+	mutex_unlock(&sem_ids(ns).mutex);
+	return err;
+}
+
 asmlinkage long sys_semctl (int semid, int semnum, int cmd, union semun =
arg)
 {
 	int err =3D -EINVAL;
diff --git a/ipc/shm.c b/ipc/shm.c
index a86a3a5..5f4bca6 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -156,7 +156,37 @@ static inline int shm_addid(struct ipc_namespace *ns=
, struct shmid_kernel *shp)
 	return ipc_addid(&shm_ids(ns), &shp->shm_perm, ns->shm_ctlmni);
 }
=20
+long shm_mvid(struct ipc_namespace *ns, int id, int newid)
+{
+	long err;
+	struct shmid_kernel *shp;
+
+	mutex_lock(&shm_ids(ns).mutex);
+	shp =3D shm_lock(ns, id);
+
+	err =3D -EINVAL;
+	if (shp =3D=3D NULL)
+			goto out_up;
+
+	err =3D shm_checkid(ns, shp, id);
+	if (err)
+		goto out_unlock_up;
+
+	err =3D ipc_mvid(&shm_ids(ns), id,
+		       newid, ns->shm_ctlmni);
=20
+	if (err)
+		goto out_unlock_up;
+
+	shp->id =3D newid;
+	shp->shm_ctim =3D get_seconds();
+
+out_unlock_up:
+	shm_unlock(shp);
+out_up:
+	mutex_unlock(&shm_ids(ns).mutex);
+	return err;
+}
=20
 /* This is called by fork, once for every shm attach. */
 static void shm_open(struct vm_area_struct *vma)
diff --git a/ipc/util.c b/ipc/util.c
index 44e5135..4f338d4 100644
--- a/ipc/util.c
+++ b/ipc/util.c
@@ -318,6 +318,66 @@ found:
 }
=20
 /**
+ *	ipc_mvid 	-	move an IPC identifier
+ *	@ids: IPC identifier set
+ *	@oldid: ID of the IPC permission set to move
+ *	@newid: new ID of the IPC permission set to move
+ *	@size: new size limit for the id array
+ *
+ *	Move an entry in the IPC arrays from the 'oldid' place to the
+ *      'newid' place. The seq number of the entry is updated to match t=
he
+ *      'newid' value.
+ *
+ *	Called with the list lock and ipc_ids.mutex held.
+ */
+
+int ipc_mvid(struct ipc_ids *ids, int oldid, int newid, int size)
+{
+	struct kern_ipc_perm *p;
+	int old_lid =3D oldid % SEQ_MULTIPLIER;
+	int new_lid =3D newid % SEQ_MULTIPLIER;
+
+	if ((new_lid >=3D size) ||
+	    newid !=3D  (new_lid + (newid/SEQ_MULTIPLIER)*SEQ_MULTIPLIER))
+		return -ERANGE;
+
+	size =3D grow_ary(ids, size);
+
+	BUG_ON(old_lid >=3D ids->entries->size);
+
+	p =3D ids->entries->p[old_lid];
+
+	if (!p)
+		return -ENXIO;
+
+	/*
+	 * The id (n=B0 of the entry in the table entries) may be the same
+	 * but not the seq number.
+	 */
+	if (new_lid !=3D old_lid) {
+
+		if (ids->entries->p[new_lid])
+			return -EBUSY;
+
+		ids->entries->p[new_lid] =3D p;
+
+		ids->entries->p[old_lid] =3D NULL;
+
+		if (new_lid > ids->max_id)
+			ids->max_id =3D new_lid;
+		if (old_lid =3D=3D ids->max_id) {
+			do {
+				--old_lid;
+			} while (ids->entries->p[old_lid] =3D=3D NULL);
+			ids->max_id =3D old_lid;
+		}
+	}
+
+	p->seq =3D newid/SEQ_MULTIPLIER;
+	return 0;
+}
+
+/**
  *	ipc_rmid	-	remove an IPC identifier
  *	@ids: identifier set
  *	@id: Identifier to remove
diff --git a/ipc/util.h b/ipc/util.h
index 333e891..886af31 100644
--- a/ipc/util.h
+++ b/ipc/util.h
@@ -59,6 +59,7 @@ int ipc_findkey(struct ipc_ids* ids, key_t key);
 int ipc_addid(struct ipc_ids* ids, struct kern_ipc_perm* new, int size);
=20
 /* must be called with both locks acquired. */
+int ipc_mvid(struct ipc_ids *ids, int oldid, int newid, int size);
 struct kern_ipc_perm* ipc_rmid(struct ipc_ids* ids, int id);
=20
 int ipcperms (struct kern_ipc_perm *ipcp, short flg);


--=20
Pierre
