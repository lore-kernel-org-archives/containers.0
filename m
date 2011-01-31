From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: Re: [PATCH 4/4] pidns: Use task_active_pid_ns where appropriate
Date: Mon, 31 Jan 2011 15:47:58 +0100
Message-ID: <4D46CB9E.1090802__43792.7830069841$1296485410$gmane$org@free.fr>
References: <1296469525-30111-1-git-send-email-daniel.lezcano@free.fr>	<1296469525-30111-5-git-send-email-daniel.lezcano@free.fr>
	<AANLkTikjcou-0b4NejpY66qXeZuzsC-M+oNTyHk=OE-Z@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <AANLkTikjcou-0b4NejpY66qXeZuzsC-M+oNTyHk=OE-Z-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

On 01/31/2011 12:26 PM, Alexey Dobriyan wrote:
> On Mon, Jan 31, 2011 at 12:25 PM, Daniel Lezcano<daniel.lezcano-GANU6spQydw@public.gmane.org>  wrote:
>> The expressions tsk->nsproxy->pid_ns and task_active_pid_ns
>> aka ns_of_pid(task_pid(tsk)) should have the same number of
>> cache line misses with the practical difference that
>> ns_of_pid(task_pid(tsk)) is released later in a processes life.
>>
>> Furthermore by using task_active_pid_ns it becomes trivial
>> to write an unshare implementation for the the pid namespace.
>>
>> So I have used task_active_pid_ns everywhere I can.
> Yet current->nsproxy->pid_ns is way clearer.
> Because live current always has pid_ns.
>
> This task_active_pid_ns() is misnamed(?) because it does matter only
> for dead tasks?

Actually this function is later used, for the unshare, to get the pid_ns 
of a specific task, not the current one.

http://kerneltrap.org/mailarchive/linux-kernel/2010/6/20/4585095

Do you suggest task_pid_ns(struct task_struct *tsk) would be a better name ?

>> -               current->nsproxy->pid_ns->last_pid);
>> +               task_active_pid_ns(current)->last_pid);
> I thought of doing exactly opposite patch :-)
>
