From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 9/9] signal: Ignore signals sent to the pid namespace
	init
Date: Thu, 13 Dec 2007 11:16:21 -0700
Message-ID: <m1aboesbnu.fsf@ebiederm.dsl.xmission.com>
References: <m13au8ytos.fsf@ebiederm.dsl.xmission.com>
	<m1y7c0xezt.fsf@ebiederm.dsl.xmission.com>
	<m1tzmoxexb.fsf_-_@ebiederm.dsl.xmission.com>
	<m1prxcxeum.fsf_-_@ebiederm.dsl.xmission.com>
	<m1lk80xeps.fsf_-_@ebiederm.dsl.xmission.com>
	<m1hcioxenh.fsf_-_@ebiederm.dsl.xmission.com>
	<m1d4tcxelu.fsf_-_@ebiederm.dsl.xmission.com>
	<m18x40xeg6.fsf_-_@ebiederm.dsl.xmission.com>
	<m13au8xe8m.fsf_-_@ebiederm.dsl.xmission.com>
	<m1y7c0vzm4.fsf_-_@ebiederm.dsl.xmission.com>
	<20071213162811.GC219@tv-sign.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20071213162811.GC219-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org> (Oleg Nesterov's message of
	"Thu, 13 Dec 2007 19:28:11 +0300")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org> writes:

> On 12/12, Eric W. Biederman wrote:
>> 
>> -static int is_sig_init(struct task_struct *tsk)
>> +static int is_sig_init(struct task_struct *init, struct pid *sender)
>>  {
>> -	if (likely(!is_global_init(tsk->group_leader)))
>> +	if (!is_container_init(init))
>> +		return 0;
>> +
>> +	if (!sender)
>> +		sender = task_tgid(current);
>
> What if this signal is sent from the interrupt and sender == NULL?
>
>> +
>> +	if (!pid_in_pid_ns(sender, task_active_pid_ns(init)))
>>  		return 0;
>
> In that case the result of the above check can be wrong, no?

Yes.  If we are not in process context (in_interrupt) we do infer
the sender incorrectly.  Duh.  I saw something in earlier patches
people had posted didn't understand it, and didn't get an answer
when I asked about it.  I guess I should have thought about that
corner case and looked a little harder.

In this case the sender would always be the kernel.  Oleg do you
know which signals are sent from interrupt context and through
which signal sending entry points?

I'm inclined to say:
if (!sender && in_interrupt())
	sender = &init_struct_pid;

Which will cause the signal to be dropped if SIG_DFL for the real init
(same pid namespace), and otherwise cause the signal to be sent.  Which
sight unseen feels like the right thing.

It worries me that we are likely going through check_kill_permission and
all of the rest.

I expect instead of testing for in_interrupt I should be doing something
like the siginfo test in check_kill_permssion.  And just lumping all of
the kernel related signals into the same bin.

I place this one on the backburner of my thoughts and come back to it in
a bit.  I am close enough that it should be a simple straight forward code
change whatever the outcome.

Eric
