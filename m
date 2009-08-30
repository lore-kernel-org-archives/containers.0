From: Casey Schaufler <casey@schaufler-ca.com>
Subject: Re: [PATCH 2/5] cr: checkpoint the active LSM and add	RESTART_KEEP_LSM
 flag
Date: Sun, 30 Aug 2009 11:58:28 -0700
Message-ID: <4A9ACBD4.4020804@schaufler-ca.com>
References: <20090828210041.GA27878@us.ibm.com> <20090828210208.GA28048@us.ibm.com> <4A98B1D7.9050108@schaufler-ca.com> <20090829225923.GB12549@hallyn.com> <4A99C1B6.6080504@schaufler-ca.com> <20090830134809.GA14699@hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20090830134809.GA14699@hallyn.com>
Sender: linux-security-module-owner@vger.kernel.org
To: "Serge E. Hallyn" <serge@hallyn.com>
Cc: "Serge E. Hallyn" <serue@us.ibm.com>, Oren Laadan <orenl@cs.columbia.edu>, Linux Containers <containers@lists.osdl.org>, linux-security-module@vger.kernel.org, SELinux <selinux@tycho.nsa.gov>, "Eric W. Biederman" <ebiederm@xmission.com>, Stephen Smalley <sds@epoch.ncsc.mil>, James Morris <jmorris@namei.org>, David Howells <dhowells@redhat.com>, Alexey Dobriyan <adobriyan@gmail.com>, Casey Schaufler <casey@schaufler-ca.com>
List-Id: containers.vger.kernel.org

