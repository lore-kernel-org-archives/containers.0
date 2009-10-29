From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] c/r: tolerate X86_EFLAGS_RF on restart
Date: Thu, 29 Oct 2009 09:31:25 -0500
Message-ID: <20091029143125.GE15713@us.ibm.com>
References: <1256323024-20268-1-git-send-email-orenl@librato.com>
	<20091026145746.GA23564@us.ibm.com> <4AE8EDC4.5010202@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4AE8EDC4.5010202-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Avi Kivity <avi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org):
> 
> After reading the code a bit more, and seeing that:
> 
> 1) ptrace uses the debugreg of a process so may be interested in
> that particular flag, and
> 
> 2) even without ptrace userspace can set that flag (by suitably
> setting the restore context from a signal handler)
> 
> I now think that we should instead:
> 
> 1) Keep the X86_EFLAGS_RF from the time of checkpoint *as is*
> 
> 2) If the restarting task already has this flag set prior to
> restoring eflags from the saved value, then preserve the existing
> flag even if at the time of checkpoint it wasn't set.
> 
> Unless someones yells, I'll commit this soon.

As it stands (looking at arch/x86/kernel/ptrace.c) it looks like
userspace with no privilege can set the bit right?  I think your
proposal sounds best.

-serge
