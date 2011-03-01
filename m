From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [PATCH 01/10] Add a user_namespace as creator/owner of
	uts_namespace
Date: Mon, 28 Feb 2011 16:28:30 -0800
Message-ID: <20110228162830.35a051a8.akpm__8006.50639362193$1298939352$gmane$org@linux-foundation.org>
References: <20110224150150.GA8262@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110224150150.GA8262-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org>
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
Cc: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, dlezcano-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org, kernel list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, LSM <linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, oleg-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, 24 Feb 2011 15:01:51 +0000
"Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> wrote:

> Cc: oleg-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org, dlezcano-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org

I don't think those addresses do what you think they do.

> copy_process() handles CLONE_NEWUSER before the rest of the
> namespaces.  So in the case of clone(CLONE_NEWUSER|CLONE_NEWUTS)
> the new uts namespace will have the new user namespace as its
> owner.  That is what we want, since we want root in that new
> userns to be able to have privilege over it.
> 

Well this sucks.  Anyone who is reading this patch series really won't
have a clue what any of it is for.  There's no context provided.

A useful way of thinking about this is to ask yourself "what will Linus
think when this stuff hits his inbox".  If the answer is "he'll say
wtf" then we're doing it wrong.

Sigh.

I shall (again) paste in the below text, which I snarfed from the wiki.
Please check that it is complete, accurate and adequate.  If not,
please send along replacement text.


: The expected course of development for user namespaces targeted
: capabilities is laid out at https://wiki.ubuntu.com/UserNamespace.
: 
: Goals:
: 
: - Make it safe for an unprivileged user to unshare namespaces.  They
:   will be privileged with respect to the new namespace, but this should
:   only include resources which the unprivileged user already owns.
: 
: - Provide separate limits and accounting for userids in different
:   namespaces.  
: 
: Status:
: 
:   Currently (as of 2.6.38) you can clone with the CLONE_NEWUSER flag to
:   get a new user namespace if you have the CAP_SYS_ADMIN, CAP_SETUID, and
:   CAP_SETGID capabilities.  What this gets you is a whole new set of
:   userids, meaning that user 500 will have a different 'struct user' in
:   your namespace than in other namespaces.  So any accounting information
:   stored in struct user will be unique to your namespace.
: 
:   However, throughout the kernel there are checks which
: 
:   - simply check for a capability.  Since root in a child namespace
:     has all capabilities, this means that a child namespace is not
:     constrained.
: 
:   - simply compare uid1 == uid2.  Since these are the integer uids,
:     uid 500 in namespace 1 will be said to be equal to uid 500 in
:     namespace 2.  
: 
:   As a result, the lxc implementation at lxc.sf.net does not use user
:   namespaces.  This is actually helpful because it leaves us free to
:   develop user namespaces in such a way that, for some time, user
:   namespaces may be unuseful.  
: 
: 
: Bugs aside, this patchset is supposed to not at all affect systems which
: are not actively using user namespaces, and only restrict what tasks in
: child user namespace can do.  They begin to limit privilege to a user
: namespace, so that root in a container cannot kill or ptrace tasks in the
: parent user namespace, and can only get world access rights to files. 
: Since all files currently belong to the initila user namespace, that means
: that child user namespaces can only get world access rights to *all*
: files.  While this temporarily makes user namespaces bad for system
: containers, it starts to get useful for some sandboxing.
: 
: I've run the 'runltplite.sh' with and without this patchset and found no
: difference.
