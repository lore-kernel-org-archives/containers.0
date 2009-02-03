From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/1] c/r: define s390-specific checkpoint-restart code (v3)
Date: Tue, 3 Feb 2009 13:42:21 -0600
Message-ID: <20090203194221.GA21416@us.ibm.com>
References: <20090203161223.GA17998@us.ibm.com>
	<4988961A.2080101@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4988961A.2080101-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>, schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org, linux390-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> 
> 
> Serge E. Hallyn wrote:
> > Implement the s390 arch-specific checkpoint/restart helpers.  This
> > is on top of Oren Laadan's c/r code.
> > 
> > With these, I am able to checkpoint and restart simple
> > programs as per Oren's patch intro.  While on x86 I never had
> > to freeze a single task to checkpoint it, on s390 I do need
> > to.  That is a prereq for consistent snapshots (esp with
> > multiple processes) anyway so I don't see that as a problem.
> > 
> > I'm having a strange problem with libraries though.  If I link a
> > program with some extra libraries (-lm, -lcrypt, -lpthread,
> > whatever), then after restart, if I do a fprintf("%f), the program
> > segfaults.  Not linking with extra libraries beside libc, or not
> > doing a fprintf of a float, doesn't cause any segfaults after
> > restart.  ltrace and strace aren't helpful, and gdb says
> > that the restarted program faulted at __printf_fp@@GLIBC2.4.
> > objdump -d output shows no difference (of course, since this
> > is after linking), but mentions a __dso_handle which doesn't
> > look familiar compared to x86 output.  /proc/$$/maps looks
> > the same on original and restarted task too.  So I'm
> > flummoxed.
> 
> You can try to force a core-dump of memory contents (and registers)
> at the end of the checkpoint and just before resuming to user space
> in the restart. Then compare the two. This technique proved invaluable
> to debug c/r issues.

Good idea, will try that, thanks.

-serge
