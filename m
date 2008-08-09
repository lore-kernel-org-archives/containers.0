From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: [RFC][PATCH 2/4] checkpoint/restart: x86 support
Date: Sat, 9 Aug 2008 08:43:12 +0200
Message-ID: <200808090843.12922.arnd__40816.6042798713$1218264321$gmane$org@arndb.de>
References: <20080807224033.FFB3A2C1@kernel> <200808090029.28286.arnd@arndb.de>
	<489CD0F9.9060603@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <489CD0F9.9060603-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Theodore Tso <tytso-3s7WtUTddSA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Saturday 09 August 2008, Oren Laadan wrote:
> >> Anyway, either a single structure for both 32 and 64 bit x86, or separate
> >> "struct cr_hdr_cpu{_32,_64}", one for each architecture.
> > 
> > struct pt_regs is part of the kernel ABI, it will not change.
> 
> I'm in favor about keeping the format identical between the variations of
> each architecture. Note, however, that "struct pt_regs" won't do because it
> may change with these variations.
> 
> So we'll take care of the padding and add r8..r15 in the next version.
> 

Fair enough. How about making the layout in that structure identical to
the 64-bit pt_regs though? I don't know if we need that at any time,
but my feeling is that it is nicer than a slightly different random
layout, e.g. if someone wants to extend gdb to look at checkpointed
process dumps.

	Arnd <><
