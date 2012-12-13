From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [GIT PULL] user namespace and namespace infrastructure changes
	for 3.8
Date: Thu, 13 Dec 2012 14:01:41 -0800
Message-ID: <87mwxhtxve.fsf@xmission.com>
References: <87ip88uw4n.fsf@xmission.com> <50CA2B55.5070402@amacapital.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <50CA2B55.5070402-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org> (Andy Lutomirski's message of
	"Thu, 13 Dec 2012 11:24:05 -0800")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org> writes:

> On 12/11/2012 01:17 PM, Eric W. Biederman wrote:
>> 
>> Linus,
>> 
>> Please pull the for-linus git tree from:
>> 
>>    git://git.kernel.org:/pub/scm/linux/kernel/git/ebiederm/user-namespace.git for-linus
>> 
>>    HEAD: 98f842e675f96ffac96e6c50315790912b2812be proc: Usable inode numbers for the namespace file descriptors.
>> 
>>    This tree is against v3.7-rc3
>
> You've just allowed unprivileged users to create new pid namespaces,
> etc, by creating a new userns, then creating a new pid namespace inside
> that userns, then setns-ing from outside the userns into the pid ns.  Is
> this intentional?  (The mount ns is okay -- it checks for CAP_CHROOT on
> setns.)

Absolutely.  My commit messages talk about this.  I allow creating other
namespaces once inside a user namespace deliberately.  There is no
reason I know of to ban creation of pid and other namespaces once you
are inside of a user namespace.

But please also note the difference between capable and ns_capable.  Any
security check that is capable() still requires priviliges in the
initial user namespace.

> In user_namespace.c:
>
>         /* Threaded many not enter a different user namespace */
>         if (atomic_read(&current->mm->mm_users) > 1)
>                 return -EINVAL;
>
> The comment has a typo.  Also, you're checking the wrong condition:
> that's whether the vm is shared, not whether the thread group has more
> than one member.

Yes the comment should say.

Threaded processes may not enter a different user namespace.

As for the condition.  mm_users will equal one for a non-threaded
process.  And mm_users is the check we use in unshare to detect if
a threaded process calls unshare so I think the check seems perfectly
reasonable.  Especially since the vm must have more than one member if
there is more than one member in the thread group.

> In any case, why are threads special here?

You know I don't think I stopped to think about it.   The combination
of CLONE_NEWUSER and CLONE_THREAD have been denined since the first user
namespace support was merged in 2008.

I do know that things can get really strange when you mix multiple
namespaces in a process.  tkill of your own threads will stop working.
Which access permissions should apply to files you mmap, file handles
you have open, the core dumper etc.

We do allow setresuid per thread so we might be able to cope
with a process that mixes with user namespaces in different threads,
but I would want a close review of things before we allow that kind of
sharing.

> I think, although I haven't verified it, that these changes allow
> CAP_SYS_ADMIN to bypass the bounding set (and, in particular, to gain
> CAP_MODULE): unshare the user namespace and then setfd yourself back.  I
> think that setns should only grant caps when changing to a descendent
> namespace.

(See the end.  A significant bug in cap_capable slipped in about
 3.5. cap_capable is only supposed to grant permissions to the owner
 of a user namespace if it is a child user namespace).

These changes do not allow CAP_SYS_ADMIN to bypass the bounding set.

The test:

	if (!ns_capable(user_ns, CAP_SYS_ADMIN))
		return -EPERM;

verifies that the user namespace we are entering is a nested user
namespace, because we can only have CAP_SYS_ADMIN in our current
namespace and in nested user namespaces.

> Also in userns_install:
>
> 796         /* Don't allow gaining capabilities by reentering
> 797          * the same user namespace.
> 798          */
> 799         if (user_ns == current_user_ns())
> 800                 return -EINVAL;
>
> Why?

To keep processes that deliberately drop some capabilities from being
able to gain those capabilities back by reentering the current user
namespace.

Aka that test plus the ns_capable test prevent are the combination
that prevent a process gaining privileges in the current user namespace.

> You can trivially bypass this by creating a temporary user ns.
> (If you're the owner of your own ns, then you can create a subsidiary
> ns, map yourself into it, then setns back -- you'll still be the
> owner.)

Nope.   Once you have capabilities in a user namespace you do not have
any capabilities in the parent user namespace.  Entering a user
namespace is a one way operation.

> unshare has a bug.  This code:

Interesting...

Looking at it this is a very small misfeature.

What is happening is that commit_creds is setting is making the task
undumpable because we changed the set of capabilities in struct cred.

This in turn results in pid_revalidate setting the owner of
of /proc/self/uid_map to GLOBAL_ROOT_UID.

From the outside the permissions on /proc/self/uid_map look like:
-rw-r--r-- 1 root root 0 2012-12-13 12:43 /proc/30530/uid_map

Then since /proc/self/uid_map uses the default permission function
and the test program below is not run as root the read-write open
of uid_map fails.

> Also, I'm entirely unconvinced that the owner of a userns should
> automatically have all caps (in the cap_capable sense) on a userns if
> the task is inside that ns.   What's wrong with just using normal
> caps?

You have said it strangely. But I absolutely agree with you.

There is a bug in cap_capable that snuck in when kuids made it possible
for an owner to exist in multiple user namespaces.

cap_capable is only supposed to grant capabilities without looking at
the capability bitmap to the owner of the user namespace when the user
namespace in question is a child of the current user namespace.

When cap_capable was written the owner had to live in the parent user
namespace so the fact that it was a child user namespace was
automatically guaranteed.  kuids broke that assumption, and cap_capable
broke when I chaned it to use kuids.

That is an embarrassing brown paper bag bug.

I am going to step back and see if I can figure out how to fix
cap_capable.  There is the "targ_ns != &init_user_ns" test before we
grant the owner of a user namespace permission so the effects are
limited to what you can do in a child user namespace.

> (Of course, the fact that caps don't usefully inherit is an issue --
> there's a loooong thread going on right now about that.)  But doing this
> enshrines root-has-caps even farther into ABI.  At least please make
> this depend on !SECURE_NOROOT.

With the bug fixed there is nothing new here.  On creation of a user
namespace of course the initial process with have all capabilities just
like init starts out with all capabilities.

The owner of a user namespace when outside of a user namespace also
has all capabilities over a user namespace, and has since March of 2011.

When entering a user namespace what happens is that the owner permanently
drops whatever privileges the owner has to their previous user namespace
and their implied capabilites get put into the capability bitmask.

This has absolutely nothing to do with SECURE_NOROOT and the case where
becomming root gains privileges.  What does happen from a global
perspective is that there are some capabilities that a process has that
it will not be able to drop (capabilities over the user namespaces it
owns), and if the owner of the process has created user namespaces.

Eric
