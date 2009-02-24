From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 1/3] powerpc: bare minimum checkpoint/restart
	implementation
Date: Tue, 24 Feb 2009 13:58:26 -0600
Message-ID: <20090224195826.GA25909@us.ibm.com>
References: <1233182478-27113-1-git-send-email-ntl@pobox.com>
	<1233182478-27113-2-git-send-email-ntl@pobox.com>
	<49814FA2.9060108@cs.columbia.edu>
	<20090129214035.GB6913@localdomain>
	<20090217010355.58afd5cf@thinkcentre.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org>
Content-Disposition: inline
In-Reply-To: <20090217010355.58afd5cf@thinkcentre.lan>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
To: Nathan Lynch <ntl@pobox.com>
Cc: containers@lists.osdl.org, Oren Laadan <orenl@cs.columbia.edu>, linuxppc-dev@ozlabs.org
List-Id: containers.vger.kernel.org

Quoting Nathan Lynch (ntl@pobox.com):
> Nathan Lynch <ntl@pobox.com> wrote:
> >
> > Oren Laadan wrote:
> > > 
> > > Nathan Lynch wrote:
> > > > 
> > > > What doesn't work:
> > > > * restarting a 32-bit task from a 64-bit task and vice versa
> > > 
> > > Is there a test to bail if we attempt to checkpoint such tasks ?
> > 
> > No, but I'll add one if it looks too hard to fix for the next round.
> 
> Unfortunately, adding a check for this is hard.
> 
> The "point of no return" in the restart path is cr_read_mm, which tears
> down current's address space.  cr_read_mm runs way before cr_read_cpu,
> which is the only restart method I've implemented for powerpc so far.
> So, checking for this condition in cr_read_cpu is too late if I want
> restart(2) to return an error and leave the caller's memory map
> intact.  (And I do want this: restart should be as robust as execve.)
> 
> Well okay then, cr_read_head_arch seems to be the right place in the
> restart sequence for the architecture code to handle this.  However,
> cr_write_head_arch (which produces the buffer that cr_read_head_arch
> consumes) is not provided a reference to the task to be checkpointed,
> nor can it assume that it's operating on current.  I need a reference
> to a task before I can determine whether it's running in 32- or 64-bit
> mode, or using the FPU, Altivec, SPE, whatever.
> 
> In any case, mixing 32- and 64-bit tasks across restart is something I
> eventually want to support, not reject.  But the problem I've outlined
> applies to FPU state and vector extensions (VMX, SPE), as well as
> sanity-checking debug register (DABR) contents.  We'll need to be able
> to error out gracefully from restart when a checkpoint image specifies a
> feature unsupported by the current kernel or hardware.  But I don't see
> how to do it with the current architecture.  Am I missing something?

I suspect I can guess the response to this suggestion, but how about we
accept that if sys_restart() fails due to something like this, the
task is lost and can't exit gracefully?  The end-user can then run
a user-space program to run through the checkpoint image ahead of
time (if they want) and verify whether restart can be expected to
succeed on the current hardware and os version?

If a minor difference is detected, the user-space program might
simply rewrite (a copy of) the checkpoint image into one which can
in fact succeed.

-serge
