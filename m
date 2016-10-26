From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: Keyrings, user namespaces and the user_struct
Date: Wed, 26 Oct 2016 00:54:26 -0500
Message-ID: <87shrju031.fsf@xmission.com>
References: <CALCETrU0PqNYmWx70pugkhj-kAD5DSzSi3swhK+v12WMYZYUZA@mail.gmail.com>
	<17576.1477412418@warthog.procyon.org.uk>
	<18335.1477414412@warthog.procyon.org.uk>
	<1477414605.3079.40.camel@HansenPartnership.com>
	<20161025170602.GB24481@laptop.thejh.net>
	<1477418708.3079.52.camel@HansenPartnership.com>
	<20161025181735.GC24481@laptop.thejh.net>
	<20947.1477428095@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20947.1477428095-S6HVgzuS8uM4Awkfq6JHfwNdhmdF6hFW@public.gmane.org> (David Howells's
	message of "Tue, 25 Oct 2016 21:41:35 +0100")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Eric Paris <eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, James Bottomley <James.Bottomley-JuX6DAaQMKPCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>, LSM List <linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, keyrings-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, simo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:

> Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org> wrote:
>
>> ... Perhaps we could simply *remove* the concept of named keys and keyrings.
>
> See Linus's dictum about breaking userspace.
>
> The problem isn't named keys: keys have to be named - the description is how
> they're looked up typically.  Further, non-keyring keys can't be looked up
> directly by name - you have to search for them in a keyring.
>
> The issue here is named keyrings and keyctl_join_session_keyring().  It might
> well have been a bad idea - though I've seen some people arguing for a single
> session keyring shared across all a user's logins, in which case, we might
> want this after all (or use the user-default session).
>
> One thing we perhaps do want to do, though, is restrict the names of keyrings
> to the user_namespace in which the keyring was created.

Grr...

The first round of user namespace support had actually restricted the
description lookup to a single user namespace.  Then I missed a detail
and converted the code to it's current form.  Ooops!

I think the answer for all of the issues raised in this conversation is
to just make the keyring names and the keyring name lookup per user
namespace.

Maybe a few small additional tweaks to install_user_keyrings to notice
if we have the user keyring from the wrong user namespace.

Something like the untested patch below.

Eric

diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.h
index eb209d4523f5..5ea474df16bd 100644
--- a/include/linux/user_namespace.h
+++ b/include/linux/user_namespace.h
@@ -52,6 +52,12 @@ struct user_namespace {
 	struct key		*persistent_keyring_register;
 	struct rw_semaphore	persistent_keyring_register_sem;
 #endif
+#ifdef CONFIG_KEYS
+# ifndef KEYRING_NAME_HASH_SIZE
+# define KEYRING_NAME_HASH_SIZE	(1 << 5)
+# endif
+	struct list_head keyring_name_hash[KEYRING_NAME_HASH_SIZE];
+#endif
 	struct work_struct	work;
 #ifdef CONFIG_SYSCTL
 	struct ctl_table_set	set;
diff --git a/security/keys/internal.h b/security/keys/internal.h
index a705a7d92ad7..e83e9e6129fc 100644
--- a/security/keys/internal.h
+++ b/security/keys/internal.h
@@ -18,6 +18,7 @@
 #include <linux/keyctl.h>
 
 struct iovec;
+struct user_namespace;
 
 #ifdef __KDEBUG
 #define kenter(FMT, ...) \
@@ -137,7 +138,7 @@ extern key_ref_t keyring_search_aux(key_ref_t keyring_ref,
 extern key_ref_t search_my_process_keyrings(struct keyring_search_context *ctx);
 extern key_ref_t search_process_keyrings(struct keyring_search_context *ctx);
 
-extern struct key *find_keyring_by_name(const char *name, bool skip_perm_check);
+extern struct key *find_keyring_by_name(struct user_namespace *ns, const char *name, bool skip_perm_check);
 
 extern int install_user_keyrings(void);
 extern int install_thread_keyring_to_cred(struct cred *);
diff --git a/security/keys/keyring.c b/security/keys/keyring.c
index c91e4e0cea08..be1bb5ca1c3a 100644
--- a/security/keys/keyring.c
+++ b/security/keys/keyring.c
@@ -20,6 +20,7 @@
 #include <keys/user-type.h>
 #include <linux/assoc_array_priv.h>
 #include <linux/uaccess.h>
+#include <linux/user_namespace.h>
 #include "internal.h"
 
 /*
@@ -55,7 +56,6 @@ static inline void *keyring_key_to_ptr(struct key *key)
 	return key;
 }
 
-static struct list_head	keyring_name_hash[KEYRING_NAME_HASH_SIZE];
 static DEFINE_RWLOCK(keyring_name_lock);
 
 static inline unsigned keyring_hash(const char *desc)
@@ -106,7 +106,7 @@ static DECLARE_RWSEM(keyring_serialise_link_sem);
  * Publish the name of a keyring so that it can be found by name (if it has
  * one).
  */
-static void keyring_publish_name(struct key *keyring)
+static void keyring_publish_name(struct user_namespace *ns, struct key *keyring)
 {
 	int bucket;
 
@@ -115,11 +115,11 @@ static void keyring_publish_name(struct key *keyring)
 
 		write_lock(&keyring_name_lock);
 
-		if (!keyring_name_hash[bucket].next)
-			INIT_LIST_HEAD(&keyring_name_hash[bucket]);
+		if (!ns->keyring_name_hash[bucket].next)
+			INIT_LIST_HEAD(&ns->keyring_name_hash[bucket]);
 
 		list_add_tail(&keyring->name_link,
-			      &keyring_name_hash[bucket]);
+			      &ns->keyring_name_hash[bucket]);
 
 		write_unlock(&keyring_name_lock);
 	}
@@ -148,9 +148,11 @@ static void keyring_free_preparse(struct key_preparsed_payload *prep)
 static int keyring_instantiate(struct key *keyring,
 			       struct key_preparsed_payload *prep)
 {
+	struct user_namespace *ns = (void *)prep->data;
+
 	assoc_array_init(&keyring->keys);
 	/* make the keyring available by name if it has one */
-	keyring_publish_name(keyring);
+	keyring_publish_name(ns, keyring);
 	return 0;
 }
 
@@ -497,13 +499,14 @@ struct key *keyring_alloc(const char *description, kuid_t uid, kgid_t gid,
 					       const union key_payload *),
 			  struct key *dest)
 {
+	void *data = cred->user_ns;
 	struct key *keyring;
 	int ret;
 
 	keyring = key_alloc(&key_type_keyring, description,
 			    uid, gid, cred, perm, flags, restrict_link);
 	if (!IS_ERR(keyring)) {
-		ret = key_instantiate_and_link(keyring, NULL, 0, dest, NULL);
+		ret = key_instantiate_and_link(keyring, data, 0, dest, NULL);
 		if (ret < 0) {
 			key_put(keyring);
 			keyring = ERR_PTR(ret);
@@ -997,7 +1000,8 @@ key_ref_t find_key_to_update(key_ref_t keyring_ref,
  * Returns a pointer to the keyring with the keyring's refcount having being
  * incremented on success.  -ENOKEY is returned if a key could not be found.
  */
-struct key *find_keyring_by_name(const char *name, bool skip_perm_check)
+struct key *find_keyring_by_name(struct user_namespace *ns,
+				 const char *name, bool skip_perm_check)
 {
 	struct key *keyring;
 	int bucket;
@@ -1009,16 +1013,13 @@ struct key *find_keyring_by_name(const char *name, bool skip_perm_check)
 
 	read_lock(&keyring_name_lock);
 
-	if (keyring_name_hash[bucket].next) {
+	if (ns->keyring_name_hash[bucket].next) {
 		/* search this hash bucket for a keyring with a matching name
 		 * that's readable and that hasn't been revoked */
 		list_for_each_entry(keyring,
-				    &keyring_name_hash[bucket],
+				    &ns->keyring_name_hash[bucket],
 				    name_link
 				    ) {
-			if (!kuid_has_mapping(current_user_ns(), keyring->user->uid))
-				continue;
-
 			if (test_bit(KEY_FLAG_REVOKED, &keyring->flags))
 				continue;
 
diff --git a/security/keys/process_keys.c b/security/keys/process_keys.c
index 40a885239782..5f527dcb4e79 100644
--- a/security/keys/process_keys.c
+++ b/security/keys/process_keys.c
@@ -72,7 +72,7 @@ int install_user_keyrings(void)
 		 *   may have been destroyed by setuid */
 		sprintf(buf, "_uid.%u", uid);
 
-		uid_keyring = find_keyring_by_name(buf, true);
+		uid_keyring = find_keyring_by_name(cred->user_ns, buf, true);
 		if (IS_ERR(uid_keyring)) {
 			uid_keyring = keyring_alloc(buf, user->uid, INVALID_GID,
 						    cred, user_keyring_perm,
@@ -88,7 +88,7 @@ int install_user_keyrings(void)
 		 * already) */
 		sprintf(buf, "_uid_ses.%u", uid);
 
-		session_keyring = find_keyring_by_name(buf, true);
+		session_keyring = find_keyring_by_name(cred->user_ns, buf, true);
 		if (IS_ERR(session_keyring)) {
 			session_keyring =
 				keyring_alloc(buf, user->uid, INVALID_GID,
@@ -783,7 +783,7 @@ long join_session_keyring(const char *name)
 	mutex_lock(&key_session_mutex);
 
 	/* look for an existing keyring of this name */
-	keyring = find_keyring_by_name(name, false);
+	keyring = find_keyring_by_name(old->user_ns, name, false);
 	if (PTR_ERR(keyring) == -ENOKEY) {
 		/* not found - try and create a new one */
 		keyring = keyring_alloc(
