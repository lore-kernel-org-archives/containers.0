From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: BUG in tty_open when using containers and ptrace
Date: Mon, 13 Apr 2009 09:20:38 -0500
Message-ID: <20090413142038.GB13007@us.ibm.com>
References: <d06d0dd6a4ddf760bea53291c048e291@[::1]>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <d06d0dd6a4ddf760bea53291c048e291@[::1]>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: =?iso-8859-1?Q?M=F4she?= van der Sterre <me-A/3C56C7qwM@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting M=F4she van der Sterre (me-A/3C56C7qwM@public.gmane.org):
> Hello,
> =

> I am working on the lxc userspace tools, and got this BUG a couple of
> times.
> Here are the reports:
> =

> http://moshe.nl/tty-bugshot1.png
> http://moshe.nl/tty-bugshot2.png
> =

> I am running 2.6.29.1 from kernel.org in a virtual machine under kvm.
> I have not been able to reliably reproduce it, but it happens only after
> the container is setup and ptrace is active on lxc-start.
> I think the first screen shot is while all ttys where allowed in
> cgroup.devices, the second one while only tty1 was allowed.

Which distro is this - an uptodate F10, fresh F11, something else?

Since it also happens when all ttys are allowed it probably isn't the
devices cgroup...  Actually the devpts code seems the most likely
cause.  Suka, can you take a look at the 2.6.29.1 source for anything
suspect?

M=F4she, can you send me tty_io.S after doing:
	'objdump -d drivers/char/tty_io.o > tty_io.S'

as well as strace_output after doing:
	'strace -f -ostrace_output <your_lxc_start_command_here>'
?

thanks,
-serge
