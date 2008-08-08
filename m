From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC][PATCH 2/4] checkpoint/restart: x86 support
Date: Fri, 08 Aug 2008 19:04:25 -0400
Message-ID: <489CD0F9.9060603__28074.7801218697$1218237270$gmane$org@cs.columbia.edu>
References: <20080807224033.FFB3A2C1@kernel> <200808081409.30591.arnd@arndb.de>
	<489CAC70.7090809@cs.columbia.edu>
	<200808090029.28286.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <200808090029.28286.arnd-r2nGTMty4D4@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Theodore Tso <tytso-3s7WtUTddSA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org



Arnd Bergmann wrote:
> On Friday 08 August 2008, Oren Laadan wrote:
> 
>>> It seems weird that you use __u64 members for the registers, but don't
>>> include r8..r15 in the list. As a consequence, this structure does not
>>> seem well suited for either x86-32 or x86-64.
>> In the context of CR, x86-32 and x86-64 are distinct architectures because
>> you cannot always migrate from one to the other (though 32->64 is sometimes
>> possible). Therefore, each architecture can have a separate checkpoint file
>> format (eg r8..r15 only for x86-64).
> 
> So why do you use __u64 members for your 32 bit registers?

The idea was that x86-32 checkpoints can be restarted on a x86-64 node in
32 bit mode. Clearly it needed more thought...

> 
>> Except for this special case (32 bit running 64 bit), simple conversion can
>> be done in the kernel if needed, but most conversion between kernel the
>> format for different kernel versions (should it change) can be done in
>> user space (eg. with a filter).
> 
> The 32bit on 64bit case is quite common on non-x86 architectures, e.g.
> powerpc or sparc, where 64 bit kernels typically run 32 bit user space.
> 
> A particularly interesting case is mixing 32 and 64 bit tasks in a container
> that you are checkpointing. This is a very realistic scenario, so there
> may be good arguments for keeping the format identical between the variations
> of each architecture.
> 
>>> I would suggest either using struct pt_regs by reference, or defining
>>> it so that you can use the same structure for both 32 and 64 bit x86.
>> We prefer not to use the kernel structure directly, but an intermediate
>> structure that can help mitigate subtle incompatibilities issues (between
>> kernel configurations, versions, and even compiler versions).
>>
>> Anyway, either a single structure for both 32 and 64 bit x86, or separate
>> "struct cr_hdr_cpu{_32,_64}", one for each architecture.
> 
> struct pt_regs is part of the kernel ABI, it will not change.

I'm in favor about keeping the format identical between the variations of
each architecture. Note, however, that "struct pt_regs" won't do because it
may change with these variations.

So we'll take care of the padding and add r8..r15 in the next version.

Oren.
