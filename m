From: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/2][LXC] Have lxc_restart call app_restart()
Date: Wed, 24 Feb 2010 09:45:15 +0100
Message-ID: <4B84E71B.2020408@fr.ibm.com>
References: <20100224084108.GG18758@us.ibm.com>
	<20100224084156.GH18758@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100224084156.GH18758-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

On 02/24/2010 09:41 AM, Sukadev Bhattiprolu wrote:
> diff --git a/src/lxc/Makefile2 b/src/lxc/Makefile2
> new file mode 100644
> index 0000000..9aba841
> --- /dev/null
> +++ b/src/lxc/Makefile2
> @@ -0,0 +1,16 @@
> +
> +CFLAGS = -static -I . -I ..
> +
> +LDFLAGS = /lib/libcheckpoint.a -lutil
> +
> +LXC_OBJS = start.o conf.o confile.o arguments.o monitor.o log.o mainloop.o \
> +		utils.o commands.o state.o cgroup.o error.o namespace.o \
> +		parse.o network.o af_unix.o console.o nl.o stop.o
> +
> +RESTART_OBJS = $(LXC_OBJS) lxc_restart.o restart.o
> +
> +lxc_restart: $(RESTART_OBJS)
> +	$(CC) -o lxc_restart $(RESTART_OBJS) $(LDFLAGS)
> +
> +clean:
> +	rm -f $(RESTART_OBJS)

you should patch Makefile.am.

C.
