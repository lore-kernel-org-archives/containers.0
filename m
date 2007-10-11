From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH] task containersv11 add tasks file interface fix for
	cpusets
Date: Thu, 11 Oct 2007 17:20:43 -0600
Message-ID: <m13awhb5mc.fsf@ebiederm.dsl.xmission.com>
References: <20071003084241.24279.62099.sendpatchset@jackhammer.engr.sgi.com>
	<6599ad830710030851jb44f00ft9634f9381218b6e9@mail.gmail.com>
	<20071003105817.7adf6516.pj@sgi.com>
	<6599ad830710031110r1a74eafej56f20cc33e72ac81@mail.gmail.com>
	<20071003131632.fed4b848.pj@sgi.com>
	<6599ad830710031331h15d35e90lc63d845efd2de6f5@mail.gmail.com>
	<20071006012437.c0fd3a8a.pj@sgi.com>
	<alpine.DEB.0.9999.0710061047400.24311@chino.kir.corp.google.com>
	<20071006125904.a26ed99f.pj@sgi.com>
	<6599ad830710061409p2dcaa1c8u8c6864beaaafb149@mail.gmail.com>
	<20071011150315.78c4f45f.pj@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20071011150315.78c4f45f.pj-sJ/iWh9BUns@public.gmane.org> (Paul Jackson's message of
	"Thu, 11 Oct 2007 15:03:15 -0700")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Jackson <pj-sJ/iWh9BUns@public.gmane.org>
Cc: nickpiggin-/E1597aS9LT0CCvOHzKKcA@public.gmane.org, a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org, rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org


Stupid question.

Would it help at all if we structured this as:
- Take the control group off of the cpus and runqueues.
- Modify the tasks in the control group.
- Place the control group back on the runqueues.

Essentially this is what ptrace does (except for one task at a time).

Since we know that the tasks are not running, and that we have
exclusive access to the tasks in the control group we can take action
as if we were the actual tasks themselves.  Which should simplify
locking.

So I think with just a touch of care we can significantly simplify the
locking by being much more coarse grained, at the expense of this kind
of control group operation being more expensive.  Plus we would have
an operation that was reusable.

I think the stop everything.  modify everything, start everything
could also be used instead of an array of task structures.

Eric
