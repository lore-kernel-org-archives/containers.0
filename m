From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 3/4] userns: Add a more complete capability subset test to
	commit_creds
Date: Fri, 14 Dec 2012 16:11:38 -0800
Message-ID: <87r4msrx6t.fsf__1259.82878166742$1355530324$gmane$org@xmission.com>
References: <87txroxpgq.fsf@xmission.com> <87bodwxpcg.fsf@xmission.com>
	<20121215000338.GC13659@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20121215000338.GC13659-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org> (Serge E. Hallyn's
	message of "Sat, 15 Dec 2012 00:03:38 +0000")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Cc: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

"Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> writes:

> Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
>> 
>> When unsharing a user namespace we reduce our credentials to just what
>> can be done in that user namespace.  This is a subset of the credentials
>> we previously had.  Teach commit_creds to recognize this is a subset
>> of the credentials we have had before and don't clear the dumpability flag.
>> 
>> This allows an unprivileged  program to do:
>> unshare(CLONE_NEWUSER);
>> fd = open("/proc/self/uid_map", O_RDWR);
>> 
>> Where previously opening the uid_map writable would fail because
>> the the task had been made non-dumpable.
>> 
>> Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
>
> Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
>
>> ---
>>  kernel/cred.c |   26 +++++++++++++++++++++++++-
>>  1 files changed, 25 insertions(+), 1 deletions(-)
>> 
>> diff --git a/kernel/cred.c b/kernel/cred.c
>> index 48cea3d..993a7ea41 100644
>> --- a/kernel/cred.c
>> +++ b/kernel/cred.c
>> @@ -455,6 +455,30 @@ error_put:
>>  	return ret;
>>  }
>>  
>
> Do you think we need to warn that this can only be used for
> commit_creds?  (i.e. if someone tried ot use this in some
> other context, the 'creds are subset of target ns is a child
> of current_ns' assumption would be wrong)

This function should be a general test valid at any time.

Except that I forgot the bit of the test that asks is the original cred
the owner of the subset user namespace.

I will respin this patch.

As a small segway this property that unshare(CLONE_NEWUSER) results
in a subset of the capabilities a process already had is a very
important property to make it possible to reason about user namespaces.
Maintaining this property is the reason behind the choices I made
in fixing cap_capable.

>> +static bool cred_cap_issubset(const struct cred *set, const struct cred *subset)
>> +{
>> +	const struct user_namespace *set_ns = set->user_ns;
>> +	const struct user_namespace *subset_ns = subset->user_ns;
>> +
>> +	/* If the two credentials are in the same user namespace see if
>> +	 * the capabilities of subset are a subset of set.
>> +	 */
>> +	if (set_ns == subset_ns)
>> +		return cap_issubset(subset->cap_permitted, set->cap_permitted);
>> +
>> +	/* The credentials are in a different user namespaces
>
> This can only happen during setns and CLONE_NEWUSER right?

Right.  This can only happen during setns, unshare(CLONE_NEWUSER),
and possibly during clone.  Otherwise we are not changing the user
namespace.  However for clarity and robustness I don't want the code
to rely on that.

>> +	 * therefore one is a subset of the other only if a set is an
>> +	 * ancestor of subset.
>> +	 */
>
>> +	while (subset_ns != &init_user_ns) {
>> +		if (set_ns == subset_ns->parent)
>> +			return true;
>> +		subset_ns = subset_ns->parent;
>> +	}
>> +
>> +	return false;
>> +}
>> +
>>  /**
>>   * commit_creds - Install new credentials upon the current task
>>   * @new: The credentials to be assigned
>> @@ -493,7 +517,7 @@ int commit_creds(struct cred *new)
>>  	    !gid_eq(old->egid, new->egid) ||
>>  	    !uid_eq(old->fsuid, new->fsuid) ||
>>  	    !gid_eq(old->fsgid, new->fsgid) ||
>> -	    !cap_issubset(new->cap_permitted, old->cap_permitted)) {
>> +	    !cred_cap_issubset(old, new)) {
>>  		if (task->mm)
>>  			set_dumpable(task->mm, suid_dumpable);
>>  		task->pdeath_signal = 0;
>> -- 
>> 1.7.5.4
