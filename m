From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: [RFC][v6][PATCH 8/9]: Define clone_with_pids() syscall
Date: Fri, 11 Sep 2009 13:12:27 +0200
Message-ID: <200909111312.27497.arnd__49576.5787586153$1252667818$gmane$org@arndb.de>
References: <20090910060627.GA24343@us.ibm.com>
	<200909111231.30495.arnd@arndb.de>
	<20090911110056.GA12824@hawkmoon.kerlabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090911110056.GA12824-Hu8+6S1rdjywhHL9vcZdMVaTQe2KTcn/@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Louis Rilling <Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Nathan Lynch <nathanl-V7BBcbaFuwjMbYB6QlFGEg@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

On Friday 11 September 2009, Louis Rilling wrote:
> On 11/09/09 12:31 +0200, Arnd Bergmann wrote:
> > On Thursday 10 September 2009, Sukadev Bhattiprolu wrote:
> > > Since this is a variant of clone() and clone is listed as a PTREGSCALL(),
> > > I pass in the pt_regs.
> > > 
> > > arch/x86/kernel/entry_32.S lists clone() under this comment:
> > > 
> > > /*
> > >  * System calls that need a pt_regs pointer.
> > >  */
> > > 
> > > Is there a guideline on what system calls use/need pt_regs ?
> > 
> > You need pt_regs if you access any registers from the user task
> > other than the argument registers. In case of clone(), this is
> > the user stack pointer.
> 
> AFAICS clone() actually needs all registers (see x86 copy_thread() for
> instance). Any variant of clone() will have this requirement.

Right, but that part (do_fork) is already handled in common code, which
function calls into architecture specific code.

The point I was making is that the sys_clone() and sys_clone_with_pids()
functions themselves only access the argument registers, the stack
pointer and pass those down to do_fork, along with pt_regs.

	Arnd <><
