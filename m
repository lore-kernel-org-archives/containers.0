From: Greg Kurz <gkurz-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: [Devel] Re: [PATCH 08/10] Introduce functions to restart a process
Date: Wed, 22 Oct 2008 14:44:15 +0200
Message-ID: <1224679455.4210.24.camel__29037.1138988577$1224679697$gmane$org@localhost.localdomain>
References: <1224285098-573-1-git-send-email-major@openvz.org>
	<1224285098-573-9-git-send-email-major@openvz.org>
	<48FC4E0C.7050008@fr.ibm.com> <200810221249.55600.major@openvz.org>
	<20081022092502.GW15171@hawkmoon.kerlabs.com>
	<1224669979.4210.15.camel@localhost.localdomain>
	<20081022104448.GX15171@hawkmoon.kerlabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20081022104448.GX15171-Hu8+6S1rdjywhHL9vcZdMVaTQe2KTcn/@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, 2008-10-22 at 12:44 +0200, Louis Rilling wrote:
> On Wed, Oct 22, 2008 at 12:06:19PM +0200, Greg Kurz wrote:
> > On Wed, 2008-10-22 at 11:25 +0200, Louis Rilling wrote:
> > > Do you checkpoint uninterruptible syscalls as well? If only interruptible
> > > syscalls are checkpointed, I'd say that either this syscall uses ERESTARTSYS or
> > > ERESTART_RESTARTBLOCK, and then signal handling code already does the trick, or
> > > this syscall does not restart itself when interrupted, and well, this is life,
> > > userspace just sees -EINTR, which is allowed by the syscall spec.
> > > Actually this is how we checkpoint/migrate tasks in interruptible syscalls in
> > > Kerrighed and this works.
> > > 
> > > Louis
> > > 
> > 
> > I don't know Kerrighed internals but I understand you perform checkpoint
> > with a signal handler. Right ?
> 
> Right. This is an kernel-internal-only signal, so all signals remain available
> for userspace.
> 
> > This approach has a huge benefit: the
> > signal handling code do all the arch dependant stuff to save registers
> > in user memory.
> 
> Hm, I'm not sure to understand what you mean here. We just rely on arch code
> that jumps to signal handling to correctly setup struct pt_regs, which is then
> passed to the checkpoint code. So yes, userspace registers are mostly saved by
> existing arch code. But in x86-64 for instance, segment registers still need to
> be saved by the checkpoint code (a bit like copy_thread() does), and I don't
> know arch-independent functions doing this.
> 

You're right, some segment registers need to be saved on x86 also... I
should have written 'most of' in my previous mail.

-- 
Gregory Kurz                                     gkurz-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org
Software Engineer @ IBM/Meiosys                  http://www.ibm.com
Tel +33 (0)534 638 479                           Fax +33 (0)561 400 420

"Anarchy is about taking complete responsibility for yourself."
        Alan Moore.
