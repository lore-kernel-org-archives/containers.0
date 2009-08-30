From: Casey Schaufler <casey@schaufler-ca.com>
Subject: Re: [PATCH 2/5] cr: checkpoint the active LSM and add	RESTART_KEEP_LSM
 flag
Date: Sun, 30 Aug 2009 14:43:41 -0700
Message-ID: <4A9AF28D.2030803@schaufler-ca.com>
References: <20090828210041.GA27878@us.ibm.com> <20090828210208.GA28048@us.ibm.com> <4A98B1D7.9050108@schaufler-ca.com> <20090829225923.GB12549@hallyn.com> <4A99C1B6.6080504@schaufler-ca.com> <20090830134809.GA14699@hallyn.com> <4A9ACBD4.4020804@schaufler-ca.com> <20090830202412.GA16222@hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20090830202412.GA16222@hallyn.com>
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
> ...
>   
>>> What exactly would refusing the restart prevent?
>>>
>>> You already have the passwords in the checkpoint file, so you're
>>> not protecting those.
>>>   
>>>       
>> I seem to be having some trouble presenting my point. It's not about
>> the passwords. It's not about the firewall configuration. It's not
>> even really about the SELinux policy. It's about the total security
>> configuration of the system. This is a problem with checkpoint/restart
>> in general and there isn't much we can do about reassigning user id
>> and other bad things that can happen.
>>
>> If the admin decides that an action is acceptable because the SELinux
>> policy prevents some other action it had better be the case that a
>> process was never allowed to perform that "other action". If you allow
>> restart across policy changes you can't be sure that the process has
>> not performed such an "other action". Processes are not stateless.
>>     
>
> No, but again there are only 3 kinds of state that I can think of
> that are relevant at restart:
>
> 	1. calculations which were made before ckpt and after
> 	   restart.  For instance,  maybe before the policy change
> 	   the task could read key a but not key b.  After it could
> 	   read key b but not a.  With both keys, it can rule the
> 	   world.
> 	   In this case c/r changes nothing, bc the user could get
> 	   the same info using ptrace.
>
> 	2. system-wide changes which the task could do with the
> 	   old policy, while it could do different once after.
> 	   Doing both changes it can rule the world.
> 	   Again, c/r changes nothing, bc the user could simply
> 	   run the program twice to make both changes.
> 	
> 	3. resources (file descriptions, whatever) which the task
> 	   could create before the policy change but not after.
> 	   Every resource will be re-opened at sys_restart()
> 	   using the credentials of the caller.
> 	   This isn't perfect.  It means that if the program
> 	   started out privileged to open some file and then
> 	   dropped privilege, then the program either will fail
> 	   to restart, or will have to be restarted with extra
> 	   privilege.  And there's a decent chance that the
> 	   sys_restart() caller will have more privs than the
> 	   program anyway.  But that is why I feel pretty strongly
> 	   that it's up to the caller, in userspace, to worry about
> 	   it and do policy checks if need be.
>
> I am more worried about a user taking a checkpoint image and
> editing it, then pursuading a more privileged user to restart it
> for him.  "see, the source was trustworthy and needed privs to
> start.  can you restart it for me?"
>   

Yes, the skinware attack is the greatest vulnerability.

> The only thing to do about that is to eventually do TPM signing
> of checkpoint images.
>   

Even with that you're not eliminating the problem, you're just
making in (lots) more expensive to exploit.

>   
>>> The program was running under xyz_t, which on the old system was
>>> allowed to make some change the fw configuration, but is not under
>>> the new.  Then after restart, it will be labeled as xyz_t, and
>>> won't be allowed to make the change.
>>>
>>> When a program running as abc_t calls sys_restart() do restart
>>> the task under xyz_t, then
>>> 	1. everything which is re-created for the task will
>>> 	   need to be allowed (under current policy) to
>>> 	   abc_t.
>>> 	2. abc_t will need to be allowed process_t:restore to
>>> 	   xyz_t.
>>>
>>> What exactly can the abc_t task do if allowed to restart,
>>> which it couldn't otherwise do?
>>>       
>> That's the point. It does not have to do the bad thing, it has
>> already been done. The cat is out of the bag. The process now has
>> state that it couldn't get under the new policy.
>>     
>
> Again I claim that any state it couldn't get under the new policy,
> either it could get using ptrace anyway (i.e. a key), or it can't
> re-create the state because the new policy will prevent it.
>   

Remember that we're looking at the behavior of arbitrary applications
here, and maybe the interactions between LSM defined behavior and
application defined security behavior.


>   
>>  The new policy
>> allows the process to do something that it could not had it
>> started under the new policy.
>>     
>
> And it still is re-starting under the new policy, though again
> (I keep stressing bc this worries me more) the authorization
> checks are done against the credentials at sys_restart(), not
> the checkpointed credentials.
>
> ...
>
>   
>>> Then I would argue the user (who has authorization to restart this
>>> beast and therefore is hopefully not malicious) should have compared
>>> policies before doing sys_restart...
>>>   
>>>       
>> I'm a firm believer in malicious users. That, and users who are
>> sufficiently stupid to be indistinguishable from malicious users.
>> That, and users who are sufficiently clever to do the same things
>> that a malicious user would do in order to do something that looks
>> like a really good idea, but that is not.
>>     
>
> So do you think that adding a policy version check in the kernel
> at restart would help this?
>
> Do you think providing a recipe for userspace to do the policy
> checks would help?

If you are willing to trust the user space tools to get it right.
It gets things really complicated building trust relationships when
you have multiple policies to deal with. Look at the issues that
labeled NFS is trying to deal with. How would the user space program
know what the policy may have been when the process last ran?

>   Along with a security_may_restart() hook
> so that LSM policy can force restart to go through a helper
> that does these checks, if it wants to enforce that?
>   


I really don't know. As you're well aware, I've never bought
into the sophistication of the SELinux policy mechanism. One
of my major concerns has always been that the policy on two
machines may be different. With CR you have a case where the
policy on the same machine can be different over the life of
a process.

I am much less concerned with Smack because all the protection
it provides are subject/object relationships and those are
pretty straight forward. Even there, if the old rule set allowed
the process to read from a label the new rule set doesn't allow
you could get burned.

In the end, I don't suppose that anything stronger than "requires
privilege" is going to result in a system that's useful. So maybe
your best bet is security_may_restart(), and let the LSM decide.
Smack will most likely require CAP_MAC_ADMIN where as SELinux will
do a check based on the half-dozen contexts mentioned elsewhere.
I still don't think it is safe, but upon further reflection I'm
convinced that from a security standpoint it can never be safe to
do a restore. So we're debating one case, and a fringe one at that.

Let 'er rip.


