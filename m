From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 8/9] signal: Drop signals before sending them to init.
Date: Thu, 13 Dec 2007 10:50:59 -0700
Message-ID: <m1bq8uscu4.fsf@ebiederm.dsl.xmission.com>
References: <m13au8ytos.fsf@ebiederm.dsl.xmission.com>
	<m1y7c0xezt.fsf@ebiederm.dsl.xmission.com>
	<m1tzmoxexb.fsf_-_@ebiederm.dsl.xmission.com>
	<m1prxcxeum.fsf_-_@ebiederm.dsl.xmission.com>
	<m1lk80xeps.fsf_-_@ebiederm.dsl.xmission.com>
	<m1hcioxenh.fsf_-_@ebiederm.dsl.xmission.com>
	<m1d4tcxelu.fsf_-_@ebiederm.dsl.xmission.com>
	<m18x40xeg6.fsf_-_@ebiederm.dsl.xmission.com>
	<m13au8xe8m.fsf_-_@ebiederm.dsl.xmission.com>
	<20071213162502.GB219@tv-sign.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20071213162502.GB219-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org> (Oleg Nesterov's message of
	"Thu, 13 Dec 2007 19:25:02 +0300")
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
>> By making the rule (for init dropping signals):
>> When sending a signal to init, the presence of a signal handler that
>> is not SIG_DFL allows the signal to be sent to init.  If the signal
>> is not sent it is silently dropped without becoming pending.
>
> But isn't it better to modify sig_ignore() and handle_stop_signal()
> instead? This way we seem to need less changes,
>
> 	http://marc.info/?l=linux-kernel&m=118753610515859
>
> (the patch above itself is not complete and a bit obsolete)

No.  That way leads to semantic disaster.

In particular if it is traced or blocked your patch did not
ignore the signal, the signal would be queued up.  We would
not know who the sender is and thus not know the proper
disposition for the signal.

For a clean definition that we can maintain into the future
either we must either drop the signal before it is placed on the
queue or otherwise processed.  Or we must track the sender.

Tracking the sender is expensive.

>> The only noticeable user space difference from todays init is that it
>> no longer needs to worry about signals becoming pending when it has
>> them marked as SIG_DFL and blocked.
>
> Ugh. I have to apologize again. I got a fever, and it turns out I just
> can't read English.
>
> So, do you mean we can ignore the problems with the signals which are
> currently blocked by /sbin/init?

Yes.  Further I am saying those signals will never become pending if
we do not have a signal handler installed.

> I personally agree, but I'm not sure I understand this right.
>
>> +static int sig_init_drop(struct task_struct *tsk, int sig)
>> +{
>> +	/* All signals for which init has a SIG_DFL handler are
>> +	 * silently dropped without being sent.
>> +	 */
>> +	if (!is_sig_init(tsk))
>> +		return 0;
>> +
>> +	return (tsk->sighand->action[sig-1].sa.sa_handler == SIG_DFL);
>> +}
>
> What if /sbin/init has a handler, but before this signal is delivered
> /sbin/init does signal(SIG_DFL) ? We should modify so_sigaction() to
> prevent this. Note again the patch above.

No.  We should treat signals that we process for /sbin/init completely
normally.

If we try and do the right thing with pending signals we have the question
which pid namespaces sent the signal.  If the signal came from a decedent
of /sbin/init we should drop the signal.  If the signal came from outside
the pid namespace of init we should keep the signal.  There is no right
correct if you define what happens that way.

Therefore we make a small change to the definition of where we drop
signals to init.  We always unconditionally drop them in the sender
if init has the signal handler set to SIG_DFL.  Otherwise the signals
are processed normally.

This gives /sbin/init completely normal signal handling if the signal is
ever enqueued.  Something trivial to implement and explain.

Theoretically the new definition can deliver a few more signals to
/sbin/init and see them processed.  In practice I do not expect this
to matter.  Especially since /sbin/init did ask for the signals at
one time.

Eric
