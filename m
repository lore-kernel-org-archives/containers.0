From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/1] cr: define CHECKPOINT_SUBTREE flag and sysctl
Date: Mon, 27 Apr 2009 14:30:53 -0500
Message-ID: <20090427193052.GA30080@us.ibm.com>
References: <20090424210608.GA16973@us.ibm.com> <m3vdotk34g.fsf@pobox.com>
	<20090425024515.GA4534@hallyn.com> <m3y6tmt3wb.fsf@pobox.com>
	<20090427180717.GA28476@us.ibm.com>
	<20090427190947.GA14148@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090427190947.GA14148-2ev+ksY9ol182hYKe6nXyg@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Alexey Dobriyan (adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org):
> On Mon, Apr 27, 2009 at 01:07:17PM -0500, Serge E. Hallyn wrote:
> > Heh, because there is no such thing as a 'container'.
> 
> Oh, yes, there is.
> 
> Set of tasks shares set of uts_ns, ipc_ns, mnt_ns, pid_ns and net_ns.
> No other task shares this set.
> Pid_ns set has tree hierarchy.
> All user_ns which come from credentials of set of tasks aren't shared
> with other tasks.
> 
> Such set of tasks logically forms a container.

Sure, that definition makes sense, but so do the other existing
uses of the term.  You can hijack already-overloaded terms if you want,
but it's not wise, and will hamper communications when everyone reads
something different into your message.

You don't mention the freezer control group (or any of the others).
Your patchset has the kernel freeze the tasks for the duration of the
checkpoint, but that's one aspect of your patchset which, while
convenient, is imo hard to really justify not doing in user-space.

> > There is a set of tasks in the same freezer control group, and it's
> > possible that there is a task not in that cgroup which is in the same
> > utsname as the rest of the tasks in that freezer cgroup.
