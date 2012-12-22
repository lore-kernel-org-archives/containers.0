From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH review 2/3] pidns: Stop pid allocation when init dies
Date: Sat, 22 Dec 2012 12:31:21 -0800
Message-ID: <87bodlbzhi.fsf@xmission.com>
References: <87d2y2elbi.fsf@xmission.com> <871ueiel9d.fsf@xmission.com>
	<20121222165438.GA19680@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20121222165438.GA19680-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> (Oleg Nesterov's message of
	"Sat, 22 Dec 2012 17:54:38 +0100")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:

> On 12/21, Eric W. Biederman wrote:
>>
>> --- a/include/linux/pid_namespace.h
>> +++ b/include/linux/pid_namespace.h
>> @@ -21,7 +21,7 @@ struct pid_namespace {
>>  	struct kref kref;
>>  	struct pidmap pidmap[PIDMAP_ENTRIES];
>>  	int last_pid;
>> -	int nr_hashed;
>> +	unsigned int nr_hashed;
>>  	struct task_struct *child_reaper;
>>  	struct kmem_cache *pid_cachep;
>>  	unsigned int level;
>> @@ -42,6 +42,8 @@ struct pid_namespace {
>>
>>  extern struct pid_namespace init_pid_ns;
>>
>> +#define PIDNS_HASH_ADDING (1U << 31)
>
> Yes, agreed. We can't rely on PF_EXITING/whatever, we need the explicit
> flag.

The simpler and more comprehensible we can make this code the better. 
We have had too many surprises in this code because of complex failure
modes.

> 1/2 looks fine too. Only one nit about init_pid_ns below...

Then I will add your acked-by to the first patch.

>> @@ -319,7 +318,7 @@ struct pid *alloc_pid(struct pid_namespace *ns)
>>
>>  	upid = pid->numbers + ns->level;
>>  	spin_lock_irq(&pidmap_lock);
>> -	if (ns->nr_hashed < 0)
>> +	if (ns->nr_hashed < PIDNS_HASH_ADDING)
>
> I won't insist, but perhaps if "(!(nr_hashed & PIDNS_HASH_ADDING))"
> looks more understandable.

I will stare at it both ways and post an updated patch.

I'm not certain which form I like better.  Certainly the decrements
are doing a double duty.

>> +void disable_pid_allocation(struct pid_namespace *ns)
>> +{
>> +	spin_lock_irq(&pidmap_lock);
>> +	if (ns->nr_hashed >= PIDNS_HASH_ADDING)
>
> Do we really need this check? It seems that PIDNS_HASH_ADDING
> bit must be always set when disable_pid_allocation() is called.
>
>> +		ns->nr_hashed -= PIDNS_HASH_ADDING;
>
> Anyway, nr_hashed &= ~PIDNS_HASH_ADDING looks simpler and doesn't
> need a check.

That I agree with.

> But again, I won't insist this is minor and subjective.
>
>>  struct pid *find_pid_ns(int nr, struct pid_namespace *ns)
>>  {
>>  	struct hlist_node *elem;
>> @@ -584,7 +591,7 @@ void __init pidmap_init(void)
>>  	/* Reserve PID 0. We never call free_pidmap(0) */
>>  	set_bit(0, init_pid_ns.pidmap[0].page);
>>  	atomic_dec(&init_pid_ns.pidmap[0].nr_free);
>> -	init_pid_ns.nr_hashed = 1;
>> +	init_pid_ns.nr_hashed = 1 + PIDNS_HASH_ADDING;
>
> The obly chunk which doesn't look exactly correct to me, although this
> doesn't really matter. Hmm, actually the code was already wrong before
> this patch.
>
> I think init_pid_ns.nr_hashed should be PIDNS_HASH_ADDING, we should not
> add 1 to account the unused zero pid, and kernel_thread(kernel_init) was
> not called yet.

Good point because the zero pid does not get hashed.  Who knows perhaps
with a little more evolution create_pid_ns can be used to create the
initial pid namespace.

I am also going to add "BUILD_BUG_ON(PID_MAX_LIMIT >= PIDNS_HASH_ADDING);"
to document that the pid values and PIDNS_HASH_ADDING can't overlap.

Eric	
