From: Casey Schaufler <casey@schaufler-ca.com>
Subject: Re: [PATCH 3/5] cr: add generic LSM c/r support
Date: Sat, 29 Aug 2009 16:40:08 -0700
Message-ID: <4A99BC58.9040205@schaufler-ca.com>
References: <20090828210041.GA27878@us.ibm.com> <20090828210417.GC28048@us.ibm.com> <4A98AEDE.1000105@schaufler-ca.com> <20090829224147.GA12549@hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20090829224147.GA12549@hallyn.com>
Sender: linux-security-module-owner@vger.kernel.org
To: "Serge E. Hallyn" <serge@hallyn.com>
Cc: "Serge E. Hallyn" <serue@us.ibm.com>, Oren Laadan <orenl@cs.columbia.edu>, Linux Containers <containers@lists.osdl.org>, linux-security-module@vger.kernel.org, SELinux <selinux@tycho.nsa.gov>, "Eric W. Biederman" <ebiederm@xmission.com>, Stephen Smalley <sds@epoch.ncsc.mil>, James Morris <jmorris@namei.org>, David Howells <dhowells@redhat.com>, Alexey Dobriyan <adobriyan@gmail.com>, Casey Schaufler <casey@schaufler-ca.com>
List-Id: containers.vger.kernel.org

Serge E. Hallyn wrote:
> Quoting Casey Schaufler (casey@schaufler-ca.com):
>   
>> Serge E. Hallyn wrote:
>>     
> ...
>   
>>> Briefly, all security fields must be exported by the LSM as a simple
>>> null-terminated string.  They are checkpointed through the
>>> security_checkpoint_obj() helper, because we must pass it an extra
>>> sectype field.  Splitting SECURITY_OBJ_SEC into one type per object
>>> type would not work because, in Smack, one void* security is used for
>>> all object types.
>>>       
>> I do not understand why the Smack behavior is a limitation here.
>>     
>
> Well it's not the Smack behavior, it's the combination of Smack's
> and SELinux's behavior :)
>   

OK. That's what I thought.

> In the end what I have here is probably best anyway - what is
> stored in the object hash is not a security struct as known
> by any LSM, but a generic object label.  So at
> object_hash_types[CKPT_OBJ_SEC]->restore(), we don't re-create
> an actual security struct, but just a string which is later
> used by security_xyztype_restore() to create an actual label.
>   

That's completely reasonable and in keeping with the Smack
mindset. Of course, it's easiest if the string is the actual
label. Smack wins!

>   
>>>   But we must pass the sectype field because in
>>> SELinux a different type of structure is stashed in each object type.
>>>       
>> But each can be expressed as a context, can't it?
>>     
>
> A set of contexts (root_u:root_r:root_t:::system_u:system_r\
> :system_t::...).
>
> There would be a problem if it were stored as a more
> structured type, and if the ->restore handler wanted to
> re-create an actual task_security_struct, ipc_security_struct,
> etc.  So the last paragraph in the patch intro was just trying to
> explain why the intermediate layer, storing a generic string on
> the c/r object hash, needs to be there.  The thing that is
> not possible is to place the actual void *security or a struct
> task_security_struct on the objhash.
>   

Right. Now why do you need a set of contexts?

> ...
>
>   
>>> +	/* str will be alloc'ed for us by the LSM.  We will free it when
>>> +	 * we clear out our hashtable */
>>>   
>>>       
>> Why do you think that you need a copy? Sure, SELinux always gives you
>> a copy, but Smack keeps "contexts" around and making a copy is not only
>> unnecessary, but wasteful. If you free the "context" with the appropriate
>> call (security_release_secctx) you will get the "free allocated memory"
>> behavior desired by SELinux and the "do nothing" behavior of Smack. For
>> free, assuming that you also fix your Smack hook so that it works in the
>> way Smack deems "Correct".
>>     
>
> Hmm, that should be doable.  Mind you these are not the same as
> secctx's returned by secid_to_secctx.

Now why is that? If they are different things, what are they?

What is the difference between a secctx and a context?
I got a bit confused because the word "context" has been
used to refer to the thing represented by a secctx for a
long time.

>   Though selinux_release_secctx 
> is implemented as a simple kfree, so it would 'just work.'  I'm
> not sure if it's better to just re-use it, or introduce a new
> security_release_context() that does the same thing...
>
> thanks,
> -serge
>
>
>   

