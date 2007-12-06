From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH] pid: sys_wait... fixes
Date: Thu, 06 Dec 2007 10:21:39 -0700
Message-ID: <m1y7c7spr0.fsf@ebiederm.dsl.xmission.com>
References: <m17ijsv7iu.fsf@ebiederm.dsl.xmission.com>
	<20071206170145.GA10674@tv-sign.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20071206170145.GA10674-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org> (Oleg Nesterov's message of
	"Thu, 6 Dec 2007 20:01:45 +0300")
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org> writes:

> On 12/05, Eric W. Biederman wrote:
>> 
>> This modifies do_wait and eligible_child to take a pair of
>> enum pid_type and struct pid *pid to precisely specify what
>> set of processes are eligible to be waited for,  instead of the
>> raw pid_t value from sys_wait4.
>
> Personally, I like this patch very much. Not only it fixes the bug,
> in my opinion it also makes the code more clean.
>
> However at first glance it has a minor fixable problem,
>
>> +	if (type < PIDTYPE_MAX) {
>> +		if (p->pids[type].pid != pid)
>>  			return 0;
>>  	}
>
> If type != PIDTYPE_PID we can't trust p->pids[type].pid unless p is a
> group leader. This .pid could be just a "random value".

Ugh.  You are correct.  Thanks for the review.
That is one annoying special case.

Eric
