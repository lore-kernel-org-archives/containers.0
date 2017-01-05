From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH] pid: fix lockdep deadlock warning due to ucount_lock
Date: Thu, 05 Jan 2017 17:17:47 +1300
Message-ID: <87vatu87is.fsf@xmission.com>
References: <1483586894-3521-1-git-send-email-avagin@openvz.org>
	<8760lu9ngc.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <8760lu9ngc.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> (Eric W. Biederman's message of
	"Thu, 05 Jan 2017 16:48:19 +1300")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrei Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman) writes:

> Andrei Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org> writes:
>
>> =========================================================
>> [ INFO: possible irq lock inversion dependency detected ]
>> 4.10.0-rc2-00024-g4aecec9-dirty #118 Tainted: G        W
>> ---------------------------------------------------------
>> swapper/1/0 just changed the state of lock:
>>  (&(&sighand->siglock)->rlock){-.....}, at: [<ffffffffbd0a1bc6>] __lock_task_sighand+0xb6/0x2c0
>> but this lock took another, HARDIRQ-unsafe lock in the past:
>>  (ucounts_lock){+.+...}
>> and interrupts could create inverse lock ordering between them.
>> other info that might help us debug this:
>> Chain exists of:                 &(&sighand->siglock)->rlock --> &(&tty->ctrl_lock)->rlock --> ucounts_lock
>>  Possible interrupt unsafe locking scenario:
>>        CPU0                    CPU1
>>        ----                    ----
>>   lock(ucounts_lock);
>>                                local_irq_disable();
>>                                lock(&(&sighand->siglock)->rlock);
>>                                lock(&(&tty->ctrl_lock)->rlock);
>>   <Interrupt>
>>     lock(&(&sighand->siglock)->rlock);
>>
>>  *** DEADLOCK ***
>>
>> This patch removes a dependency between rlock and ucount_lock.
>
> It would have clearer if you had included the call chain where
> destroy_pid_namespaces is called with siglock held.
>
> Do you see any good reason not to just change put_ucounts to
> use spin_lock_irqsave?  Otherwise this looks like a class of bug that
> will creep in again.  As having the last user of ucounts exit and call
> put_ucount in the right conditions looks like something that will
> be hard to trigger in with lockdep.

And now I see might_lock I can just add that into put_ucounts to try and
keep this kind of issue from hiding for a full development cycle.

So I will take your patch as is.

Thank you,
Eric

>
>> Cc: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
>> Signed-off-by: Andrei Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
>> ---
>>  kernel/pid_namespace.c | 10 ++++++----
>>  1 file changed, 6 insertions(+), 4 deletions(-)
>>
>> diff --git a/kernel/pid_namespace.c b/kernel/pid_namespace.c
>> index df9e8e9..eef2ce9 100644
>> --- a/kernel/pid_namespace.c
>> +++ b/kernel/pid_namespace.c
>> @@ -151,8 +151,12 @@ static struct pid_namespace *create_pid_namespace(struct user_namespace *user_ns
>>  
>>  static void delayed_free_pidns(struct rcu_head *p)
>>  {
>> -	kmem_cache_free(pid_ns_cachep,
>> -			container_of(p, struct pid_namespace, rcu));
>> +	struct pid_namespace *ns = container_of(p, struct pid_namespace, rcu);
>> +
>> +	dec_pid_namespaces(ns->ucounts);
>> +	put_user_ns(ns->user_ns);
>> +
>> +	kmem_cache_free(pid_ns_cachep, ns);
>>  }
>>  
>>  static void destroy_pid_namespace(struct pid_namespace *ns)
>> @@ -162,8 +166,6 @@ static void destroy_pid_namespace(struct pid_namespace *ns)
>>  	ns_free_inum(&ns->ns);
>>  	for (i = 0; i < PIDMAP_ENTRIES; i++)
>>  		kfree(ns->pidmap[i].page);
>> -	dec_pid_namespaces(ns->ucounts);
>> -	put_user_ns(ns->user_ns);
>>  	call_rcu(&ns->rcu, delayed_free_pidns);
>>  }
