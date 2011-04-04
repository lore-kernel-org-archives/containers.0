From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 05/10] Core checkpoint/restart support code
Date: Mon, 04 Apr 2011 16:43:29 -0500
Message-ID: <1301953409.31531.130.camel__13844.313476193$1301954019$gmane$org@tp-t61>
References: <1298936432-29607-1-git-send-email-ntl@pobox.com>
	<1298936432-29607-6-git-send-email-ntl@pobox.com>
	<20110403190324.GD15044@hallyn.com> <1301929228.31531.39.camel@tp-t61>
	<20110404151017.GA4857@hallyn.com> <1301931608.31531.49.camel@tp-t61>
	<20110404162753.GA3456@hallyn.com> <4D9A00B1.2080002@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4D9A00B1.2080002-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, 2011-04-04 at 13:32 -0400, Oren Laadan wrote:
> From the technical point of view it *is* a big problem:  there are
> very good reasons why we chose a certain design. 
> 
> If Natahan is suggesting in-kernel tree creation as a temporary thing
> to simplify the code for review - then, given that this patch handles
> a single process, doing so add lots of unnecessary code, all of which
> in the kernel.
> 
> If this is the beginning of a permanent approach, then it is totally
> incompatible with what we have done so far, and severely restricts 
> the kind of use--cases of the project, potentially making it too
> unattractive for many natural adaptors, like HPC users. Sorry, nack.

It's not a stopgap measure to "ease review" or whatever; recreating the
task tree in-kernel is a fundamental - and simplifying - part of the
design.  I have earned through painful experience the opinion that
recreating the task tree in userspace is pretty much insane, as is
exposing the pid allocator to userspace via eclone(2), as is attempting
to support c/r of any resource that isn't isolated/virtualized, as is
having every recreated task "rendezvous" in the kernel by having them
all call restart(2), even though little significant work can be done in
parallel.

Time to try something different.

I don't see anything about in-kernel task tree creation that would
interfere with real-world use cases.
