From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 03/10] userns: Add a limit on the number of user namespaces
Date: Thu, 21 Jul 2016 10:23:27 -0500
Message-ID: <878twv6mmo.fsf@x220.int.ebiederm.org>
References: <8737n5dscy.fsf@x220.int.ebiederm.org>
	<20160720012138.7894-1-ebiederm@xmission.com>
	<20160720012138.7894-3-ebiederm@xmission.com>
	<578F2233.2040708@kyup.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <578F2233.2040708-6AxghH7DbtA@public.gmane.org> (Nikolay Borisov's message of "Wed,
	20 Jul 2016 10:03:15 +0300")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org>
Cc: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>
List-Id: containers.vger.kernel.org

Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org> writes:

> On 07/20/2016 04:21 AM, Eric W. Biederman wrote:
[snip]
>> +static bool inc_user_namespaces(struct user_namespace *ns)
>> +{
>> +	struct user_namespace *pos, *bad;
>> +	for (pos = ns; pos; pos = pos->parent) {
>> +		int max = READ_ONCE(pos->max_user_namespaces);
>> +		int sum = atomic_inc_return(&pos->user_namespaces);
>> +		if (sum > max)
>> +			goto fail;
>> +	}
>> +	return true;
>> +fail:
>> +	bad = pos;
>> +	atomic_dec(&pos->user_namespaces);
>> +	for (pos = ns; pos != bad; pos = pos->parent)
>> +		atomic_dec(&pos->user_namespaces);
>> +
>> +	return false;
>> +}
>> +
>> +static void dec_user_namespaces(struct user_namespace *ns)
>> +{
>> +	struct user_namespace *pos;
>> +	for (pos = ns; pos; pos = pos->parent) {
>> +		int dec = atomic_dec_if_positive(&pos->user_namespaces);
>> +		WARN_ON_ONCE(dec < 0);
>> +	}
>> +}
>
> Here you are essentially duplicating the logic of
> page_counter_try_charge and page_counter_uncharge. Perhaps the code of
> the page_counter can be moved away from mm/ and into kernel and the
> renamed to something more generic? E.g. the removed resource_counters or
> maybe "hierarchical counters"? If more namespaces are added in the
> future we certainly wouldn't want proliferation of pairs of such
> hierarchical inc/dec functions.


There are a couple of issues with using the logic of
page_counter_try_charge.  

- It is a maintenance issue.  AKA it ties the fate of two things that
  otherwise should be independent.

- Inc/dec is much easier to protect against interger underflow/overflow
  than a counter that adds/removes arbitrary charges.  While a great
  inspiration when I looked at page_counter_xxx I believe I saw
  issues with the handling of large charges that could cause problems
  in the general case.

- Where we can reuse the logic I actually do in the next patch.

- Having looked at some of the counter cases for things like this aiming
  for general reuse at this point is actually an anti-pattern.  The
  fundamental question is what is a reasonable number of instances for
  this resource and as such how do we know when an application is
  broken.  That really depends on the resource and inotify resources are
  very very different from these name space counters for example.  Which
  means there is no one size fits all design.  As such I oppose code
  that suggests that a one size fits all design is the way to go.

So I think the way this needs to go is for hierarchical resources to
have their own paired functions for readability if nothing else, and if
there is a common pattern we can abstract it out as it is observed.
Which limits the changes to those paired functions.

>> +
>>  /*
>>   * Create a new user namespace, deriving the creator from the user in the
>>   * passed credentials, and replacing that user with the new root user for the
>> @@ -128,8 +169,12 @@ int create_user_ns(struct cred *new)
>>  	kgid_t group = new->egid;
>>  	int ret;
>>  
>> +	ret = -EUSERS;
>>  	if (parent_ns->level > 32)
>> -		return -EUSERS;
>> +		goto fail;
>> +
>> +	if (!inc_user_namespaces(parent_ns))
>> +		goto fail;
>
> I think it would be better if the simple "return -EUSERS" semantics is
> saved and the "fail" label entirely nuked. In this case you only leave
> the more complex error handling.

I wrote it my preference. And this is all bike shedding.

[snip]
>> @@ -165,6 +211,7 @@ int create_user_ns(struct cred *new)
>>  	ns->level = parent_ns->level + 1;
>>  	ns->owner = owner;
>>  	ns->group = group;
>> +	ns->max_user_namespaces = INT_MAX - 1;
>
> Do we want an INT_MAX -1 default initialization or inheritance from
> parent's value?

I like (INT_MAX -1) because that is effectively a value meaning unlimited
and as such that is the simplest possible thing to implement.  When you
can set the value to anything in your namespace a default doesn't do
anything and showing that your level of the hierarchy isn't limiting
things but another level of the hiearchy is seems meaninful to me.

I admit I have argued for other behavior in the past but when I sat down
and looked at all of the alternatives I could not see a benefit from
other behavior.

That said I'm not opposed to evolving how things work and make things
work better.  This just looked like the best baseline to start the
design from that I could see.

Eric
