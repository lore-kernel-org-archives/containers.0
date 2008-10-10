From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: Keys and namespaces
Date: Fri, 10 Oct 2008 15:30:53 -0700
Message-ID: <m1hc7k13s2.fsf@frodo.ebiederm.org>
References: <20081010011917.GA8046@us.ibm.com> <414.1223643503@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <414.1223643503-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> (David Howells's message of "Fri, 10
	Oct 2008 13:58:23 +0100")
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:

> On the subject of namespaces: I still need to look at providing a key ID and
> keyring name namespace.
>
> Is it worth me just using the user_namespace?  A number of parameters are
> per-UID (such as the key quotas), so it might very well make sense to do that.

Yes.

> That way, user_namespace could actually be a credentials namespace.

I have always thought of it as a security token namespace.

I'm not certain about the term credential as that usually means something
like password.  In the context of keys where you are caching something
like a kerberos token it makes more sense.  Even there it isn't a
secret key that is being cached but more of a capability that says
that the secret key was known at some point.

> If that is the case, CLONE_NEWUSER should also set up (clone?) the keys and
> keyrings attached to the parent.  This possibly needs to be done anyway as the
> keys have UID and GID references that may be invalid in the new namespace.
>
> How do the UIDs and GIDs in different namespaces map, anyway?

At the simplest level they do not map between namespaces.

At a practical level the users in a user namespace should have
no more capabilities than the creator of the user namespace and
the creator of the user namespace should have the power to kill
all processes and remove all objects created by users in that
user namespace.

For filesystem access where we have talked about this in some detail.
The current idea is to have a user namespace parameter on struct inode.
All security credential comparisons will need to become comparisons
of both user_namespace and uid to match.

> Furthermore, some keys may actually represent foreign user details; perhaps
> NTFS or CIFS user IDs for example.  Should those be discarded on CLONE_NEWUSER?

After CLONE_NEWUSER the user id and guid should be 0, and no keys should be
held.  With respect to holding credentials it should be essentially the same
state as when init starts.  At least as a general rule.

If keys are the kind of thing that can be passed between namespaces
allowing user space to control which keys get passed makes sense.  We
allow the controlling tty and process groups to remain the same across
pid namespace creation and require processes to change them explicitly
if needed.  It is definitely a requirement to get to the state init
starts in, either by kernel fiat or normal user space operations.


A word about foreign user details.

In my conception a user namespace is essentially a single administration
domain of uids and gids, and as such can span and does today span several machines.
user namespaces are unique in that their tokens are assigned administratively
and the kernel has no control over lifetime of tokens.

In that concept foreign users doesn't make a lot of sense to me.

Keys certainly provide the ability to several different implementations
of user identification.  How that interacts with a web of administration
of user permissions to objects not living in the kernel I don't know.

Ultimately I think putting keys in the user namespace is a good match.
As it is a way to talk about stored user identification either in memory
or on disk, and how that maps to what a user is allowed to do.

Eric
