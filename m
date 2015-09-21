From: bsegall--- via Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Subject: Re: [PATCH] pidns: fix set/getpriority and ioprio_set/get in
	PRIO_USER mode
Date: Mon, 21 Sep 2015 11:42:56 -0700
Message-ID: <xm268u7zaa1b.fsf@sword-of-the-dawn.mtv.corp.google.com>
References: <xm26io7a9lwz.fsf@sword-of-the-dawn.mtv.corp.google.com>
	<20150917142926.1a68072b19ef0ada47eabe43@linux-foundation.org>
	<874minis1b.fsf@x220.int.ebiederm.org>
Reply-To: bsegall-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <874minis1b.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org> (Eric W. Biederman's
	message of "Mon, 21 Sep 2015 12:46:56 -0500")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, ambrose-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman) writes:

> Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> writes:
>
>> On Wed, 16 Sep 2015 12:58:04 -0700 bsegall-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org wrote:
>>
>>> setpriority(PRIO_USER, 0, x) will change the priority of tasks outside
>>> of the current pid namespace. This is in contrast to both the other
>>> modes of setpriority and the example of kill(-1). Fix this. getpriority
>>> and ioprio have the same failure mode, fix them too.
>>
>> (cc Eric)
> (cc Containers)
>
> Interesting.  Strictly speaking the current behavior is not wrong.
> Searching for all threads with a given uid has nothing to do with pids
> so the pid namespace not limiting them is natural.
>
> In practice I don't think anyone cares either way (except people with
> one color or another of security hat on) so this might be a change we
> can actually make.
>
> In general it is probably better not to share uids and gids between
> containers.
>
> Ben do you have a use case where this actually matters?  Or was this a
> case of "That looks wrong..."?
>
> Eric

I believe we generally want this for isolation of a process, without
requiring root initially (and a non-trivial uid_map, not to mention
creating the extra users, requires root). There are probably other holes
in using namespaces like this, but are they intended?

(Cc the relevant team member at google)

>
>>> Signed-off-by: Ben Segall <bsegall-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
>>> Cc: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
>>> Cc: Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
>>> ---
>>>  block/ioprio.c | 6 ++++--
>>>  kernel/sys.c   | 4 ++--
>>>  2 files changed, 6 insertions(+), 4 deletions(-)
>>> 
>>> diff --git a/block/ioprio.c b/block/ioprio.c
>>> index 31666c9..cc7800e 100644
>>> --- a/block/ioprio.c
>>> +++ b/block/ioprio.c
>>> @@ -123,7 +123,8 @@ SYSCALL_DEFINE3(ioprio_set, int, which, int, who, int, ioprio)
>>>  				break;
>>>  
>>>  			do_each_thread(g, p) {
>>> -				if (!uid_eq(task_uid(p), uid))
>>> +				if (!uid_eq(task_uid(p), uid) ||
>>> +				    !task_pid_vnr(p))
>>>  					continue;
>>>  				ret = set_task_ioprio(p, ioprio);
>>>  				if (ret)
>>> @@ -220,7 +221,8 @@ SYSCALL_DEFINE2(ioprio_get, int, which, int, who)
>>>  				break;
>>>  
>>>  			do_each_thread(g, p) {
>>> -				if (!uid_eq(task_uid(p), user->uid))
>>> +				if (!uid_eq(task_uid(p), user->uid) ||
>>> +				    !task_pid_vnr(p))
>>>  					continue;
>>>  				tmpio = get_task_ioprio(p);
>>>  				if (tmpio < 0)
>>> diff --git a/kernel/sys.c b/kernel/sys.c
>>> index fa2f2f6..6af9212 100644
>>> --- a/kernel/sys.c
>>> +++ b/kernel/sys.c
>>> @@ -222,7 +222,7 @@ SYSCALL_DEFINE3(setpriority, int, which, int, who, int, niceval)
>>>  				goto out_unlock;	/* No processes for this user */
>>>  		}
>>>  		do_each_thread(g, p) {
>>> -			if (uid_eq(task_uid(p), uid))
>>> +			if (uid_eq(task_uid(p), uid) && task_pid_vnr(p))
>>>  				error = set_one_prio(p, niceval, error);
>>>  		} while_each_thread(g, p);
>>>  		if (!uid_eq(uid, cred->uid))
>>> @@ -290,7 +290,7 @@ SYSCALL_DEFINE2(getpriority, int, which, int, who)
>>>  				goto out_unlock;	/* No processes for this user */
>>>  		}
>>>  		do_each_thread(g, p) {
>>> -			if (uid_eq(task_uid(p), uid)) {
>>> +			if (uid_eq(task_uid(p), uid) && task_pid_vnr(p)) {
>>>  				niceval = nice_to_rlimit(task_nice(p));
>>>  				if (niceval > retval)
>>>  					retval = niceval;
>>> -- 
>>> 2.6.0.rc0.131.gf624c3d
>>> 
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
>>> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>> Please read the FAQ at  http://www.tux.org/lkml/
