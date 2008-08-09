From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC][PATCH 2/4] checkpoint/restart: x86 support
Date: Fri, 08 Aug 2008 21:20:14 -0400
Message-ID: <489CF0CE.1000603__46410.3605635048$1218244933$gmane$org@cs.columbia.edu>
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
>>> struct pt_regs is part of the kernel ABI, it will not change.
>> I'm in favor about keeping the format identical between the variations of
>> each architecture. Note, however, that "struct pt_regs" won't do because it
>> may change with these variations.
> 
> "Part of the kernel ABI" makes it sound to me like it won't change.
> Who's right here? :)
 >
 > -- Dave
 >

hehehe .. both; I meant that while it doesn't change per architecture, it
varies between architectures. So "struct pt_regs" compiled for x86-32 is
different than that compiled for x86-64. Therefore we can't just dump the
structure as is and expect that 64 bit would be able to parse the 32 bit.
In other words, we need an intermediate representation.

Oren.
