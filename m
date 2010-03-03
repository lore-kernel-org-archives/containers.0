From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [RFC][PATCH] ns: Syscalls for better namespace sharing control.
Date: Wed, 03 Mar 2010 12:16:45 -0800
Message-ID: <m17hptjh3m.fsf__47547.9097840891$1267647453$gmane$org@fess.ebiederm.org>
References: <4B88E431.6040609@parallels.com>
	<m1bpfbqajn.fsf@fess.ebiederm.org> <4B894564.7080104@parallels.com>
	<m1iq9io5sc.fsf@fess.ebiederm.org> <4B89727C.9040602@parallels.com>
	<m1ljeempk6.fsf@fess.ebiederm.org> <4B8AE8C1.1030305@free.fr>
	<4B8D28CF.8060304@parallels.com> <20100302211942.GA17816@us.ibm.com>
	<m1y6iaqsmm.fsf@fess.ebiederm.org> <20100303000743.GA13744@us.ibm.com>
	<m1ocj6qljj.fsf@fess.ebiederm.org> <4B8E9370.3050300@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4B8E9370.3050300-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org> (Pavel Emelyanov's message of
	"Wed\, 03 Mar 2010 19\:50\:56 +0300")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Cc: Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Netfilter Development Mailinglist <netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org> writes:

>> I just played with this and if you make the semantics of unshare(CLONE_NEWPID)
>> to be that you become the idle task aka pid 0, and not the init task pid 1 the
>> implementation is trivial.
>
> This is not ... handy - if after enter you have pid 0 you obviously
> can't perform 2 parallel enters.

2 parallel enters?  I meant you have pid 0 in the entered pid namespace.
You have pid 0 because your pid simply does not map.

There is nothing that makes to parallel enters impossible in that.
Even today we have one thread per cpu that has task->pid == &init_struct_pid
which is pid 0.

For the case of unshare where we are designed to be used with PAM I don't
think my proposed semantics work.  For a join needed an extra fork before
you are really in the pid namespace should be minor.

> The way I see it:
>
> As far as the numbers reported to the userspace are concerned:
> 1. task, that enters is still visible by its old parent by old pid
> 2. task, that enters gets some pid within the entering namespace
>    and reports its parent pid to have pid 1 (init obviously doesn't
>    care)
> 3. we _can_ try to allocate new pid equal to the old one so that
>    glibc stays happy
>
>
> As far as the pointers are concerned:
> 1. parent pointer doesn't change
> 2. task_pid(tsk) one (i.e. struct pid * one) _can_ change if
>    a) we don't allow threads enter (de_thread problem is handeled)
>    b) we don't allow leave the group/session, i.e. check, that there
>       is the only one task that enters lives in its pgid/sid
>    c) we wait for the quiescent state to pass by before destroying
>       the old pid to handle race with sys_kill()

That doesn't handle the case of cached struct pids.  A good example is
waitpid, where it waits for a specific struct pid.  Which means that
allocating a new struct pid and changing task->pid will cause
waitpid(pid) to wait forever...

To change struct pid would require the refcount on struct pid to show
no references from anywhere except the task_struct.

At the cost of a little memory we can solve that problem for unshare
if we have a an extra upid in struct pid, how we verify there is space
in struct pid I'm not certain.

I do think that at least until someone calls exec the namespace pids are
reported to the process itself should not change.  That is kill and
waitpid etc.  Which suggests an implementation the opposite of what
I proposed.  With ns_of_pid(task_pid(current)) being used as the
pid namespace of children, and current->nsproxy->pid_ns not changing
in the case of unshare.

Shrug.

Or perhaps this is a case where we use we can implement join with
an extra process but we can't implement unshare, because the effect
cannot be immediate.

Eric
