From: Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>
Subject: Re: Keyrings, user namespaces and the user_struct
Date: Tue, 25 Oct 2016 18:41:56 +0200
Message-ID: <20161025164156.GA24481__42268.6059996069$1477413752$gmane$org@laptop.thejh.net>
References: <17576.1477412418@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <17576.1477412418-S6HVgzuS8uM4Awkfq6JHfwNdhmdF6hFW@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org, James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, keyrings-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, simo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Oct 25, 2016 at 05:20:18PM +0100, David Howells wrote:
> I have some questions about user namespacing, with regard to making keyrings
> namespaced.  My current idea is to follow the following method:
> 
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

I think this sounds sensible.


> Whilst I've got this partially working, there is a problem because the
> user_struct contains pointers to the user's user-keyring and user-session
> keyrings - and these would need replacing when entering a new user_namespace.
> 
> However, the active user_struct is *not* replaced by create_user_ns().  Should
> it be?
> 
> I'm not sure whether there's a need to use the user_struct inherited from
> before the unsharing - certainly setresuid(), for example, doesn't seem to
> keep the values.  Would it be possible to create a new user_struct with the
> same kuid_t as the old one, but in the context of the new user_struct in case
> it gets mapped?

Most things in user_struct should not be per-namespace, at least not without the
consent of root in the init namespace or so. Otherwise, someone could e.g. create
a bunch of new namespaces and lock the maximum permitted amount of memory in each
one, effectively allowing an arbitrary amount of memory to be pinned.

However, I think that there are people who would benefit from being able to have
the user_struct be per-namespace because they actually want separate limits for
multiple containers, but have too many containers to be able to allocate separate
kuid ranges for all of them. (I think James Bottomley said that in his Security
Summit talk?) Therefore, I think it might make sense to have separate user_structs
for user namespaces, but let them have a "struct user_struct *parent_pointer" to
the user_struct belonging to the same kuid in the parent namespace and a
resource_tracking_parent pointer that normally points to the user with the same
kuid in the init namespace.
Then, you could use the keyring stuff in the user_struct belonging to the current
namespace, all the existing users of user_struct could follow the ->parent_pointer
for now, and if someone wants to have per-ns resource tracking, they can add it in
later relatively easily.

But maybe I'm just overthinking this?
