From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 6/7] proc: Introduce the /proc/<pid>/dump file
Date: Sat, 23 Jul 2011 10:58:40 +0200
Message-ID: <20110723085840.GJ21089@mtj.dyndns.org>
References: <4E204466.8010204@parallels.com> <4E204500.6040800@parallels.com>
	<20110721064408.GR3455@htj.dyndns.org>
	<4E2A8239.5060908@parallels.com>
	<20110723083711.GF21089@mtj.dyndns.org>
	<4E2A8B12.4010709@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4E2A8B12.4010709-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
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
Cc: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, Cyrill Gorcunov <gorcunov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Hello,

On Sat, Jul 23, 2011 at 12:49:22PM +0400, Pavel Emelyanov wrote:
> On 07/23/2011 12:37 PM, Tejun Heo wrote:
> > Just use ptrace.  Seizing all threads in a process, gather file and
> > memory map info from /proc, inject a parasite to dump memory pages and
> > do whatever else.  There's nothing special about TLS, fs/gs base is
> > already included in ptrace register dump in x86_64.  Dunno how it's
> > handled in 32bit but if it's not available exporting it isn't a big
> > deal.  Rebuilding the process image from the captured information
> > shouldn't be too hard.
> 
> You're talking about your recent set for ptrace? Can you propose a
> quick scratch of how you propose to dump and restore registers and
> memory with this?

Hmmm... I thought I just did that writing the above paragraph, so even
without the parasite treak, ptrace has access to full memory space and
registers of the tracee, so the basic stuff is already dumpable &&
restorable - at its simplest, dumper can PEEKDATA for each mapped
memory area (as indicated by /proc/PID/maps), use GETREGS and
GETFPREGS to acquire register states, save them.  To restore, launch a
process, attach to it, let it mmap all the recorded areas and fill it
from the saved data and SETREGS/SETFPREGS to restore the register
states and let go.

This of course is over-simplified but this should work.  There are
some missing things like finding out which signals are pending and
with what siginfo but those can be solved with small additions to
/proc.

Thanks.

-- 
tejun
