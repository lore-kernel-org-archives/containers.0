From: Srivatsa Vaddagiri <vatsa-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: Revert for cgroups CPU accounting subsystem patch
Date: Tue, 13 Nov 2007 13:29:46 +0530
Message-ID: <20071113075946.GA14731__12227.5758105845$1194940109$gmane$org@linux.vnet.ibm.com>
References: <6599ad830711122125u576e85a6w428466a0ab46dbc6@mail.gmail.com>
	<20071113060038.GC3359@linux.vnet.ibm.com>
	<6599ad830711122205g88aae4fua8dd76cf6e8ab84d@mail.gmail.com>
	<47394B84.8030008@linux.vnet.ibm.com>
	<6599ad830711122310nf7530cfs5ef1fea061b1252c@mail.gmail.com>
	<47395277.1060006@linux.vnet.ibm.com>
Reply-To: vatsa-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <47395277.1060006-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Nov 13, 2007 at 12:59:59PM +0530, Balbir Singh wrote:
> Paul Menage wrote:
> > On Nov 12, 2007 11:00 PM, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:
> >> Right now, one of the limitations of the CPU controller is that
> >> the moment you create another control group, the bandwidth gets
> >> divided by the default number of shares. We can't create groups
> >> just for monitoring.
> > 
> > Could we get around this with, say, a flag that always treats a CFS
> > schedulable entity as having a weight equal to the number of runnable
> > tasks in it? So CPU bandwidth would be shared between groups in
> > proportion to the number of runnable tasks, which would distribute the
> > cycles approximately equivalently to them all being separate
> > schedulable entities.
> > 
> 
> I think it's a good hack, but not sure about the complexity to implement
> the code.

I agree that it would be adding unnecessary complexity, just to meet the
accounting needs.

Thinking of it more, this requirement to "group tasks for only accounting
purpose" may be required for other resources (mem, io, network etc) as well?
Should we have a generic accounting controller which can provide these
various resource usgae stats for a group (cpu, mem etc) by iterating thr' the 
task list for the group and summing up the corresponding stats already present 
in task structure?

-- 
Regards,
vatsa
