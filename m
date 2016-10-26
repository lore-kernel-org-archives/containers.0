From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: Keyrings, user namespaces and the user_struct
Date: Tue, 25 Oct 2016 23:38:27 -0500
Message-ID: <874m3zwwqk.fsf__16890.4368453243$1477456866$gmane$org@xmission.com>
References: <17576.1477412418@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <17576.1477412418-S6HVgzuS8uM4Awkfq6JHfwNdhmdF6hFW@public.gmane.org> (David Howells's
	message of "Tue, 25 Oct 2016 17:20:18 +0100")
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org, James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, keyrings-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, simo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:

> I have some questions about user namespacing, with regard to making keyrings
> namespaced.  My current idea is to follow the following method:

I am not certain your stated goal is a proper description of what you
are trying to achieve.

>  (1) A new key/keyring records the user_namespace active when it is created.
>
>  (2) If a process's user_namespace doesn't match that recorded in a key then
>      it gets ENOKEY if it tries to refer to it or access it and can't see it
>      in /proc/keys.
>
>  (3) A process's keyring subscriptions are cleared if CLONE_NEWUSER is passed
>      to clone() or to unshare() so that it doesn't retain a keyring it can't
>      access.
>
>  (4) Each user_namespace has its own separate register of persistent keyrings
>      and KEYCTL_GET_PERSISTENT can only get from the register of the currently
>      caller's user_namespace.  This is already upstream
>
> as this seems the simplest solution.  I don't want to add a new CLONE_xxx flag
> as there isn't exactly a whole lot of room left.
>
> Whilst I've got this partially working, there is a problem because the
> user_struct contains pointers to the user's user-keyring and user-session
> keyrings - and these would need replacing when entering a new
> user_namespace.

The session keyring should change when someone changes their
session.  It is a deliberate choice for a session to span namespaces.

Similarly upon entering a user namespace the user does not immediately
change.

So I expect the user mechanism by which the session and user keyrings
are changed should suffice when entering a user namespace.

Also keep in mind that users are fundamentally global.  A given
kuid always maps to the same user_struct.

> However, the active user_struct is *not* replaced by create_user_ns().  Should
> it be?

No.  The user has not changed, so changing the user_struct does not make
sense.

> I'm not sure whether there's a need to use the user_struct inherited from
> before the unsharing - certainly setresuid(), for example, doesn't seem to
> keep the values.  Would it be possible to create a new user_struct with the
> same kuid_t as the old one, but in the context of the new user_struct in case
> it gets mapped?

That would not make much sense.

Are you being asked for different user keys for the same user in
different user namespaces?

Or do you possibly have the impression that users in different user
namespaces are disjoint? (Users in different user namespaces are not
disjoint, they are just the users outside of the user namespace that
they are mapped to).

I have seen a mistaken notion that it is safe to map users in
different containers to the same user outside of the container
and there won't be problems.  Are people with that notion asking
you to fix the code to conform to their mistaken notion of reality?

Now if it does make sense to change the user key to be fundamentally per
user per user namespace we can do that, but we need to be very clear
about what we are trying to accomplish and why.

> I've attached the patch showing my current changes for reference.

Thank you.

The current design if for only the keys owned by users in the current
user namespace to be accessible.  Something that key_task_permission
appears to enforce quite well.

There is a legitimate criticism that the CRIU folks can bring that we
have a global space of key_serial_t/key inode numbers in the kernel.  It
might make sense to move key_serial_tree into struct user_namespace
to fix that.  In general I don't think it matters because the number
is a random number that is essentially unpredicatable.

Elsewhere it has been mentioned there is an implementation bug or
two that needs to be corrected, but that is separate from the bulk
of the implementation that I am not seeing any issues jump out at me
when I look at it.

Eric

p.s.  Apologies for the delay it has taken a bit for my state on
the key subsystem to page back in.

p.p.s. In case I was not clear.  I think your patch below is very much
the wrong approach.

