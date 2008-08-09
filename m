From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC][PATCH 2/4] checkpoint/restart: x86 support
Date: Fri, 08 Aug 2008 22:35:10 -0400
Message-ID: <489D025E.3030901__48707.0859097459$1218249498$gmane$org@cs.columbia.edu>
References: <20080807224033.FFB3A2C1@kernel>	
	<200808081409.30591.arnd@arndb.de>
	<489CAC70.7090809@cs.columbia.edu>	
	<200808090029.28286.arnd@arndb.de>
	<489CD0F9.9060603@cs.columbia.edu>	
	<1218242286.19082.62.camel@nimitz>
	<489CF0CE.1000603@cs.columbia.edu>
	<1218248458.19082.68.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1218248458.19082.68.camel@nimitz>
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
> On Fri, 2008-08-08 at 21:20 -0400, Oren Laadan wrote:
>> hehehe .. both; I meant that while it doesn't change per architecture, it
>> varies between architectures. So "struct pt_regs" compiled for x86-32 is
>> different than that compiled for x86-64. Therefore we can't just dump the
>> structure as is and expect that 64 bit would be able to parse the 32 bit.
>> In other words, we need an intermediate representation.
> 
> Surely we already handle this, though.  Don't we allow a 32-bit app
> running on a 64-bit kernel to PTRACE_GETREGS and get the 32-bit version?
> A 64-bit app will get the 64-bit version making the same syscall.  It's
> all handled in the syscall compatibility code.

Sure, that's a compatibility layer around ptrace() in the 64-bit kernel.

Recall that Arnd suggested "keeping the format identical between the
variations of each architecture", and I fully agree. If we want to keep
the format identical, we can't simply define:
	struct cr_hdr_cpu {
		struct pt_regs regs;
		...
	};
because that will compile differently on x86-32 and x86-64. So either we
add r8..r15 to the structure as it appears in the patch now (and keep the
format identical), or allow the format to vary, and explicitly test for
this case and add a compatibility layer. Personally I prefer the former.

Oren.
