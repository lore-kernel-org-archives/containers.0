From: Jeremy Fitzhardinge <jeremy-TSDbQ3PG+2Y@public.gmane.org>
Subject: Re: [RFC][PATCH 2/4] checkpoint/restart: x86 support
Date: Sun, 10 Aug 2008 07:55:26 -0700
Message-ID: <489F015E.9080704__41343.3816786439$1218380375$gmane$org@goop.org>
References: <20080807224033.FFB3A2C1@kernel>	
	<200808081409.30591.arnd@arndb.de>
	<489CAC70.7090809@cs.columbia.edu>	
	<200808090029.28286.arnd@arndb.de>
	<489CD0F9.9060603@cs.columbia.edu>
	<1218242286.19082.62.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1218242286.19082.62.camel@nimitz>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Theodore Tso <tytso-3s7WtUTddSA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
List-Id: containers.vger.kernel.org

Dave Hansen wrote:
> On Fri, 2008-08-08 at 19:04 -0400, Oren Laadan wrote:
>   
>>> struct pt_regs is part of the kernel ABI, it will not change.
>>>       
>> I'm in favor about keeping the format identical between the variations of
>> each architecture. Note, however, that "struct pt_regs" won't do because it
>> may change with these variations.
>>     
>
> "Part of the kernel ABI" makes it sound to me like it won't change.
> Who's right here? :)

Struct pt_regs is not ABI, and can (and has) changed on x86.   It's not 
suitable for a checkpoint structure because it only contains the 
registers that the kernel trashes, not all usermode registers (on i386, 
it leaves out %gs, for example).  asm-x86/ptrace-abi.h does define stuff 
that's fixed in stone; it expresses it in terms of a register array, 
with constants defining what element is which register.

    J
