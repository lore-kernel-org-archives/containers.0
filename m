From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 00/30] C/R OpenVZ/Virtuozzo style
Date: Tue, 14 Apr 2009 01:46:36 -0400
Message-ID: <49E4233C.3000108@cs.columbia.edu>
References: <20090410023207.GA27788@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090410023207.GA27788-2ev+ksY9ol182hYKe6nXyg@public.gmane.org>
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
Cc: xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org
List-Id: containers.vger.kernel.org


Some meta comments about this patch set:

* Patches 1-9 are cleanups, unrelated to checkpoint/restart. They
deserve a separate thread.

* You barely take locks or reference counts to objects that you
later refer to. What if something really bad happens ?

* (contd) If you don't take locks, then you at the very least need
to rely on the container remaining frozen for the duration of the
operation (during checkpoint).

* (contd) Still with locks and references, during restart you can't
even freeze the container, so need extra logic to prevent bad things
(e.g. OOM killer, signal or ptrace from parent container etc).

* What is the rationale behind doing the freeze/unfreeze from within
sys_checkpoint/sys_restart ?   Instead of you let userspace do it
(and only verify in kernel) you gain, again, flexibility. For example,
you want to also snapshot the filesystem, then userspace will do
something like:  freeze container -> snapshot filesystem -> checkpoint
-> thaw container.

* A plethora of "FIXME" comments ...

Alexey Dobriyan wrote:
> This is to show how we see C/R and to provoke discussion on number of
> important issues (mounts, ...).

Quoting your patch:
---
This is one big FIXME:
	What to do with overmounted files?
	What to do with mounts at all, who should restore them?

just restore something to not oops on task exit
---

> 
> This is small part of long-awaited to be cleanuped code.
> 
> It's able to restore busyloop on i386 and x86_64 and restore i386
> busyloop on x86_64. It wasn't tested much more than that.

Oh .. I really wish you'd sent a x86_64 patch our way, too ;)

> 
> I'm currently starting formal testsuite, otherwise it's whack-a-mole
> game and formal TODO list (a huge one).
> 

So I'm still struggling to see the major different in the approaches
that would justify throwing away our hard worked, reviewed, tested
and functional code, and take this - similar in design, largely
incomplete and unreviewed code.

Best,

Oren.