> David
> ---
> diff --git a/include/linux/key.h b/include/linux/key.h
> index 722914798f37..8d785279f7b4 100644
> --- a/include/linux/key.h
> +++ b/include/linux/key.h
> @@ -142,6 +142,7 @@ struct key {
>  		struct rb_node	serial_node;
>  	};
>  	struct rw_semaphore	sem;		/* change vs change sem */
> +	struct user_namespace	*ns;		/* Owning namespace */
>  	struct key_user		*user;		/* owner of this key */
>  	void			*security;	/* security data for this key */
>  	union {
> diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
> index 68f594212759..43f5c47de3a3 100644
> --- a/kernel/user_namespace.c
> +++ b/kernel/user_namespace.c
> @@ -42,6 +42,12 @@ static void set_cred_user_ns(struct cred *cred, struct user_namespace *user_ns)
>  	cred->cap_ambient = CAP_EMPTY_SET;
>  	cred->cap_bset = CAP_FULL_SET;
>  #ifdef CONFIG_KEYS
> +	key_put(cred->session_keyring);
> +	cred->session_keyring = NULL;
> +	key_put(cred->process_keyring);
> +	cred->process_keyring = NULL;
> +	key_put(cred->thread_keyring);
> +	cred->thread_keyring = NULL;
>  	key_put(cred->request_key_auth);
>  	cred->request_key_auth = NULL;
>  #endif
> diff --git a/security/keys/gc.c b/security/keys/gc.c
> index addf060399e0..0f0c589bf49d 100644
> --- a/security/keys/gc.c
> +++ b/security/keys/gc.c
> @@ -12,6 +12,7 @@
>  #include <linux/module.h>
>  #include <linux/slab.h>
>  #include <linux/security.h>
> +#include <linux/user_namespace.h>
>  #include <keys/keyring-type.h>
>  #include "internal.h"
>  
> @@ -155,6 +156,7 @@ static noinline void key_gc_unused_keys(struct list_head *keys)
>  			atomic_dec(&key->user->nikeys);
>  
>  		key_user_put(key->user);
> +		put_user_ns(key->ns);
>  
>  		kfree(key->description);
>  
> diff --git a/security/keys/key.c b/security/keys/key.c
> index 346fbf201c22..09df168907fd 100644
> --- a/security/keys/key.c
> +++ b/security/keys/key.c
> @@ -15,6 +15,7 @@
>  #include <linux/sched.h>
>  #include <linux/slab.h>
>  #include <linux/security.h>
> +#include <linux/user_namespace.h>
>  #include <linux/workqueue.h>
>  #include <linux/random.h>
>  #include <linux/err.h>
> @@ -289,6 +290,7 @@ struct key *key_alloc(struct key_type *type, const char *desc,
>  	init_rwsem(&key->sem);
>  	lockdep_set_class(&key->sem, &type->lock_class);
>  	key->index_key.type = type;
> +	key->ns = get_user_ns(current_user_ns());
>  	key->user = user;
>  	key->quotalen = quotalen;
>  	key->datalen = type->def_datalen;
> diff --git a/security/keys/keyring.c b/security/keys/keyring.c
> index c91e4e0cea08..70a399bd572c 100644
> --- a/security/keys/keyring.c
> +++ b/security/keys/keyring.c
> @@ -1016,6 +1016,9 @@ struct key *find_keyring_by_name(const char *name, bool skip_perm_check)
>  				    &keyring_name_hash[bucket],
>  				    name_link
>  				    ) {
> +			if (keyring->ns != current_user_ns())
> +				continue;
> +
>  			if (!kuid_has_mapping(current_user_ns(), keyring->user->uid))
>  				continue;
>  
> diff --git a/security/keys/permission.c b/security/keys/permission.c
> index 732cc0beffdf..3c1bd572d9da 100644
> --- a/security/keys/permission.c
> +++ b/security/keys/permission.c
> @@ -24,8 +24,9 @@
>   *
>   * The caller must hold either a ref on cred or must hold the RCU readlock.
>   *
> - * Returns 0 if successful, -EACCES if access is denied based on the
> - * permissions bits or the LSM check.
> + * Returns 0 if successful, -ENOKEY if the key is outside of the caller's user
> + * namespace, -EACCES if access is denied based on the permissions bits or the
> + * LSM check.
>   */
>  int key_task_permission(const key_ref_t key_ref, const struct cred *cred,
>  			unsigned perm)
> @@ -36,6 +37,9 @@ int key_task_permission(const key_ref_t key_ref, const struct cred *cred,
>  
>  	key = key_ref_to_ptr(key_ref);
>  
> +	if (key->ns != current_user_ns())
> +		return -ENOKEY;
> +
>  	/* use the second 8-bits of permissions for keys the caller owns */
>  	if (uid_eq(key->uid, cred->fsuid)) {
>  		kperm = key->perm >> 16;
> diff --git a/security/keys/process_keys.c b/security/keys/process_keys.c
> index 40a885239782..52866e90d51a 100644
> --- a/security/keys/process_keys.c
> +++ b/security/keys/process_keys.c
> @@ -691,6 +694,11 @@ try_again:
>  		break;
>  	}
>  
> +	/* We don't see keys that are outside the caller's user namespace */
> +	ret = -ENOKEY;
> +	if (key->ns != current_user_ns())
> +		goto invalid_key;
> +
>  	/* unlink does not use the nominated key in any way, so can skip all
>  	 * the permission checks as it is only concerned with the keyring */
>  	if (lflags & KEY_LOOKUP_FOR_UNLINK) {
