From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC][PATCH 2/4] checkpoint/restart: x86 support
Date: Fri, 08 Aug 2008 19:20:58 -0700
Message-ID: <1218248458.19082.68.camel__10402.7347093963$1218248590$gmane$org@nimitz>
References: <20080807224033.FFB3A2C1@kernel>
	<200808081409.30591.arnd@arndb.de> <489CAC70.7090809@cs.columbia.edu>
	<200808090029.28286.arnd@arndb.de> <489CD0F9.9060603@cs.columbia.edu>
	<1218242286.19082.62.camel@nimitz> <489CF0CE.1000603@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <489CF0CE.1000603-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Theodore Tso <tytso-3s7WtUTddSA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, 2008-08-08 at 21:20 -0400, Oren Laadan wrote:
> hehehe .. both; I meant that while it doesn't change per architecture, it
> varies between architectures. So "struct pt_regs" compiled for x86-32 is
> different than that compiled for x86-64. Therefore we can't just dump the
> structure as is and expect that 64 bit would be able to parse the 32 bit.
> In other words, we need an intermediate representation.

Surely we already handle this, though.  Don't we allow a 32-bit app
running on a 64-bit kernel to PTRACE_GETREGS and get the 32-bit version?
A 64-bit app will get the 64-bit version making the same syscall.  It's
all handled in the syscall compatibility code.

-- Dave
