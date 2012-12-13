From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: [GIT PULL] user namespace and namespace infrastructure changes
	for 3.8
Date: Thu, 13 Dec 2012 15:02:58 -0800
Message-ID: <CALCETrWxXZ1OzZeH_SGeg1E16rssxBwg+hjG09N5dkqweVKeRA@mail.gmail.com>
References: <87ip88uw4n.fsf@xmission.com> <50CA2B55.5070402@amacapital.net>
	<87mwxhtxve.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87mwxhtxve.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Dec 13, 2012 at 2:01 PM, Eric W. Biederman
<ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
> Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org> writes:
>
>> On 12/11/2012 01:17 PM, Eric W. Biederman wrote:
>>>
>>> Linus,
>>>
>>> Please pull the for-linus git tree from:
>>>
>>>    git://git.kernel.org:/pub/scm/linux/kernel/git/ebiederm/user-namespace.git for-linus
>>>
>>>    HEAD: 98f842e675f96ffac96e6c50315790912b2812be proc: Usable inode numbers for the namespace file descriptors.
>>>
>>>    This tree is against v3.7-rc3
>>
>> You've just allowed unprivileged users to create new pid namespaces,
>> etc, by creating a new userns, then creating a new pid namespace inside
>> that userns, then setns-ing from outside the userns into the pid ns.  Is
>> this intentional?  (The mount ns is okay -- it checks for CAP_CHROOT on
>> setns.)
>
> Absolutely.  My commit messages talk about this.  I allow creating other
> namespaces once inside a user namespace deliberately.  There is no
> reason I know of to ban creation of pid and other namespaces once you
> are inside of a user namespace.
>

I must be looking at the wrong commit message.

> But please also note the difference between capable and ns_capable.  Any
> security check that is capable() still requires priviliges in the
> initial user namespace.

Huh?

I'm talking about:

clone with CLONE_NEWUSER
 - child does unshare(CLONE_NEWPID)
 - parent does setfd(child's pid namespace)

Now the parent is running in the init userns with a different pid ns.
Setuid binaries will work but will see the unexpected pid ns.  With
mount namespaces, this would be Really Bad (tm).  With pid or ipc or
net, it's less obviously dangerous, but I'm not convinced it's safe.

I sort of think that setns on a *non*-userns should require
CAP_SYS_ADMIN in the current userns, at least if no_new_privs isn't
set.

>
>> In user_namespace.c:
>>
>>         /* Threaded many not enter a different user namespace */
>>         if (atomic_read(&current->mm->mm_users) > 1)
>>                 return -EINVAL;
>>
>> The comment has a typo.  Also, you're checking the wrong condition:
>> that's whether the vm is shared, not whether the thread group has more
>> than one member.
>
> Yes the comment should say.
>
> Threaded processes may not enter a different user namespace.
>
> As for the condition.  mm_users will equal one for a non-threaded
> process.  And mm_users is the check we use in unshare to detect if
> a threaded process calls unshare so I think the check seems perfectly
> reasonable.  Especially since the vm must have more than one member if
> there is more than one member in the thread group.

A non-threaded process can have mm_users == 2 with CLONE_VM.  I'm not
sure this is a problem, though.

>
>> In any case, why are threads special here?
>
> You know I don't think I stopped to think about it.   The combination
> of CLONE_NEWUSER and CLONE_THREAD have been denined since the first user
> namespace support was merged in 2008.
>
> I do know that things can get really strange when you mix multiple
> namespaces in a process.  tkill of your own threads will stop working.
> Which access permissions should apply to files you mmap, file handles
> you have open, the core dumper etc.
>
> We do allow setresuid per thread so we might be able to cope
> with a process that mixes with user namespaces in different threads,
> but I would want a close review of things before we allow that kind of
> sharing.
>

Fair enough.

I'd personally be more concerned about shared signal handlers than
shared tgid, though.  The signal handler set has all kinds of weird
things like session id.

>> I think, although I haven't verified it, that these changes allow
>> CAP_SYS_ADMIN to bypass the bounding set (and, in particular, to gain
>> CAP_MODULE): unshare the user namespace and then setfd yourself back.  I
>> think that setns should only grant caps when changing to a descendent
>> namespace.
>
> (See the end.  A significant bug in cap_capable slipped in about
>  3.5. cap_capable is only supposed to grant permissions to the owner
>  of a user namespace if it is a child user namespace).

[snipping lots of stuff]

If the intended semantics of cap_capable are, indeed:

If targ_ns is equals or is a descendent of cred->user_ns and the cap
is effective, return true.  If targ_ns is owned by cred->euid and
targ_ns is a descendent of cred->user_ns (but is not equal to
cred->user_ns), then return true.  Else return false

then I agree with you on almost everything you said.  I assumed that
the actual semantics were intended.

>
>> unshare has a bug.  This code:
>
> Interesting...
>
> Looking at it this is a very small misfeature.
>
> What is happening is that commit_creds is setting is making the task
> undumpable because we changed the set of capabilities in struct cred.
>
> This in turn results in pid_revalidate setting the owner of
> of /proc/self/uid_map to GLOBAL_ROOT_UID.
>
> From the outside the permissions on /proc/self/uid_map look like:
> -rw-r--r-- 1 root root 0 2012-12-13 12:43 /proc/30530/uid_map
>
> Then since /proc/self/uid_map uses the default permission function
> and the test program below is not run as root the read-write open
> of uid_map fails.

It's probably either worth fixing this or disabling unshare of userns.
 This makes it hard to use.  IMO non-dumpable tasks should still be
able to access the contents of /proc/self -- i.e. I'd call this a more
general bug.

But I'd also argue that unsharing userns shouldn't set non-dumpable --
cap_permitted increased, but the new capabilities are still logically
a subset of the old ones.

>
>> (Of course, the fact that caps don't usefully inherit is an issue --
>> there's a loooong thread going on right now about that.)  But doing this
>> enshrines root-has-caps even farther into ABI.  At least please make
>> this depend on !SECURE_NOROOT.
>
> With the bug fixed there is nothing new here.  On creation of a user
> namespace of course the initial process with have all capabilities just
> like init starts out with all capabilities.
>
> The owner of a user namespace when outside of a user namespace also
> has all capabilities over a user namespace, and has since March of 2011.
>
> When entering a user namespace what happens is that the owner permanently
> drops whatever privileges the owner has to their previous user namespace
> and their implied capabilites get put into the capability bitmask.
>
> This has absolutely nothing to do with SECURE_NOROOT and the case where
> becomming root gains privileges.  What does happen from a global
> perspective is that there are some capabilities that a process has that
> it will not be able to drop (capabilities over the user namespaces it
> owns), and if the owner of the process has created user namespaces.

I think I agree with you.  This would still be more useful with
capability inheritance, though :).


One more issue: the requirement that both upper and lower uids (etc.)
in the maps are in order is rather limiting.  I have no objection if
you only require upper ids to be monotonic, but currently there's no
way to may root outside to uid n (for n > 0) and some nonroot user
outside to uid 0.

Also, the fact that you can remap onto the unmapped id is a little
strange.  I haven't found any reason it would be a security bug, but
it's still odd.


--Andy
