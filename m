From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC][PATCH 2/2] pidns: Remove proc flush races when a pid namespaces are exiting.
Date: Fri, 09 Jul 2010 06:05:54 -0700
Message-ID: <m1lj9k4xfx.fsf@fess.ebiederm.org>
References: <1277399329-18087-1-git-send-email-louis.rilling@kerlabs.com>
	<20100624191843.GA14205@redhat.com>
	<20100625102303.GG3773@hawkmoon.kerlabs.com>
	<20100625183733.GA2627@us.ibm.com> <20100625192945.GA25532@redhat.com>
	<20100625212618.GA11917@us.ibm.com>
	<20100625212758.GA30474@redhat.com>
	<20100625220713.GA31123@us.ibm.com>
	<m1r5jd5l0v.fsf_-_@fess.ebiederm.org>
	<m1mxu15kv4.fsf_-_@fess.ebiederm.org>
	<20100709121425.GB18586@hawkmoon.kerlabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100709121425.GB18586@hawkmoon.kerlabs.com> (Louis Rilling's message of "Fri\, 9 Jul 2010 14\:14\:25 +0200")
Sender: linux-kernel-owner@vger.kernel.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org, Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
List-Id: containers.vger.kernel.org

Louis Rilling <Louis.Rilling@kerlabs.com> writes:

> On 08/07/10 21:39 -0700, Eric W. Biederman wrote:
>> 
>> Currently it is possible to put proc_mnt before we have flushed the
>> last process that will use the proc_mnt to flush it's proc entries.
>> 
>> This race is fixed by not flushing proc entries for dead pid
>> namespaces, and calling pid_ns_release_proc unconditionally from
>> zap_pid_ns_processes after the pid namespace has been declared dead.
>
> One comment below.
>
>> 
>> To ensure we don't unnecessarily leak any dcache entries with skipped
>> flushes pid_ns_release_proc flushes the entire proc_mnt when it is
>> called.
>> 
>> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
>> ---
>>  fs/proc/base.c         |    9 +++++----
>>  fs/proc/root.c         |    3 +++
>>  kernel/pid_namespace.c |    1 +
>>  3 files changed, 9 insertions(+), 4 deletions(-)
>> 
>> diff --git a/fs/proc/base.c b/fs/proc/base.c
>> index acb7ef8..e9d84e1 100644
>> --- a/fs/proc/base.c
>> +++ b/fs/proc/base.c
>> @@ -2742,13 +2742,14 @@ void proc_flush_task(struct task_struct *task)
>>  
>>  	for (i = 0; i <= pid->level; i++) {
>>  		upid = &pid->numbers[i];
>> +
>> +		/* Don't bother flushing dead pid namespaces */
>> +		if (test_bit(PIDNS_DEAD, &upid->ns->flags))
>> +			continue;
>> +
>
> IMHO, nothing prevents zap_pid_ns_processes() from setting PIDNS_DEAD and
> calling pid_ns_release_proc() right now. zap_pid_ns_processes() does not wait
> for EXIT_DEAD (self-reaping) children to be released.

Good point we need something probably a lock to prevent proc_mnt from
going away here.  We might do a little better if we were starting with
a specific dentry, those at least have some rcu properties but that isn't
a big help.

Hmm.  Perhaps there is a way to completely restructure this flushing
of dentries.  It is just an optimization after all so we don't get too many
stale dentries building up.

It might just be worth it simply kill proc_flush_mnt altogether.  I know
it is measurable when we don't do the flushing but perhaps there can
be a work struct that periodically wakes up and smacks stale proc dentries.

Right now I really don't think proc_flush_task is worth the hassle it
causes.

Grumble, Grumble more thinking to do.

Eric
