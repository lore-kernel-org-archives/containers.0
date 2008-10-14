From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH RFC] User namespaces: general cleanups
Date: Tue, 14 Oct 2008 09:33:51 -0500
Message-ID: <20081014143351.GA9611@us.ibm.com>
References: <20081013214108.GA4701@us.ibm.com>
	<20081010011917.GA8046@us.ibm.com> <30854.1223633214@redhat.com>
	<20081013160144.GA10359@us.ibm.com> <5306.1223939456@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <5306.1223939456-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting David Howells (dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org):
> Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:
> 
> > With the following patch applied to the base next-creds-subsys branch,
> > you can track that if you login as root, then do 'su hallyn', where
> > hallyn is uid 500, then uid 500 gets allocated twice.  So free is never
> > called on it.
> 
> Which following patch?

Argh.  The one below :)

> Actually, I've suspected that the user_struct accounting is not quite right for
> a while.  Even before I did my creds stuff, I'd occasionally multiple per-UID
> keyrings cropping up with the same ID - indicating multiple user_structs for
> the same UID.
> 
> David

From e00a2d98dd1086b0c863d8b416df33280c7c2574 Mon Sep 17 00:00:00 2001
From: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date: Mon, 13 Oct 2008 16:36:05 -0500
Subject: [PATCH 1/1] creds: print user_struct refcounts

print user_struct refcounts at alloc, and print msg at uid free.

Signed-off-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 kernel/user.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/kernel/user.c b/kernel/user.c
index ed4dc57..3b9fd14 100644
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
@@ -431,6 +433,8 @@ struct user_struct *alloc_uid(struct user_namespace *ns, uid_t uid)
 	}
 
 	uids_mutex_unlock();
+	printk(KERN_NOTICE "%s: alloced a uid (%d) (cnt %lu)\n", __func__,
+			uid, atomic_read(&up->__count));
 
 	return up;
 
-- 
1.5.4.3
