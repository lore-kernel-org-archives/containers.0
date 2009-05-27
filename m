From: Casey Schaufler <casey@schaufler-ca.com>
Subject: Re: [PATCH 0/8] a start to credentials c/r
Date: Wed, 27 May 2009 09:03:21 -0700
Message-ID: <4A1D6449.4020906@schaufler-ca.com>
References: <20090526173242.GA13757@us.ibm.com> <4A1CAE03.7090005@schaufler-ca.com> <20090527123728.GA27160@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20090527123728.GA27160@us.ibm.com>
Sender: linux-security-module-owner@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Cc: Oren Laadan <orenl@cs.columbia.edu>, Linux Containers <containers@lists.osdl.org>, David Howells <dhowells@redhat.com>, Alexey Dobriyan <adobriyan@gmail.com>, linux-security-module@vger.kernel.org
List-Id: containers.vger.kernel.org

Serge E. Hallyn wrote:
> Quoting Casey Schaufler (casey@schaufler-ca.com):
>   
>> Serge E. Hallyn wrote:
>>     
>>> Following is the next version of the credentials c/r patchset,
>>> on top of the c/r patchset at
>>> git://git.ncl.cs.columbia.edu/pub/git/linux-cr.git
>>>
>>> It implements checkpoint and restart of user, user namespaces,
>>> groups, supplementary groups, and struct cred.
>>>
>>> There is a question as to what to do about LSM data at
>>> restart.  Right now I'm ignoring it, which means that
>>> prepare_creds() should ensure that the restart tasks get
>>> the context of the task calling sys_restart().  I
>>> suspect the right thing to do is to add two new LSM
>>> hooks, one which checks current's authorization to
>>> restart from the checkpoint file,
>>>       
>> How would that work? Based on information in the file?
>> You have to assume that some number of checkpoint files
>> have been hand written by Elbonian ne'er do wells.
>>     
>
> Not based on information in the file, but based on the
> credentials of the task which created the file, and
> whether an unprivileged task could have hand-edited the
> file before feeding it to sys_restart().
>
> So some example decisions in terms of selinux contexts might be,
> 	1. a task of user_u may restart a file of type user_u
> 	if the checkpointed context is user_u
> 	2. a task of user_u may NOT restart a file of type user_u
> 	if the checkpointed context is root_u
> 	3. a task of root_u may restart a file of type root_u
> 	if the checkpointed context is user_u
>
> Uh, so yes, bsaed on info in the file as well  :)  Except
> of course the LSM would just be fed the checkpointed context
> and the checkpoint file context (and can deduce current's context).
>   

And SELinux can do whatever calculations it likes based on the
three contexts and the loaded policy.  Are you at all concerned
about the possibility that the policy may have changed? I can
envision scenarios in which it would be impossible for a process
to gain a particular context under current policy, but that a
checkpointed process may have stored away.

>   
>>>  and one which determines
>>> the task->cred->security filed based upon any of:
>>> 	1. current_security() of the task calling sys_restart()
>>> 	2. the task->cred->security checkpointed in the ckpt file
>>> 	3. the ->security of the checkpoint file
>>>   
>>>       
>> For Smack the correct behavior would be:
>>
>>     1. for sys_restart() callers without CAP_MAC_ADMIN
>>     2. for sys_restart() callers with CAP_MAC_ADMIN
>>     3. never
>>     
>
> That makes sense, and is basically analagous (if I'm thinking
> right) to how I'm doing capabilities.
>
> So the first (authorization hook) for smack would just always
> return TRUE?
>   

I suggest that it needs to check for a valid Smack label. Even though
they're just text strings they do have limitations, including size
(> 0 < 24) and character set. A call to smk_import() is the right
way to do it, as it also makes sure the label is in the internal list.
If smk_import() returns NULL something's amiss.


> I can hook that up right now...
>   

I bet you could do it even with the call to smk_import. (smiley here)

>   
>> sys_restart() callers running with CAP_MAC_ADMIN would have to be
>> very very careful about the files they restart. But that's nothing
>> new in the MAC world.
>>     
>
> Yup.
>
> Mind you eventually I expect a setup where some privileged program
> is asked (by privileged or unprivilegd tasks) to create a checkpoint
> and ask the TPM to sign it.  No unprivileged program can sign an
> image directly, so then a restart of a task with privilege can be
> restricted to anything with a valid signature.  In that case, it
> may be safe to have the checkpointed task's credentials completely
> restored, including LSM labels.
>   

All of the current LSMs share the property that the access control
rules (SELinux policy, Smack access rules, TOMOYO policy) may change
between the time of checkpoint and the time of restart. If I had a
silver bullet answer to the concerns that raises I'd pass it along,
but as I don't I'll stick to the answer I have for Smack (The rules
of the moment are those that matter, and the architecture of Smack
supports that) and leave the other LSMs to their own devices.


> But that's a ways off.
>   

It does look like a bit of work.

Thank you.


> thanks,
> -serge
> --
> To unsubscribe from this list: send the line "unsubscribe linux-security-module" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
>   
