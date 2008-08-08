From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: [RFC][PATCH 2/4] checkpoint/restart: x86 support
Date: Fri, 8 Aug 2008 14:09:29 +0200
Message-ID: <200808081409.30591.arnd__13287.943081423$1218197504$gmane$org@arndb.de>
References: <20080807224033.FFB3A2C1@kernel> <20080807224035.E56663BF@kernel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080807224035.E56663BF@kernel>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Theodore Tso <tytso-3s7WtUTddSA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org



> diff -puN /dev/null include/asm-x86/ckpt.h
> --- /dev/null	2007-04-11 11:48:27.000000000 -0700
> +++ linux-2.6.git-dave/include/asm-x86/ckpt.h	2008-08-04 13:29:59.000000000 -0700
> @@ -0,0 +1,46 @@

> +
> +struct cr_hdr_cpu {
> +        __u64 bx;
> +        __u64 cx;
> +        __u64 dx;
> +        __u64 si;
> +        __u64 di;
> +        __u64 bp;
> +        __u64 ax;
> +        __u64 ds;
> +        __u64 es;
> +        __u64 orig_ax;
> +        __u64 ip;
> +        __u64 cs;
> +        __u64 flags;
> +        __u64 sp;
> +        __u64 ss;
> +        __u64 fs;
> +        __u64 gs;
> +
> +	__u64 debugreg0;
> +	__u64 debugreg1;
> +	__u64 debugreg2;
> +	__u64 debugreg3;
> +	__u64 debugreg6;
> +	__u64 debugreg7;
> +
> +	__u8 uses_debug;
> +
> +	__u8 used_math;
> +	__u8 has_fxsr;
> +	union thread_xstate xstate;	/* i387 */
> +};

It seems weird that you use __u64 members for the registers, but don't
include r8..r15 in the list. As a consequence, this structure does not
seem well suited for either x86-32 or x86-64.

I would suggest either using struct pt_regs by reference, or defining
it so that you can use the same structure for both 32 and 64 bit x86.

	Arnd <><
