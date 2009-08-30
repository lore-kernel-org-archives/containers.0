From: "Serge E. Hallyn" <serge@hallyn.com>
Subject: Re: [PATCH 2/5] cr: checkpoint the active LSM and add
	RESTART_KEEP_LSM flag
Date: Sun, 30 Aug 2009 08:48:09 -0500
Message-ID: <20090830134809.GA14699@hallyn.com>
References: <20090828210041.GA27878@us.ibm.com> <20090828210208.GA28048@us.ibm.com> <4A98B1D7.9050108@schaufler-ca.com> <20090829225923.GB12549@hallyn.com> <4A99C1B6.6080504@schaufler-ca.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4A99C1B6.6080504@schaufler-ca.com>
Sender: linux-security-module-owner@vger.kernel.org
To: Casey Schaufler <casey@schaufler-ca.com>
Cc: "Serge E. Hallyn" <serue@us.ibm.com>, Oren Laadan <orenl@cs.columbia.edu>, Linux Containers <containers@lists.osdl.org>, linux-security-module@vger.kernel.org, SELinux <selinux@tycho.nsa.gov>, "Eric W. Biederman" <ebiederm@xmission.com>, Stephen Smalley <sds@epoch.ncsc.mil>, James Morris <jmorris@namei.org>, David Howells <dhowells@redhat.com>, Alexey Dobriyan <adobriyan@gmail.com>
List-Id: containers.vger.kernel.org

