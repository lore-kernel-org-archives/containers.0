From: David Howells <dhowells@redhat.com>
Subject: [PATCH] User namespaces: Only put the userns when we unhash the uid
Date: Fri, 13 Feb 2009 14:04:21 +0000
Message-ID: <20090213140421.5698.86876.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759147AbZBMOF2@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: torvalds@osdl.org, jmorris@namei.sys
Cc: akpm@linux-foundation.org, dhowells@redhat.com, serue@us.ibm.com, mingo@elte.hu, kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, vegard.nossum@gmail.com, containers@lists.osdl.org, snakebyte@gmx.de
List-Id: containers.vger.kernel.org

From: Serge E. Hallyn <serue@us.ibm.com>

uids in namespaces other than init don't get a sysfs entry.

For those in the init namespace, while we're waiting to remove
the sysfs entry for the uid the uid is still hashed, and
alloc_uid() may re-grab that uid without getting a new
reference to the user_ns, which we've already put in free_user
before scheduling remove_user_sysfs_dir().

Reported-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: Serge E. Hallyn <serue@us.ibm.com>
Acked-by: David Howells <dhowells@redhat.com>
Tested-by: Ingo Molnar <mingo@elte.hu>
---

 kernel/user.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)


diff --git a/kernel/user.c b/kernel/user.c
index 477b666..3551ac7 100644
--- a/kernel/user.c
+++ b/kernel/user.c
@@ -72,6 +72,7 @@ static void uid_hash_insert(struct user_struct *up, struct hlist_head *hashent)
 static void uid_hash_remove(struct user_struct *up)
 {
 	hlist_del_init(&up->uidhash_node);
+	put_user_ns(up->user_ns);
 }
 
 static struct user_struct *uid_hash_find(uid_t uid, struct hlist_head *hashent)
@@ -334,7 +335,6 @@ static void free_user(struct user_struct *up, unsigned long flags)
 	atomic_inc(&up->__count);
 	spin_unlock_irqrestore(&uidhash_lock, flags);
 
-	put_user_ns(up->user_ns);
 	INIT_WORK(&up->work, remove_user_sysfs_dir);
 	schedule_work(&up->work);
 }
@@ -357,7 +357,6 @@ static void free_user(struct user_struct *up, unsigned long flags)
 	sched_destroy_user(up);
 	key_put(up->uid_keyring);
 	key_put(up->session_keyring);
-	put_user_ns(up->user_ns);
 	kmem_cache_free(uid_cachep, up);
 }
 
