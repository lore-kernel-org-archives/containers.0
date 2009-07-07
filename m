From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: Re: build breaks when checkpoint unimplemented by arch
Date: Tue, 07 Jul 2009 11:31:15 -0500
Message-ID: <m33a98v4j0.fsf@pobox.com>
References: <m3my7hv7w8.fsf@pobox.com>
	<Pine.LNX.4.64.0907061902530.15941@takamine.ncl.cs.columbia.edu>
	<m3bpnxv03k.fsf@pobox.com>
	<Pine.LNX.4.64.0907070039360.22105@takamine.ncl.cs.columbia.edu>
	<m2eist3tcr.fsf@pobox.com>
	<Pine.LNX.4.64.0907071049540.24765@takamine.ncl.cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <Pine.LNX.4.64.0907071049540.24765-CXF6herHY6ykSYb+qCZC/1i27PF6R63G9nwVQlTi/Pw@public.gmane.org>
	(Oren Laadan's message of "Tue\, 7 Jul 2009 10\:58\:26 -0400 \(EDT\)")
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
> On Tue, 7 Jul 2009, Nathan Lynch wrote:
>
>> Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org> writes:
>> > That's what I tried initially, but the problem is that sigset_t may
>> > be defined differently for userspace - see /usr/include/asm/sigset_t.h.
>> > In fact, for x86_32, it it is different, defined as 'unsigned long' 
>> > (and NSIG defined as 32, so only 32 bits).
>> 
>> I noticed this, but I figured only the kernel definition was salient.
>> Apart from debugging checkpoint/restart, why would userspace need the
>> definition of struct ckpt_hdr_sigset?
>
> I expect user space tools to at least:
>
> - Assist in debugging c/r
>
> - Assist users in reporting problems with c/r (especially since they
>   themselves do not debug or hack)
>
> - Convert checkpoint images from one kernel version to another
>
> - Provide information about a checkpoint image, and even allow its
>   manipulation.  This can assist developers in debugging their programs
>   (e.g. to debug a crash you need to run a program for 30 minutes so it 
>   ets up its state; instead of repeatedly running it, you run it once, 
>   checkpoint, and then debug from a restarted version. A tool could 
>   allow you to peek/poke inside the checkpoint and even modify data in 
>   it).
>
> - Or a tool that converts a checkpoint image to a core dump so it
>   can be inspected with gdb.
>
> I'm pretty sure others will find other uses to it...

But I asked specifically about ckpt_hdr_sigset.


>> For that matter, why would userspace need the definitions of most of the
>> structures in checkpoint_hdr.h?  (Again, debugging purposes don't count:
>> ckptinfo or similar developer utilities can be included with the
>> kernel.)
>
> Keeping the checkpoint header format understandable by user space (and 
> immune to 32-64 variations) has been a requirement since day 1.

I guess I wasn't around that day.  It seems backwards to expose the
format of every checkpoint record in the ABI regardless of whether
plausible use cases exist.  Linux has a well-established pattern of
introducing interfaces without sufficient testing or documentation[1],
and I expect C/R will adhere to tradition.  Making the ABI obese in the
hope of anticipating every conceivable use will just provide more
opportunities to screw up.

[1] http://userweb.kernel.org/~mtk/papers/lce2007/What_we_lose_without_words.pdf
