From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: Keyrings, user namespaces and the user_struct
Date: Thu, 27 Oct 2016 11:18:13 -0500
Message-ID: <87twbxojei.fsf__11097.48167587$1477585296$gmane$org@xmission.com>
References: <87mvhrrng3.fsf@xmission.com> <20161026143856.GL3334@pc.thejh.net>
	<CALCETrU0PqNYmWx70pugkhj-kAD5DSzSi3swhK+v12WMYZYUZA@mail.gmail.com>
	<17576.1477412418@warthog.procyon.org.uk>
	<18335.1477414412@warthog.procyon.org.uk>
	<1477414605.3079.40.camel@HansenPartnership.com>
	<20161025170602.GB24481@laptop.thejh.net>
	<1477418708.3079.52.camel@HansenPartnership.com>
	<20161025181735.GC24481@laptop.thejh.net>
	<9243.1477492490@warthog.procyon.org.uk>
	<9610.1477493338@warthog.procyon.org.uk>
	<3677.1477506925@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <3677.1477506925-S6HVgzuS8uM4Awkfq6JHfwNdhmdF6hFW@public.gmane.org> (David Howells's message
	of "Wed, 26 Oct 2016 19:35:25 +0100")
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

> Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
>
>> > Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org> wrote:
>> >
>> >> find_keyring_by_name() checks that the UID of the keyring's owner is
>> >> mapped into the current user namespace. But that doesn't catch the
>> >> scenario I described: The keyring is created in an attacker-created
>> >> namespace and looked up from the init namespace, into which all kuids are
>> >> mapped.
>> >
>> > Ah - gotcha.
>> 
>> Unless I am misreading something it actually gets worse.  You don't even
>> need a user namespace.  You can just call keyctl_join_session_keyring
>> and the named keyring of your choice will be created.
>
> It's meant to do that - assuming a keyring of that name doesn't yet exist or
> isn't accessible by you.
>
> I should perhaps prohibit the creation of a _uid.N keyring.  However, I think
> that conceptually, it should be possible to join the user-session keyring as
> your session - or I should make it so that the user-session keyring doesn't
> exist (but I'm pretty certain that will break userspace).

>> Plus there are various really weird things in their where the keyring
>> names of _tid, _pid, _ses, get reused over and over again.
>
> True, however per-thread (_tid) and per-process(_pid) keyrings are always
> allocated by key_alloc() and never looked up by name when being created.
>
> Anonymous session (_ses) keyrings are also created by key_alloc() and not
> looked up when created.  It's only when a named session keyring is requested
> that a look up by name is done.
>
> I could make the per-thread, per-process and anon-session keyrings nameless by
> default, or prefix them with '.' and not permit joining of a keyring whose
> name begins with a '.' (you aren't allowed to use add_key() to create a such
> keyrings, so that really ought to be extended to here too).
>
>> So it looks like there are some significant things to fix.
>
> So:
>
>  (1) Make the keyring name list per user_namespace.
>
>  (2) Don't let _uid.N, _tid, _pid and _ses (anonymous session) keyrings be
>      joined.
>
>  (3) Don't let keyrings whose name begins '.' be joined.
>
>  (4) Don't keep the user and user-session keyrings in the user_struct, but
>      rather make them subordinates of the user namespace.
>
> for starters.

I would start with 2 and 3.

Then as a band-aid I would tweak join keyctl_join_session_keyring
to do something like:

	if (memcmp(name, "_uid_ses.", 9) == 0) {
        	unsigned long uid;
                kuid_t kuid;
                uid = strtoul(name, name, 10);
                kuid = make_kuid(current_user_ns(), uid);
                if (!valid_uid(kuid))
                	return -EINVAL;
                uid = from_kuid(&init_user_ns, kuid);
                snprintf(name + 9, sizeof(*name), "%u", uid);
        }
}

That allows the uid and uid_session keyring silliness to be fixed with just:

diff --git a/security/keys/process_keys.c b/security/keys/process_keys.c
index 40a885239782..37f787716575 100644
--- a/security/keys/process_keys.c
+++ b/security/keys/process_keys.c
@@ -53,7 +53,7 @@ int install_user_keyrings(void)
        user_keyring_perm = (KEY_POS_ALL & ~KEY_POS_SETATTR) | KEY_USR_ALL;
        cred = current_cred();
        user = cred->user;
-       uid = from_kuid(cred->user_ns, user->uid);
+       uid = from_kuid(&init_user_ns, user->uid);
 
        kenter("%p{%u}", user, uid);

I am quite certain that I only coded it with the name using
cred->user_ns and not &init_user_ns is so that in a user namespace
the lookup up from keyctl_join_sesson_keyring would continue to work.
And changing the name we are looking up works just as well.


Then we can discuss changing the semantics to the uid and uid session
keyrings that live in the uid_struct.  I don't think I have yet seen a
clear justification for the change in semantics.  I have just seen it
stated that it is desired to change the semantics that way.  I think the
change in semantics needs to be it's own conversation.


With the added bonus that all of the fixes I have outlined are simple
enough they should not be problematic to backport as fixes.

Eric
