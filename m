From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: build breaks when checkpoint unimplemented by arch
Date: Tue, 7 Jul 2009 10:59:43 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0907071058340.24765@takamine.ncl.cs.columbia.edu>
References: <m3my7hv7w8.fsf@pobox.com>
	<Pine.LNX.4.64.0907061902530.15941@takamine.ncl.cs.columbia.edu>
	<m3bpnxv03k.fsf@pobox.com>
	<Pine.LNX.4.64.0907070039360.22105@takamine.ncl.cs.columbia.edu>
	<20090707133335.GA7686@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090707133335.GA7686-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, 7 Jul 2009, Serge E. Hallyn wrote:

> Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> > On Mon, 6 Jul 2009, Nathan Lynch wrote:
> > 
> > > Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org> writes:
> > > 
> > > > On Mon, 6 Jul 2009, Nathan Lynch wrote:
> > > >
> > > >> Hi Oren,
> > > >> 
> > > >> With ckpt-v17-rc1 (as well as ckpt-v16-dev) the powerpc build is broken:
> > > >> 
> > > >> In file included from include/linux/checkpoint.h:28,
> > > >>                  from kernel/exit.c:53:
> > > >> include/linux/checkpoint_hdr.h:42:32: error: asm/checkpoint_hdr.h: No such file or directory
> > > >> In file included from include/linux/checkpoint.h:28,
> > > >>                  from kernel/exit.c:53:
> > > >> include/linux/checkpoint_hdr.h:410: error: 'CKPT_ARCH_NSIG' undeclared here (not in a function)
> > > >> make[1]: *** [kernel/exit.o] Error 1
> > > >> 
> > > >> 
> > > >> It appears that any architecture which does not supply
> > > >> asm/checkpoint_hdr.h is broken in the same way.
> > > >> 
> > > >> Either all architectures need to supply asm/checkpoint_hdr.h (and define
> > > >> CKPT_ARCH_NSIG), or there needs to be some other fix which allows
> > > >> as-yet-unsupported arches to build..
> > > >> 
> > > >
> > > > I see... well - maybe it's time to resend the powerpc port :p
> > > 
> > > I'm working on that, but the powerpc port won't be of any help to the
> > > twenty-odd other architectures that are broken.
> > > 
> > 
> > [...]
> > 
> > That's what I tried initially, but the problem is that sigset_t may
> > be defined differently for userspace - see /usr/include/asm/sigset_t.h.
> > In fact, for x86_32, it it is different, defined as 'unsigned long' 
> > (and NSIG defined as 32, so only 32 bits).
> > 
> > Moreover, if you include <asm/sigset.h> in checkpoint_hdr.h, which is
> > also included by userspace, you get lots of compilations warnings,
> > because of other stuff included from the kernel's asm/sigset.h that
> > isn't supposed to be included by userspace.
> > 
> > So the introduction of CKPT_ARCH_NSIG is a workaround that.
> > 
> > And back to the other problem - I agree, kernel should only include
> > <linux/checkpoint.h>, which in turn will include <checkpoint_hdr.h>
> > if defined CONFIG_CHECKPOINT.
> > 
> > Can you try this patch:
> 
> (Which looks exactly like my patch from yesterday.)

... great minds, eh ?  (and one was really tired ;)

> 
> > (Hallyn: note that there is some checkpoint-related code within
> > kerbel/capability.c that should be inside #ifdef CONFIG_CHECKPOINT).
> 
> Yup, the patch i sent yesterday took care of that.
> 
> So if that's the route we want to take, then again I can
> confirm it did compile on ppc, and compile and boot on
> s390.
> 

Sound good. 

Oren.

[...]
