From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/1] cr: safely restore a task's securebits
Date: Wed, 27 May 2009 11:31:12 -0500
Message-ID: <20090527163112.GA31716@us.ibm.com>
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
To: orenl-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

As I started doing c/r of LSM credentials, I realized I wasn't
handling securebit yet with the current patchet.  This is on
top of the set I sent out yesterday, and if I'm sendng out another
full patchset then I'll integrate this back into the previous
patches.

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 include/linux/capability.h     |    2 +
 include/linux/checkpoint_hdr.h |    1 +
 kernel/cred.c                  |    4 +++
 security/commoncap.c           |   52 +++++++++++++++++++++++++++-------------
 4 files changed, 42 insertions(+), 17 deletions(-)

diff --git a/include/linux/capability.h b/include/linux/capability.h
index 572b5a0..b3853ca 100644
--- a/include/linux/capability.h
+++ b/include/linux/capability.h
@@ -540,6 +540,8 @@ extern void checkpoint_save_cap(__u64 *dest, kernel_cap_t src);
 struct cred;
 extern int checkpoint_restore_cap(__u64 e, __u64 i, __u64 p, __u64 x,
 				struct cred *cred);
+extern void checkpoint_save_securebits(unsigned *, unsigned);
+extern int checkpoint_restore_securebits(unsigned, struct cred *);
 
 /**
  * has_capability - Determine if a task has a superior capability available
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 0bad447..7f65964 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -192,6 +192,7 @@ struct ckpt_hdr_cred {
 	__u32 version; /* especially since capability sets might grow */
 	__u32 uid, suid, euid, fsuid;
 	__u32 gid, sgid, egid, fsgid;
+	__u32 securebits;
 	__u64 cap_i, cap_p, cap_e;
 	__u64 cap_x;  /* bounding set ('X') */
 	__s32 user_ref;
diff --git a/kernel/cred.c b/kernel/cred.c
index c05192e..fe2941d 100644
--- a/kernel/cred.c
+++ b/kernel/cred.c
@@ -739,6 +739,7 @@ int checkpoint_write_cred(struct ckpt_ctx *ctx, const struct cred *cred)
 	checkpoint_save_cap(&h->cap_p, cred->cap_permitted);
 	checkpoint_save_cap(&h->cap_e, cred->cap_effective);
 	checkpoint_save_cap(&h->cap_x, cred->cap_bset);
+	checkpoint_save_securebits(&h->securebits, cred->securebits);
 
 	h->user_ref = user_ref;
 	h->groupinfo_ref = groupinfo_ref;
@@ -811,6 +812,9 @@ struct cred *restore_read_cred(struct ckpt_ctx *ctx)
 				cred);
 	if (ret)
 		goto err_putcred;
+	ret = checkpoint_restore_securebits(h->securebits, cred);
+	if (ret)
+		goto err_putcred;
 
 	ckpt_hdr_put(ctx, h);
 	return cred;
diff --git a/security/commoncap.c b/security/commoncap.c
index beac025..31ecd3d 100644
--- a/security/commoncap.c
+++ b/security/commoncap.c
@@ -804,6 +804,29 @@ int cap_task_setnice (struct task_struct *p, int nice)
 }
 #endif
 
+int cap_set_securebits(struct cred *new, unsigned securebits)
+{
+	if ((((new->securebits & SECURE_ALL_LOCKS) >> 1)
+	     & (new->securebits ^ securebits))				/*[1]*/
+	    || ((new->securebits & SECURE_ALL_LOCKS & ~securebits))	/*[2]*/
+	    || (securebits & ~(SECURE_ALL_LOCKS | SECURE_ALL_BITS))	/*[3]*/
+	    || (cap_capable(current, current_cred(), CAP_SETPCAP,
+			    SECURITY_CAP_AUDIT) != 0)			/*[4]*/
+		/*
+		 * [1] no changing of bits that are locked
+		 * [2] no unlocking of locks
+		 * [3] no setting of unsupported bits
+		 * [4] doing anything requires privilege (go read about
+		 *     the "sendmail capabilities bug")
+		 */
+	    )
+		/* cannot change a locked bit */
+		return -EPERM;
+	new->securebits = securebits;
+	return 0;
+}
+
+
 /**
  * cap_task_prctl - Implement process control functions for this security module
  * @option: The process control function requested
@@ -861,24 +884,9 @@ int cap_task_prctl(int option, unsigned long arg2, unsigned long arg3,
 	 * capability-based-privilege environment.
 	 */
 	case PR_SET_SECUREBITS:
-		error = -EPERM;
-		if ((((new->securebits & SECURE_ALL_LOCKS) >> 1)
-		     & (new->securebits ^ arg2))			/*[1]*/
-		    || ((new->securebits & SECURE_ALL_LOCKS & ~arg2))	/*[2]*/
-		    || (arg2 & ~(SECURE_ALL_LOCKS | SECURE_ALL_BITS))	/*[3]*/
-		    || (cap_capable(current, current_cred(), CAP_SETPCAP,
-				    SECURITY_CAP_AUDIT) != 0)		/*[4]*/
-			/*
-			 * [1] no changing of bits that are locked
-			 * [2] no unlocking of locks
-			 * [3] no setting of unsupported bits
-			 * [4] doing anything requires privilege (go read about
-			 *     the "sendmail capabilities bug")
-			 */
-		    )
-			/* cannot change a locked bit */
+		error = cap_set_securebits(new, arg2);
+		if (error)
 			goto error;
-		new->securebits = arg2;
 		goto changed;
 
 	case PR_GET_SECUREBITS:
@@ -921,6 +929,16 @@ error:
 	return error;
 }
 
+void checkpoint_save_securebits(unsigned *b, unsigned cred_securebits)
+{
+	*b = cred_securebits;
+}
+
+int checkpoint_restore_securebits(unsigned b, struct cred *cred)
+{
+	return cap_set_securebits(cred, b);
+}
+
 /**
  * cap_syslog - Determine whether syslog function is permitted
  * @type: Function requested
-- 
1.6.1
