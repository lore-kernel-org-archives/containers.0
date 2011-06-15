From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] Introduce ActivePid: in /proc/self/status (v2, was Vpid:)
Date: Wed, 15 Jun 2011 12:08:23 -0700
Message-ID: <m162o6lxp4.fsf@fess.ebiederm.org>
References: <20110615145527.4016.70157.stgit@bahia.local>
	<20110615184625.GA15573@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110615184625.GA15573@redhat.com> (Oleg Nesterov's message of
	"Wed, 15 Jun 2011 20:46:25 +0200")
Sender: linux-kernel-owner@vger.kernel.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: Greg Kurz <gkurz@fr.ibm.com>, akpm@linux-foundation.org, containers@lists.osdl.org, linux-kernel@vger.kernel.org, serge@hallyn.com, daniel.lezcano@free.fr, xemul@openvz.org
List-Id: containers.vger.kernel.org

Oleg Nesterov <oleg@redhat.com> writes:

> On 06/15, Greg Kurz wrote:
>>
>> @@ -176,6 +177,17 @@ static inline void task_state(struct seq_file *m, struct pid_namespace *ns,
>>  		if (tracer)
>>  			tpid = task_pid_nr_ns(tracer, ns);
>>  	}
>> +	actpid = 0;
>> +	sighand = rcu_dereference(p->sighand);
>> +	if (sighand) {
>> +		struct pid_namespace *pid_ns;
>> +		unsigned long flags;
>> +		spin_lock_irqsave(&sighand->siglock, flags);
>
> Well. This is not exactly right. We have lock_task_sighand() for this.
>
> But. Why do you need ->siglock? Why rcu_read_lock() is not enough?
>
> Hmm. You don't even need pid_ns afaics, you could simply look at
> pid->numbers[pid->level].

I got this moving in that direction, but I admit I probably didn't look
close enough.  I just remember it is always tricky when accessing a
process and dealing with races with things like unhash_process().

Eric
