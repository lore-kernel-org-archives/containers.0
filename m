From: Nathan Lynch <ntl@pobox.com>
Subject: Re: [PATCH 1/3] powerpc: bare minimum checkpoint/restart
	implementation
Date: Mon, 16 Mar 2009 13:37:45 -0500
Message-ID: <20090316133745.4f636979@thinkcentre.lan>
References: <1233182478-27113-1-git-send-email-ntl@pobox.com>
	<1233182478-27113-2-git-send-email-ntl@pobox.com>
	<49814FA2.9060108@cs.columbia.edu> <20090129214035.GB6913@localdomain>
	<20090217010355.58afd5cf@thinkcentre.lan>
	<49B9D37A.1070503@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org>
In-Reply-To: <49B9D37A.1070503@cs.columbia.edu>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
To: Oren Laadan <orenl@cs.columbia.edu>
Cc: containers@lists.osdl.org, linuxppc-dev@ozlabs.org
List-Id: containers.vger.kernel.org

Oren Laadan <orenl@cs.columbia.edu> wrote:
> 
> Nathan Lynch wrote:
> > Nathan Lynch <ntl@pobox.com> wrote:
> >> Oren Laadan wrote:
> >>> Nathan Lynch wrote:
> >>>> What doesn't work:
> >>>> * restarting a 32-bit task from a 64-bit task and vice versa
> >>> Is there a test to bail if we attempt to checkpoint such tasks ?
> >> No, but I'll add one if it looks too hard to fix for the next round.
> > 
> > Unfortunately, adding a check for this is hard.
> > 
> > The "point of no return" in the restart path is cr_read_mm, which tears
> > down current's address space.  cr_read_mm runs way before cr_read_cpu,
> > which is the only restart method I've implemented for powerpc so far.
> > So, checking for this condition in cr_read_cpu is too late if I want
> > restart(2) to return an error and leave the caller's memory map
> > intact.  (And I do want this: restart should be as robust as execve.)
> 
> In the case of restarting a container, I think it's ok if a restarting
> tasks dies in an "ugly" way -- this will be observed and handled by the
> initiating task outside the container, which will gracefully report to
> the caller/user.

How would task exit be observed?  Are all tasks in a restarted
container guaranteed to be children (in the sense that wait(2) would
work) of the initiating task?


> Even if you close this hole, then any other failure later on during
> restart - even a failure to allocate kernel memory due to memory pressure,
> will give that undesired effect that you are trying to avoid.

Kernel memory allocation failure is not the kind of problem I'm trying
to address.  I am trying to address the case of restarting a checkpoint
image that needs features that are not present, where the set of
features used by the checkpoint image can be compared against the set
of features the platform provides.


> That said, any difference in the architecture that may cause restart to
> fail is probably best placed in cr_write_head_arch.

I think I explained in my earlier mail why the current implementation's
cr_write_head_arch doesn't help in this case:

> > Well okay then, cr_read_head_arch seems to be the right place in the
> > restart sequence for the architecture code to handle this.  However,
> > cr_write_head_arch (which produces the buffer that cr_read_head_arch
> > consumes) is not provided a reference to the task to be checkpointed,
> > nor can it assume that it's operating on current.  I need a reference
> > to a task before I can determine whether it's running in 32- or 64-bit
> > mode, or using the FPU, Altivec, SPE, whatever.
> > 
> > In any case, mixing 32- and 64-bit tasks across restart is something I
> > eventually want to support, not reject.  But the problem I've outlined
> > applies to FPU state and vector extensions (VMX, SPE), as well as
> > sanity-checking debug register (DABR) contents.  We'll need to be able
> > to error out gracefully from restart when a checkpoint image specifies a
> > feature unsupported by the current kernel or hardware.  But I don't see
> > how to do it with the current architecture.  Am I missing something?
> > 
> 
> More specifically, I envision restart to work like this:
> 
> 1) user invokes user-land utility (e.g. "cr --restart ..."
> 2) 'cr' will create a new container
> 3) 'cr' will start a child in that container
> 4) child will create rest of tree (in kernel or in user space - tbd)
> 5) each task in that tree will restore itself
> 6) 'cr' monitors this process
> 7) if all goes well - 'cr' report ok.
> 8) if something goes bad, 'cr' notices and notifies caller/user

Again, how would 'cr' obtain exit status for these tasks, and how would
it distinguish failure from normal operation?