Quoting Casey Schaufler (casey@schaufler-ca.com):
> Serge E. Hallyn wrote:
> > Quoting Casey Schaufler (casey@schaufler-ca.com):
> >   
> >> Serge E. Hallyn wrote:
> >>     
> >>> [ patch 1 was a trivial non-security patch so if you didn't see
> >>> it, you didn't miss anything ]
> >>>
> >>> The RESTART_KEEP_LSM flag indicates that the LSM should
> >>> attempt to reuse checkpointed security labels.  It is always
> >>> invalid when the LSM at restart differs from that at checkpoint.
> >>> It is currently only usable for capabilities.
> >>>   
> >>>       
> >> Can you imagine a scenario in which restoring a process on a
> >> system with a different LSM configuration makes any sense at all?
> >>     
> >
> > Without RESTART_KEEP_LSM absolutely.
> >   
> 
> Wow. I run a program on a system with the default LSM and get all
> sorts of passwords for network based services, then take it to an
> SELinux system that has a different firewall configuration based on
> the assumption that SELinux will prevent the program from getting
> that information. You'd allow that?

?

What exactly would refusing the restart prevent?

You already have the passwords in the checkpoint file, so you're
not protecting those.

The program was running under xyz_t, which on the old system was
allowed to make some change the fw configuration, but is not under
the new.  Then after restart, it will be labeled as xyz_t, and
won't be allowed to make the change.

When a program running as abc_t calls sys_restart() do restart
the task under xyz_t, then
	1. everything which is re-created for the task will
	   need to be allowed (under current policy) to
	   abc_t.
	2. abc_t will need to be allowed process_t:restore to
	   xyz_t.

What exactly can the abc_t task do if allowed to restart,
which it couldn't otherwise do?  (1) If it can read the checkpoint
files, it can access the checkpointed keys either way.  (2) If
the new policy allows xyz_t to do something it couldn't do
before, and abc_t is allowed to transition to xyz_t, then abc_t
could presumably start any program under xyz_t to do what it
wants.  That is limited by the need to be able to create a file
of an appropriate entry type.  That's why before I was thinking
of passing the type of the checkpoint file to security_cred_restore()
as well.  and (3) If under the new policy xyz_t is NOT allowed to do
something which the old policy could do, then after restart it
won't be allowed to do it either.

Quoting your example again:

> Wow. I run a program on a system with the default LSM and get all
> sorts of passwords for network based services, then take it to an

XXX Here you already have gotten the passwords under the old
policy.  So the restart has nothing to do with whether you can
get the keys which let you get the information.  Then,

> SELinux system that has a different firewall configuration based on
> the assumption that SELinux will prevent the program from getting
> that information. You'd allow that?

XXX The sys_restart() process will make sure that the process calling
sys_restart() is authorized to recreate anything (i.e. open
connections, open files, etc) which the task had open at checkpoint,
and anything done after checkpoint will still be authorized by
the new policy.

So really the big problem I see is that I've introduced a way
to disassociate the type you can restore to, from the file (and
contents of the file) you can execute to restore into the
type.

I think that can be helped by more liberal use of relabel_froms
and passing the type of a checkpoint file along to
security_cred_restore().  Passing the type of the checkpoint
file allows us to at least ensure that the file was created
by a process of a type which is also authorized to be a part
of the chain to restarting a task of xyz_t.  Adding the
relabel_from to file restore()s may be necessary to prevent
a leak of MAC perms.  Again, the process calling sys_restore()
must originally have been authorized to open the file with
the requested permissions, and must be allowed
	allow restore_t target_file_t:file restore;
permissions.  But it seems reasonable to add to that the
requirement to be allowed to
	allow restore_t orig_file_t:file relabel_from;

Now in the meantime, please note that there is nothing stopping
you from ensuring that only my_only_restore_t is allowed to
transition to anything, and having the program which transitions
to that domain and calls sys_restart() first compare policy
versions.

> > With RESTART_KEEP_LSM, on a system with a different LSM loaded,
> > certainly not.
> >
> > With RESTART_KEEP_LSM, on a system with the same LSM but a different
> > policy, yes I do.  If any checkpointed contexts have been invalidated
> > in the new policy, then restart with RESTART_KEEP_LSM should fail (*1).
> > If the contexts are still valid, then it seems reasonable to
> > assume that bin_t, user_t, etc, still basically mean what they
> > meant before.  No reason to refuse restart just because I loaded
> > a policy module for postfix, imo.
> >   
> 
> Again, Wow. How can you tell that a process that ran for a while
> under another policy can not have done anything that would make
> it unsafe under the current policy?

If it 'did something' before checkpoint, then either
	1. the system is already changed as a result,
	   and whether we restore or not has no further
	   effect.
or
	2. the process ended up with some resource which
	   it couldn't have gotten under the new policy.
	   In that case, if the task doing sys_restart()
	   is not allowed to re-create the resource (file
	   handle to /etc/shadow, socket, whatever) then
	   the checkpoint will fail.  If the task doing
	   sys_restart() *is* allowed to re-create it,
	   but the target context xyz_t would not have
	   been, then I don't consider that a leak.  As
	   I said above, it could compare policy versions
	   in user-space ahead of time or the user could have
	   used a more appropriate context from which to
	   call sys_restart().

>  And what if the program is the
> very one with the changed policy? How can you tell?

Well then either
	1. the checkpoint was taken before it changed the
	   policy, so it will try to do so again (and
	   hopefully fail)
	2. the checkpoint was taken after it changed the
	   policy, so the policy hasn't actually changed
	   between checkpoint and restart.

and in any case, if the program was authorized to change
policy, then the program calling sys_restart() on it should
have required some tremendously trusted type to begin with.

> > I could add both an lsm-module and lsm-policy version to the
> > checkpoint header, where the lsm-policy might be a sha1sum of
> > the whole policy, but that seems like overkill, a lot of
> > overhead, and probably a maintenance headache for the lsm-module
> > version.
> >
> >   
> >> Goodness gracious, even if the "old" environment and the "new"
> >> are both SELinux and the policies are different I can't see how
> >> you could make any sort of claim that restoring the process is
> >> safe.
> >>     
> >
> > In what sense do you mean 'unsafe'?  The initial creation or
> > access to any checkpointed resource always happens with the
> > sys_restart() caller's and existing object's contexts, so there
> > should be no opportunity for accessing data which the old policy
> > allowed but the new does not.  It's possible that the task will
> > fail because of a more restrictive new policy, but so be it.
> >   
> 
> Now I'm no expert on SELinux policies, but if the change in policy
> was made to prevent the program from doing something that it has
> already done under the old policy so that it can safely allow the
> program to do something it hasn't done prior to being checkpointed,
> you have a big problem.
> 
> That's a big sentence. Let me clarify a little:
> 
> Let's say that my program, placebo, needs to do one of two
> dangerous things, either thing A early in the execution or
> thing B late in the execution. It would be perfectly safe for
> placebo to do either, but really dreadfully bad for it to do
> both. The program is of course oblivious to the policy, so it
> will try to do both even though it really only needs to do one.
> 
> The old policy allows placebo to do A and not B. The new policy
> allows B but not A. Either is safe. If I run placebo under the
> old policy, checkpoint it, and restart it under the new policy
> Bad Things happen. Even with both the old and the new policies
> being demonstrably safe.

Then I would argue the user (who has authorization to restart this
beast and therefore is hopefully not malicious) should have compared
policies before doing sys_restart...

It seems I could save a lot of time arguing by proposing that

	1. each LSM keep a policy version (sha1sum or whatever
	   suits it) updated at every policy update
	2. a new security_app_restore() hook passes in the
	   the checkpoint header, so that the LSM can choose
	   to verify the checkpoint file type and the policy
	   version.  Checkpoint file type check might be done
	   even if !(flags & RESTART_KEEP_LSM)...

but I'm still not convinced this isn't just better done by
userspace if it wants to.  Because we are not protecting
against a malicious user, as he can get the info he got
from checkpoint() using ptrace, so we are only protecting
the user from himself.

Maybe I should wait a day to send this, since perhaps
on an afternoon walk I'll see the error of my ways...

thanks,
-serge
