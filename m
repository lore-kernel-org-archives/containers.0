From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: Re: build breaks when checkpoint unimplemented by arch
Date: Tue, 07 Jul 2009 01:22:28 -0500
Message-ID: <m2eist3tcr.fsf@pobox.com>
References: <m3my7hv7w8.fsf@pobox.com>
	<Pine.LNX.4.64.0907061902530.15941@takamine.ncl.cs.columbia.edu>
	<m3bpnxv03k.fsf@pobox.com>
	<Pine.LNX.4.64.0907070039360.22105@takamine.ncl.cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <Pine.LNX.4.64.0907070039360.22105-CXF6herHY6ykSYb+qCZC/1i27PF6R63G9nwVQlTi/Pw@public.gmane.org>
	(Oren Laadan's message of "Tue\, 7 Jul 2009 00\:44\:15 -0400 \(EDT\)")
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org> writes:
> That's what I tried initially, but the problem is that sigset_t may
> be defined differently for userspace - see /usr/include/asm/sigset_t.h.
> In fact, for x86_32, it it is different, defined as 'unsigned long' 
> (and NSIG defined as 32, so only 32 bits).

I noticed this, but I figured only the kernel definition was salient.
Apart from debugging checkpoint/restart, why would userspace need the
definition of struct ckpt_hdr_sigset?

For that matter, why would userspace need the definitions of most of the
structures in checkpoint_hdr.h?  (Again, debugging purposes don't count:
ckptinfo or similar developer utilities can be included with the
kernel.)


> Moreover, if you include <asm/sigset.h> in checkpoint_hdr.h, which is
> also included by userspace, you get lots of compilations warnings,
> because of other stuff included from the kernel's asm/sigset.h that
> isn't supposed to be included by userspace.

Can you provide examples of such warnings?  Are you building against
"sanitized" kernel headers (make headers_install) or using them in
place?
