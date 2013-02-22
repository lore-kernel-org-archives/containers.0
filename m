From: Cyrill Gorcunov <gorcunov-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [CRIU] [Announce] Checkpoint-restore tool v0.4
Date: Fri, 22 Feb 2013 13:13:26 +0400
Message-ID: <20130222091326.GA17499@moon>
References: <5124B107.1040302@parallels.com>
	<alpine.LNX.2.01.1302220955160.1805@nerf07.vanv.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.01.1302220955160.1805-F2ai0iW9ZajH9RFtKMg/Ng@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jan Engelhardt <jengelh-9+2X+4sQBs8@public.gmane.org>
Cc: CRIU <criu-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Feb 22, 2013 at 10:01:19AM +0100, Jan Engelhardt wrote:
> 
> On Wednesday 2013-02-20 12:18, Pavel Emelyanov wrote:
> >
> >As was planned, the v0.4 of C/R tools is out, right after the Linux v3.8.
> >
> >The most valuable thing in this release, is that all the kernel patches
> >we had are now merged, and thus what crtools-v0.4 can do will work on
> >the upstream kernel (properly configured)!
> 
> I have trouble compiling that.
> 
> $ + make -j10 'CFLAGS=-fmessage-length=0 -O2 -Wall -D_FORTIFY_SOURCE=2 -fstack-protector -funwind-tables -fasynchronous-unwind-tables -g' V=1
> gcc -M -MT arch/x86/crtools.d -MT arch/x86/crtools.o -fmessage-length=0 -O2 -Wall -D_FORTIFY_SOURCE=2 -fstack-protector -funwind-tables -fasynchronous-unwind-tables -g   arch/x86/crtools.c -o arch/x86/crtools.d
> arch/x86/crtools.c:5:21: fatal error: asm/fpu.h: No such file or directory
> 
> fpu.h does not exist in /usr/include, nor does it exist in $linux/arch/x86/
> or $linux/include. Apparently it does exist in crtools, but there are no
> more flags pointing to crtools/include/. Which probably means you should
> place mandatory CFLAGS not in CFLAGS, but your own variable.

Thanks for report, i'll fix that.
