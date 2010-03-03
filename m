From: Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [RFC][PATCH] ns: Syscalls for better namespace sharing control.
Date: Wed, 03 Mar 2010 19:50:56 +0300
Message-ID: <4B8E9370.3050300__41005.9615424418$1267635604$gmane$org@parallels.com>
References: <4B88E431.6040609@parallels.com>	<m1bpfbqajn.fsf@fess.ebiederm.org>
	<4B894564.7080104@parallels.com>	<m1iq9io5sc.fsf@fess.ebiederm.org>
	<4B89727C.9040602@parallels.com>	<m1ljeempk6.fsf@fess.ebiederm.org>
	<4B8AE8C1.1030305@free.fr>	<4B8D28CF.8060304@parallels.com>
	<20100302211942.GA17816@us.ibm.com>	<m1y6iaqsmm.fsf@fess.ebiederm.org>
	<20100303000743.GA13744@us.ibm.com>
	<m1ocj6qljj.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m1ocj6qljj.fsf-+imSwln9KH6u2/kzUuoCbdi2O/JbrIOy@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>, Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Netfilter Development Mailinglist <netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
List-Id: containers.vger.kernel.org

> I just played with this and if you make the semantics of unshare(CLONE_NEWPID)
> to be that you become the idle task aka pid 0, and not the init task pid 1 the
> implementation is trivial.

This is not ... handy - if after enter you have pid 0 you obviously
can't perform 2 parallel enters. The way I see it:

As far as the numbers reported to the userspace are concerned:
1. task, that enters is still visible by its old parent by old pid
2. task, that enters gets some pid within the entering namespace
   and reports its parent pid to have pid 1 (init obviously doesn't
   care)
3. we _can_ try to allocate new pid equal to the old one so that
   glibc stays happy


As far as the pointers are concerned:
1. parent pointer doesn't change
2. task_pid(tsk) one (i.e. struct pid * one) _can_ change if
   a) we don't allow threads enter (de_thread problem is handeled)
   b) we don't allow leave the group/session, i.e. check, that there
      is the only one task that enters lives in its pgid/sid
   c) we wait for the quiescent state to pass by before destroying
      the old pid to handle race with sys_kill()

Thoughts/questions? ("This is a nasty problem" answer is not acceptable,
the real code problems/races please)
