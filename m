From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [RFC][PATCH] ns: Syscalls for better namespace sharing control.
Date: Thu, 04 Mar 2010 13:45:23 -0800
Message-ID: <m1pr3j92x8.fsf__8766.42871085114$1267751431$gmane$org@fess.ebiederm.org>
References: <4B894564.7080104@parallels.com>
	<m1iq9io5sc.fsf@fess.ebiederm.org> <4B89727C.9040602@parallels.com>
	<m1ljeempk6.fsf@fess.ebiederm.org> <4B8AE8C1.1030305@free.fr>
	<4B8D28CF.8060304@parallels.com> <20100302211942.GA17816@us.ibm.com>
	<m1y6iaqsmm.fsf@fess.ebiederm.org> <20100303000743.GA13744@us.ibm.com>
	<m1ocj6qljj.fsf@fess.ebiederm.org> <20100303153800.GA937@us.ibm.com>
	<m13a0hmblr.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m13a0hmblr.fsf-+imSwln9KH6u2/kzUuoCbdi2O/JbrIOy@public.gmane.org> (Eric W. Biederman's message
	of "Wed\, 03 Mar 2010 11\:47\:12 -0800")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Netfilter Development Mailinglist <netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman) writes:

> "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> writes:
>
>> Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
>>> Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> writes:
>>> 
>>> > Eric W. Biederman [ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org] wrote:
>>> > | 
>>> > | I think replacing a struct pid for another struct pid allocated in
>>> > | descendant pid_namespace (but has all of the same struct upid values
>>> > | as the first struct pid) is a disastrous idea.  It destroys the
>>> >
>>> > True. Sorry, I did not mean we would need a new 'struct pid' for an
>>> > existing process. I think we talked earlier of finding a way of attaching
>>> > additional pid numbers to the same struct pid.
>>> 
>>> I just played with this and if you make the semantics of unshare(CLONE_NEWPID)
>>> to be that you become the idle task aka pid 0, and not the init task pid 1 the
>>> implementation is trivial.
>>
>> Heh, and then (browsing through your copy_process() patch hunks) the next
>> forked task becomes the child reaper for the new pidns?  <shrug>  why not
>> I guess.
>>
>> Now if that child reaper then gets killed, will the idle task get killed too?
>
> No.
>
>> And if not, then idle task can just re-populating the new pidns with new
>> idle tasks...
>
> After zap_pid_namespace interesting...
>
>> If this brought us a step closer to entering an existing pidns that would
>> be one thing, but is there actually any advantage to being able to
>> unshare a new pidns?  Oh, I guess there is - PAM can then use it at
>> login, which might be neat.
>
> I have to say that the semantics of my patch are unworkable for
> unshare.  Unless I am mistaken for PAM to use it requires that the
> current process fully change and become what it needs to be.
> Requiring an extra fork to fully complete the process is a problem.
>
> Scratch one bright idea.

Maybe not.  I just looked and in the vast majority of cases the login
process goes like this.

{
	setup stuff include pam
	child = fork();
	if (!child) {
		setuid()
                exec /bin/bash
        }
        waitpid(child);
        
        pam and other cleanup
}

So an unshare of the pid namespace that doesn't really take effect
until we fork may actually be usable from pam, and in fact is probably
the preferred implementation.  It looks like neither openssh nor login
from util-linux-ng will cope properly with getting any pid back from
wait() except the pid of their child.  It looks like they both with
terminate.  Which means if you login in a new pid namespace (where the
unsharing process becomes pid 1) and call nohup everything will get
killed and you will be logged out.

Eric
