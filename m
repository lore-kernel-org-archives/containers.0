From: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: User namespaces and keys
Date: Wed, 23 Feb 2011 15:06:14 +0000
Message-ID: <890.1298473574__6922.40413413874$1298473627$gmane$org@redhat.com>
References: <20110223135814.GA1859@mail.hallyn.com>
	<20110217150224.GA26334@mail.hallyn.com>
	<29677.1298462729@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110223135814.GA1859-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Cc: xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, kernel list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, LSM <linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Kees Cook <kees.cook-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Serge E. Hallyn <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> wrote:

> > I guess we need to look at how to mix keys and namespaces again.
> 
> From strictly kernel pov, at the moment, keys are strictly usable only
> by the user in your own user namespace.

I'm not sure that's currently completely true.  Key quota maintenance is
namespaced, and the key's owner UID/GID belong to that namespace, so that's
okay, but:

 (*) key_task_permission() does not distinguish UIDs and GIDs from different
     namespaces.

 (*) A key can be referred to by its serial number, no matter whose namespace
     it is in, and will yield up its given UID/GID, even if these aren't
     actually meaningful in your namespace.

     This means request_key() can successfully upcall at the moment.

I wonder if I should make the following changes:

 (1) If the key and the accessor are in different user namespaces, then skip
     the UID and GID comparisons in key_task_permission().  That means that to
     be able to access the key you'd have to possess the key and the key would
     have to grant you Possessor access, or the key would have to grant you
     Other access.

 (2) If the key and someone viewing the key description are in different
     namespaces, then indicate that the UID and the GID are -1, irrespective of
     the actual values.

 (3) When an upcall is attempting to instantiate a key, it is allowed to access
     the keys of requestor using the requestor's credentials (UID, GID, groups,
     security label).  Ensure that this will be done in the requestor's user
     namespace.

     Nothing should need to be done here, since search_process_keyrings()
     switches to the requestor's creds.

Oh, and are security labels user-namespaced?

> We may want to look at this again, but for now I think that would be a
> safe enough default.  Later, we'll probably want the user creating a
> child_user_ns to allow his keys to be inherited by the child user_ns.

That depends what you mean by 'allow his keys to be inherited'.  Do you mean
copying all the creator's keys en mass?  You may find all you need to do is to
provide the new intended user with a new session keyring with a link back to
the creator's session keyring.

> Though, as I type that, it seems to me that that'll just become a
> maintenance pain, and it's just plain safer to have the user re-enter
> his keys,

That would certainly be simpler.

> sharing them over a file if needed.

I'm not sure what you mean by that.  Do you mean some sort of cred passing
similar to that that can be done over AF_UNIX sockets with fds?

> I'm going to not consider the TPM at the moment :)

I'm not sure the TPM is that much of a problem, assuming you're just referring
to its keystore capability...

David
