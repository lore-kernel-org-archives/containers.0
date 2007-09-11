From: Randy Dunlap <randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] Hookup group-scheduler with task container
 infrastructure
Date: Tue, 11 Sep 2007 08:22:43 -0700
Message-ID: <20070911082243.9433c528.randy.dunlap@oracle.com>
References: <20070910171049.GA16048@linux.vnet.ibm.com>
	<Pine.LNX.4.64.0709101903220.5368@fbirervta.pbzchgretzou.qr>
	<20070910172334.GB19100@linux.vnet.ibm.com>
	<20070910102259.dc45a481.akpm@linux-foundation.org>
	<20070910174649.GA16222@linux.vnet.ibm.com>
	<b647ffbd0709101537l9af4dc8x743b25c96e0f5235@mail.gmail.com>
	<6599ad830709101545s66fd338dob6932407db4e1002@mail.gmail.com>
	<46E641C1.8000808@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <46E641C1.8000808-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: ckrm-tech-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, vatsa-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, Jan Engelhardt <jengelh-bdq14YP6qtRlEiWPh9xO2Q@public.gmane.org>, Dmitry Adamushko <dmitry.adamushko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, 11 Sep 2007 09:20:33 +0200 Cedric Le Goater wrote:

> Paul Menage wrote:
> > On 9/10/07, Dmitry Adamushko <dmitry.adamushko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> >> On 10/09/2007, Srivatsa Vaddagiri <vatsa-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:
> >>> On Mon, Sep 10, 2007 at 10:22:59AM -0700, Andrew Morton wrote:
> >>>> objection ;)  "cpuctlr" isn't memorable.  Kernel code is write-rarely,
> >>>> read-often.  "cpu_controller", please.  The extra typing is worth it ;)
> >>> Ok! Here's the modified patch (against 2.6.23-rc4-mm1).
> >> as everyone seems to be in a quest for a better name... I think, the
> >> obvious one would be just 'group_sched'.
> >>
> > 
> > But "sched" on its own could refer to CPU scheduling, I/O scheduling,
> > network scheduling, ...
> > 
> > And "group" is more or less implied by the fact that it's in the
> > containers/control groups filesystem.
> 
> "control groups" is the name of your framework. right ?
> 
> > So "group_sched" isn't really all that informative. The name should
> > definitely contain either "cpu" or "cfs".
> 
> "cfs" control group subsystem.

That looks odd, like it's a filesystem.
What does cfs really mean?


> "cfs" looks good enough to identify the subsystem.


---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
