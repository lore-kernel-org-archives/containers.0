From: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH RFC] User namespaces: general cleanups
Date: Tue, 14 Oct 2008 18:50:18 +0100
Message-ID: <29703.1224006618@redhat.com>
References: <20081013160144.GA10359@us.ibm.com>
	<20081010011917.GA8046@us.ibm.com> <30854.1223633214@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20081013160144.GA10359-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:

> Hmm, with this patch, with CONFIG_KEYS=y users in child user_namespaces
> never get freed.  Ones in the init_user_ns do, and with CONFIG_KEYS=n,
> those in child user_namespaces do as well.
> 
> I don't see anything obvious in copy_creds() that would cause this...

Try looking in lookup_user_key().  Also, can you try the attached patch?

I've also attached a better version of your debugging patch, one that
differentiates between allocated and reused user_structs.

David
---
From: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

CRED: Fix creds refcounting in lookup_user_key()

Make lookup_user_key() drop at all return points the reference to the current
creds that it took at the top of the function

Signed-off-by: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---

 security/keys/process_keys.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)


diff --git a/security/keys/process_keys.c b/security/keys/process_keys.c
index e40f61d..2d6076d 100644
--- a/security/keys/process_keys.c
+++ b/security/keys/process_keys.c
@@ -667,6 +667,7 @@ try_again:
 		goto invalid_key;
 
 error:
+	put_cred(cred);
 	return key_ref;
 
 invalid_key:

---
From e00a2d98dd1086b0c863d8b416df33280c7c2574 Mon Sep 17 00:00:00 2001
From: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date: Mon, 13 Oct 2008 16:36:05 -0500
Subject: [PATCH 1/1] creds: print user_struct refcounts

print user_struct refcounts at alloc, and print msg at uid free.

Signed-off-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Signed-off-by: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---

 kernel/user.c |   12 +++++++++++-
 1 files changed, 11 insertions(+), 1 deletions(-)


diff --git a/kernel/user.c b/kernel/user.c
index d476307..073296e 100644
--- a/kernel/user.c
+++ b/kernel/user.c
@@ -317,6 +317,7 @@ done:
 static inline void free_user(struct user_struct *up, unsigned long flags)
 {
 	/* restore back the count */
+	printk(KERN_NOTICE "%s: freeing a uid (%d)\n", __func__, up->uid);
 	atomic_inc(&up->__count);
 	spin_unlock_irqrestore(&uidhash_lock, flags);
 
@@ -337,6 +338,7 @@ static inline void uids_mutex_unlock(void) { }
  */
 static inline void free_user(struct user_struct *up, unsigned long flags)
 {
+	printk(KERN_NOTICE "%s: freeing a uid (%d)\n", __func__, up->uid);
 	uid_hash_remove(up);
 	spin_unlock_irqrestore(&uidhash_lock, flags);
 	sched_destroy_user(up);
@@ -422,16 +424,24 @@ struct user_struct *alloc_uid(struct user_namespace *ns, uid_t uid)
 			key_put(new->uid_keyring);
 			key_put(new->session_keyring);
 			kmem_cache_free(uid_cachep, new);
+			printk(KERN_NOTICE "%s: reuse a uid (%d) (cnt %u)\n",
+			       __func__, uid, atomic_read(&up->__count));
+
 		} else {
 			uid_hash_insert(new, hashent);
 			up = new;
+			printk(KERN_NOTICE "%s: alloced a uid (%d) (cnt %u)\n",
+			       __func__, uid, atomic_read(&up->__count));
+
 		}
 		spin_unlock_irq(&uidhash_lock);
 
+	} else {
+		printk(KERN_NOTICE "%s: reuse a uid (%d) (cnt %u)\n",
+		       __func__, uid, atomic_read(&up->__count));
 	}
 
 	uids_mutex_unlock();
-
 	return up;
 
 out_destoy_sched:
