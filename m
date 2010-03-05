From: Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [RFC][PATCH] ns: Syscalls for better namespace sharing control.
Date: Fri, 05 Mar 2010 22:18:13 +0300
Message-ID: <4B9158F5.5040205__49757.9842959114$1267816910$gmane$org@parallels.com>
References: <4B88E431.6040609@parallels.com>	<m1bpfbqajn.fsf@fess.ebiederm.org>
	<4B894564.7080104@parallels.com>	<m1iq9io5sc.fsf@fess.ebiederm.org>
	<4B89727C.9040602@parallels.com>	<m1ljeempk6.fsf@fess.ebiederm.org>
	<4B8AE8C1.1030305@free.fr>	<4B8D28CF.8060304@parallels.com>
	<20100302211942.GA17816@us.ibm.com>	<m1y6iaqsmm.fsf@fess.ebiederm.org>
	<20100303000743.GA13744@us.ibm.com>	<m1ocj6qljj.fsf@fess.ebiederm.org>
	<4B8E9370.3050300@parallels.com> <m17hptjh3m.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m17hptjh3m.fsf-+imSwln9KH6u2/kzUuoCbdi2O/JbrIOy@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Netfilter Development Mailinglist <netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
List-Id: containers.vger.kernel.org

> 2 parallel enters?  I meant you have pid 0 in the entered pid namespace.
> You have pid 0 because your pid simply does not map.

Oh, I see.

> There is nothing that makes to parallel enters impossible in that.
> Even today we have one thread per cpu that has task->pid == &init_struct_pid
> which is pid 0.

How about the forked processes then? Who will be their parent?

> For the case of unshare where we are designed to be used with PAM I don't
> think my proposed semantics work.  For a join needed an extra fork before
> you are really in the pid namespace should be minor.

Hm... One more proposal - can we adopt the planned new fork_with_pids system
call to fork the process right into a new pid namespace?

> That doesn't handle the case of cached struct pids.  A good example is
> waitpid, where it waits for a specific struct pid.  Which means that
> allocating a new struct pid and changing task->pid will cause
> waitpid(pid) to wait forever...

OK. Good example. Thanks.

> To change struct pid would require the refcount on struct pid to show
> no references from anywhere except the task_struct.

I think this is OK to return -EBUSY for this. And fix the waitpid
respectively not to block this common case. All the others I think
can be stayed as is.

> At the cost of a little memory we can solve that problem for unshare
> if we have a an extra upid in struct pid, how we verify there is space
> in struct pid I'm not certain.
> 
> I do think that at least until someone calls exec the namespace pids are
> reported to the process itself should not change.  That is kill and

Wait a second - in that case the wait will be blocked too! No?

> waitpid etc.  Which suggests an implementation the opposite of what
> I proposed.  With ns_of_pid(task_pid(current)) being used as the
> pid namespace of children, and current->nsproxy->pid_ns not changing
> in the case of unshare.
> 
> Shrug.
> 
> Or perhaps this is a case where we use we can implement join with
> an extra process but we can't implement unshare, because the effect
> cannot be immediate.

Well, I'm talking only about the join now.

> Eric
> 