Serge E. Hallyn wrote:
> Quoting Casey Schaufler (casey@schaufler-ca.com):
>   
>> Serge E. Hallyn wrote:
>>     
>>> Quoting Casey Schaufler (casey@schaufler-ca.com):
>>>   
>>>       
>>>> Serge E. Hallyn wrote:
>>>>     
>>>>         
>>>>> [ patch 1 was a trivial non-security patch so if you didn't see
>>>>> it, you didn't miss anything ]
>>>>>
>>>>> The RESTART_KEEP_LSM flag indicates that the LSM should
>>>>> attempt to reuse checkpointed security labels.  It is always
>>>>> invalid when the LSM at restart differs from that at checkpoint.
>>>>> It is currently only usable for capabilities.
>>>>>   
>>>>>       
>>>>>           
>>>> Can you imagine a scenario in which restoring a process on a
>>>> system with a different LSM configuration makes any sense at all?
>>>>     
>>>>         
>>> Without RESTART_KEEP_LSM absolutely.
>>>   
>>>       
>> Wow. I run a program on a system with the default LSM and get all
>> sorts of passwords for network based services, then take it to an
>> SELinux system that has a different firewall configuration based on
>> the assumption that SELinux will prevent the program from getting
>> that information. You'd allow that?
>>     
>
> ?
>
> What exactly would refusing the restart prevent?
>
> You already have the passwords in the checkpoint file, so you're
> not protecting those.
>   


I seem to be having some trouble presenting my point. It's not about
the passwords. It's not about the firewall configuration. It's not
even really about the SELinux policy. It's about the total security
configuration of the system. This is a problem with checkpoint/restart
in general and there isn't much we can do about reassigning user id
and other bad things that can happen.

If the admin decides that an action is acceptable because the SELinux
policy prevents some other action it had better be the case that a
process was never allowed to perform that "other action". If you allow
restart across policy changes you can't be sure that the process has
not performed such an "other action". Processes are not stateless.

> The program was running under xyz_t, which on the old system was
> allowed to make some change the fw configuration, but is not under
> the new.  Then after restart, it will be labeled as xyz_t, and
> won't be allowed to make the change.
>
> When a program running as abc_t calls sys_restart() do restart
> the task under xyz_t, then
> 	1. everything which is re-created for the task will
> 	   need to be allowed (under current policy) to
> 	   abc_t.
> 	2. abc_t will need to be allowed process_t:restore to
> 	   xyz_t.
>
> What exactly can the abc_t task do if allowed to restart,
> which it couldn't otherwise do?

That's the point. It does not have to do the bad thing, it has
already been done. The cat is out of the bag. The process now has
state that it couldn't get under the new policy. The new policy
allows the process to do something that it could not had it
started under the new policy.

>   (1) If it can read the checkpoint
> files, it can access the checkpointed keys either way.  (2) If
> the new policy allows xyz_t to do something it couldn't do
> before, and abc_t is allowed to transition to xyz_t, then abc_t
> could presumably start any program under xyz_t to do what it
> wants.  That is limited by the need to be able to create a file
> of an appropriate entry type.  That's why before I was thinking
> of passing the type of the checkpoint file to security_cred_restore()
> as well.  and (3) If under the new policy xyz_t is NOT allowed to do
> something which the old policy could do, then after restart it
> won't be allowed to do it either.
>
> Quoting your example again:
>
>   
>> Wow. I run a program on a system with the default LSM and get all
>> sorts of passwords for network based services, then take it to an
>>     
>
> XXX Here you already have gotten the passwords under the old
> policy.  So the restart has nothing to do with whether you can
> get the keys which let you get the information.  Then,
>
>   
>> SELinux system that has a different firewall configuration based on
>> the assumption that SELinux will prevent the program from getting
>> that information. You'd allow that?
>>     
>
> XXX The sys_restart() process will make sure that the process calling
> sys_restart() is authorized to recreate anything (i.e. open
> connections, open files, etc) which the task had open at checkpoint,
> and anything done after checkpoint will still be authorized by
> the new policy.
>
> So really the big problem I see is that I've introduced a way
> to disassociate the type you can restore to, from the file (and
> contents of the file) you can execute to restore into the
> type.
>
> I think that can be helped by more liberal use of relabel_froms
> and passing the type of a checkpoint file along to
> security_cred_restore().  Passing the type of the checkpoint
> file allows us to at least ensure that the file was created
> by a process of a type which is also authorized to be a part
> of the chain to restarting a task of xyz_t.  Adding the
> relabel_from to file restore()s may be necessary to prevent
> a leak of MAC perms.  Again, the process calling sys_restore()
> must originally have been authorized to open the file with
> the requested permissions, and must be allowed
> 	allow restore_t target_file_t:file restore;
> permissions.  But it seems reasonable to add to that the
> requirement to be allowed to
> 	allow restore_t orig_file_t:file relabel_from;
>
> Now in the meantime, please note that there is nothing stopping
> you from ensuring that only my_only_restore_t is allowed to
> transition to anything, and having the program which transitions
> to that domain and calls sys_restart() first compare policy
> versions.
>
>   
>>> With RESTART_KEEP_LSM, on a system with a different LSM loaded,
>>> certainly not.
>>>
>>> With RESTART_KEEP_LSM, on a system with the same LSM but a different
>>> policy, yes I do.  If any checkpointed contexts have been invalidated
>>> in the new policy, then restart with RESTART_KEEP_LSM should fail (*1).
>>> If the contexts are still valid, then it seems reasonable to
>>> assume that bin_t, user_t, etc, still basically mean what they
>>> meant before.  No reason to refuse restart just because I loaded
>>> a policy module for postfix, imo.
>>>   
>>>       
>> Again, Wow. How can you tell that a process that ran for a while
>> under another policy can not have done anything that would make
>> it unsafe under the current policy?
>>     
>
> If it 'did something' before checkpoint, then either
> 	1. the system is already changed as a result,
> 	   and whether we restore or not has no further
> 	   effect.
> or
> 	2. the process ended up with some resource which
> 	   it couldn't have gotten under the new policy.
> 	   In that case, if the task doing sys_restart()
> 	   is not allowed to re-create the resource (file
> 	   handle to /etc/shadow, socket, whatever) then
> 	   the checkpoint will fail.  If the task doing
> 	   sys_restart() *is* allowed to re-create it,
> 	   but the target context xyz_t would not have
> 	   been, then I don't consider that a leak.  As
> 	   I said above, it could compare policy versions
> 	   in user-space ahead of time or the user could have
> 	   used a more appropriate context from which to
> 	   call sys_restart().
>
>   
>>  And what if the program is the
>> very one with the changed policy? How can you tell?
>>     
>
> Well then either
> 	1. the checkpoint was taken before it changed the
> 	   policy, so it will try to do so again (and
> 	   hopefully fail)
> 	2. the checkpoint was taken after it changed the
> 	   policy, so the policy hasn't actually changed
> 	   between checkpoint and restart.
>
> and in any case, if the program was authorized to change
> policy, then the program calling sys_restart() on it should
> have required some tremendously trusted type to begin with.
>
>   
>> ...
>
> Then I would argue the user (who has authorization to restart this
> beast and therefore is hopefully not malicious) should have compared
> policies before doing sys_restart...
>   

I'm a firm believer in malicious users. That, and users who are
sufficiently stupid to be indistinguishable from malicious users.
That, and users who are sufficiently clever to do the same things
that a malicious user would do in order to do something that looks
like a really good idea, but that is not.

> It seems I could save a lot of time arguing by proposing that
>
> 	1. each LSM keep a policy version (sha1sum or whatever
> 	   suits it) updated at every policy update
> 	2. a new security_app_restore() hook passes in the
> 	   the checkpoint header, so that the LSM can choose
> 	   to verify the checkpoint file type and the policy
> 	   version.  Checkpoint file type check might be done
> 	   even if !(flags & RESTART_KEEP_LSM)...
>
> but I'm still not convinced this isn't just better done by
> userspace if it wants to.  Because we are not protecting
> against a malicious user, as he can get the info he got
> from checkpoint() using ptrace, so we are only protecting
> the user from himself.
>
> Maybe I should wait a day to send this, since perhaps
> on an afternoon walk I'll see the error of my ways...
>
> thanks,
> -serge
>
>
>   

