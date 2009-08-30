From: Casey Schaufler <casey@schaufler-ca.com>
Subject: Re: [PATCH 2/5] cr: checkpoint the active LSM and add	RESTART_KEEP_LSM
 flag
Date: Sat, 29 Aug 2009 17:03:02 -0700
Message-ID: <4A99C1B6.6080504@schaufler-ca.com>
References: <20090828210041.GA27878@us.ibm.com> <20090828210208.GA28048@us.ibm.com> <4A98B1D7.9050108@schaufler-ca.com> <20090829225923.GB12549@hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20090829225923.GB12549@hallyn.com>
Sender: linux-security-module-owner@vger.kernel.org
To: "Serge E. Hallyn" <serge@hallyn.com>
Cc: "Serge E. Hallyn" <serue@us.ibm.com>, Oren Laadan <orenl@cs.columbia.edu>, Linux Containers <containers@lists.osdl.org>, linux-security-module@vger.kernel.org, SELinux <selinux@tycho.nsa.gov>, "Eric W. Biederman" <ebiederm@xmission.com>, Stephen Smalley <sds@epoch.ncsc.mil>, James Morris <jmorris@namei.org>, David Howells <dhowells@redhat.com>, Alexey Dobriyan <adobriyan@gmail.com>
List-Id: containers.vger.kernel.org

Serge E. Hallyn wrote:
> Quoting Casey Schaufler (casey@schaufler-ca.com):
>   
>> Serge E. Hallyn wrote:
>>     
>>> [ patch 1 was a trivial non-security patch so if you didn't see
>>> it, you didn't miss anything ]
>>>
>>> The RESTART_KEEP_LSM flag indicates that the LSM should
>>> attempt to reuse checkpointed security labels.  It is always
>>> invalid when the LSM at restart differs from that at checkpoint.
>>> It is currently only usable for capabilities.
>>>   
>>>       
>> Can you imagine a scenario in which restoring a process on a
>> system with a different LSM configuration makes any sense at all?
>>     
>
> Without RESTART_KEEP_LSM absolutely.
>   

Wow. I run a program on a system with the default LSM and get all
sorts of passwords for network based services, then take it to an
SELinux system that has a different firewall configuration based on
the assumption that SELinux will prevent the program from getting
that information. You'd allow that?

> With RESTART_KEEP_LSM, on a system with a different LSM loaded,
> certainly not.
>
> With RESTART_KEEP_LSM, on a system with the same LSM but a different
> policy, yes I do.  If any checkpointed contexts have been invalidated
> in the new policy, then restart with RESTART_KEEP_LSM should fail (*1).
> If the contexts are still valid, then it seems reasonable to
> assume that bin_t, user_t, etc, still basically mean what they
> meant before.  No reason to refuse restart just because I loaded
> a policy module for postfix, imo.
>   

Again, Wow. How can you tell that a process that ran for a while
under another policy can not have done anything that would make
it unsafe under the current policy? And what if the program is the
very one with the changed policy? How can you tell?

> I could add both an lsm-module and lsm-policy version to the
> checkpoint header, where the lsm-policy might be a sha1sum of
> the whole policy, but that seems like overkill, a lot of
> overhead, and probably a maintenance headache for the lsm-module
> version.
>
>   
>> Goodness gracious, even if the "old" environment and the "new"
>> are both SELinux and the policies are different I can't see how
>> you could make any sort of claim that restoring the process is
>> safe.
>>     
>
> In what sense do you mean 'unsafe'?  The initial creation or
> access to any checkpointed resource always happens with the
> sys_restart() caller's and existing object's contexts, so there
> should be no opportunity for accessing data which the old policy
> allowed but the new does not.  It's possible that the task will
> fail because of a more restrictive new policy, but so be it.
>   

Now I'm no expert on SELinux policies, but if the change in policy
was made to prevent the program from doing something that it has
already done under the old policy so that it can safely allow the
program to do something it hasn't done prior to being checkpointed,
you have a big problem.

That's a big sentence. Let me clarify a little:

Let's say that my program, placebo, needs to do one of two
dangerous things, either thing A early in the execution or
thing B late in the execution. It would be perfectly safe for
placebo to do either, but really dreadfully bad for it to do
both. The program is of course oblivious to the policy, so it
will try to do both even though it really only needs to do one.

The old policy allows placebo to do A and not B. The new policy
allows B but not A. Either is safe. If I run placebo under the
old policy, checkpoint it, and restart it under the new policy
Bad Things happen. Even with both the old and the new policies
being demonstrably safe.

>>  The same goes for having file based capabilities on one
>> and not on the other.
>>     
>
> A task running as uid 500 with cap_dac_read_search=ep could have
> been started at least 3 ways:
> 	1. a uid 500 task executing a file with cap_dac_read_search=ep
> 	file caps
> 	2. a root task executing a file which does prctl(PR_SET_KEEPCAPS),
> 	setuid(500), and drops the other caps,
> 	3. a uid 500 task executing a setuid root version of the
> 	file in (2).
>
> When we are restarting a task, we don't really care which of
> the above ways it might have gotten its privileges.
>
> I certainly could be overlooking something - what do you see as the
> safety problem?
>
>   
>> It seems that the check you've chosen is necessary, but far from
>> sufficient.
>>     
>
> Thanks much for giving this some thought.  Without doubt this
> is tricky business, and I was definately hoping for some serious
> discussion.
>
> thanks,
> -serge
>
> *1 - Hmm, in Smack, if the caller has CAP_MAC_ADMIN, then he
> can load new, currently undefined types, right?  I guess that
> could be a problem, though again I assume the new type should
> simply have no accesses and so shouldn't be unsafe.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-security-module" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
>   

