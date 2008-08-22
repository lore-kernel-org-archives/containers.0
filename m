From: Dave Hansen <dave-gkUM19QKKo4@public.gmane.org>
Subject: Re: [RFC v2][PATCH 3/9] x86 support for checkpoint/restart
Date: Fri, 22 Aug 2008 13:17:50 -0700
Message-ID: <1219436270.20559.131.camel__7489.0140248046$1219436442$gmane$org@nimitz>
References: <Pine.LNX.4.64.0808202251500.17436@takamine.ncl.cs.columbia.edu>
	<Pine.LNX.4.64.0808202304180.17436@takamine.ncl.cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <Pine.LNX.4.64.0808202304180.17436-CXF6herHY6ykSYb+qCZC/1i27PF6R63G9nwVQlTi/Pw@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jeremy-TSDbQ3PG+2Y@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, 2008-08-20 at 23:04 -0400, Oren Laadan wrote:+
> +#ifdef CONFIG_X86_64
> +
> +#error "CONFIG_X86_64 unsupported yet."

Well, I told you I'd write some Kconfig magic for you, but I can't since
I can't apply these patches. :)

You need this in a Kconfig file somewhere:

config CHECKPOINT_RESTART
	prompt "Good prompt"
	def_bool y
	depends on X86_32 && EXPERIMENTAL
	help
		Lots of fun help...

config SELECT_ALL_NAMESPACES
	prompt "Enable all kernel namespace support"
	selects IPC_NS NET_NS ...
	help
		This option will save you having to go track down
		all of the individual places that namespaces are
		supported in the kernel.

		If you don't turn this on, the restart porttion
		of checkpoint/restart gets a lots less reliable...	

probably in checkpoint/Kconfig.

Then, in all of the architectures' arch/*/Kconfig files, you need to:

source "checkpoint/Kconfig"

Then, the Makefile looks like this:

--- /dev/null   2008-04-22 10:49:52.000000000 -0700
+++ oren-cr.git-dave/checkpoint/Makefile        2008-08-22 12:30:53.000000000 -0700
@@ -0,0 +1 @@
+obj-$(CONFIG_CHECKPOINT_RESTART) += sys.o checkpoint.o restart.o

-- Dave
