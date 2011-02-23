From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: User namespaces and keys
Date: Wed, 23 Feb 2011 07:45:49 -0800
Message-ID: <m162sasqj6.fsf__18608.8538416245$1298476099$gmane$org@fess.ebiederm.org>
References: <20110223135814.GA1859@mail.hallyn.com>
	<20110217150224.GA26334@mail.hallyn.com> <29677.1298462729@redhat.com>
	<890.1298473574@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <890.1298473574-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> (David Howells's message of "Wed, 23
	Feb 2011 15:06:14 +0000")
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
Cc: xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, kernel list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, LSM <linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Kees Cook <kees.cook-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:

> Serge E. Hallyn <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> wrote:
>
>> > I guess we need to look at how to mix keys and namespaces again.
>> 
>> From strictly kernel pov, at the moment, keys are strictly usable only
>> by the user in your own user namespace.
>
> I'm not sure that's currently completely true.  Key quota maintenance is
> namespaced, and the key's owner UID/GID belong to that namespace, so that's
> okay, but:
>
>  (*) key_task_permission() does not distinguish UIDs and GIDs from different
>      namespaces.
>
>  (*) A key can be referred to by its serial number, no matter whose namespace
>      it is in, and will yield up its given UID/GID, even if these aren't
>      actually meaningful in your namespace.
>
>      This means request_key() can successfully upcall at the moment.
>
> I wonder if I should make the following changes:
>
>  (1) If the key and the accessor are in different user namespaces, then skip
>      the UID and GID comparisons in key_task_permission().  That means that to
>      be able to access the key you'd have to possess the key and the key would
>      have to grant you Possessor access, or the key would have to grant you
>      Other access.
>
>  (2) If the key and someone viewing the key description are in different
>      namespaces, then indicate that the UID and the GID are -1, irrespective of
>      the actual values.
>
>  (3) When an upcall is attempting to instantiate a key, it is allowed to access
>      the keys of requestor using the requestor's credentials (UID, GID, groups,
>      security label).  Ensure that this will be done in the requestor's user
>      namespace.
>
>      Nothing should need to be done here, since search_process_keyrings()
>      switches to the requestor's creds.
>
> Oh, and are security labels user-namespaced?

Not at this time.  The user namespace as currently merged is little more
than a place holder for a proper implementation.  Serge is busily
fleshing out that proper implementation.

Until we reach the point where all checks that have historically been
"if (uid1 == uid2)" become "if ((uidns1 == uidns2) && (uid1 == uid2))"
there will be problems.

The security labels and probably lsm's in general need to be per user
namespace but we simply have not gotten that far.  For the short term I
will be happy when we get a minimally usable user namespace.

Eric
