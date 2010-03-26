From: Jamie Lokier <jamie-yetKDKU6eevNLxjTenLetw@public.gmane.org>
Subject: Re: [C/R ARM][PATCH 3/3] c/r: ARM implementation of checkpoint/restart
Date: Fri, 26 Mar 2010 02:47:59 +0000
Message-ID: <20100326024759.GN19308__40987.0392679752$1269571744$gmane$org@shareable.org>
References: <1269219965-23923-1-git-send-email-christofferdall@christofferdall.dk>
	<1269219965-23923-4-git-send-email-christofferdall@christofferdall.dk>
	<20100323211843.GC19572@n2100.arm.linux.org.uk>
	<7d08b87d1003241348g347f092k1142318490e0bdcc@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <7d08b87d1003241348g347f092k1142318490e0bdcc-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Christoffer Dall <christofferdall-77OGu6e99YhyO3AAkE1OcX9LOBIZ5rWg@public.gmane.org>
Cc: containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Russell King - ARM Linux <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>, linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-arm-kernel <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Id: containers.vger.kernel.org

Christoffer Dall wrote:
> > That doesn't indicate what ISA version the system is running on, or even
> > if the ABI is compatible (we have two ABIs - OABI and EABI).
> =

> That's why I checkpointed CONFIG_OABI_COMPAT, but I realize that it's
> not sufficient.
> =

> How about checkpointing CONFIG_AEABI and CONFIG_OABI_COMPAT and making
> sure that we either restore to the same setting of the two or restore
> to CONFIG_OABI_COMPAT=3Dy?

With CONFIG_OABI_COMPAT enabled, each process can be in either
personality: OABI or EABI.  Checkpointing will need to remember which
one.

With CONFIG_OABI_COMPAT disabled, it'll be fixed at one or the other,
but there's no reason why a process should not be moved between
kernels with different values of CONFIG_OABI_COMPAT, so long as the
OABI or EABI personality is supported by the destination kernel.

In other words, CONFIG_OABI_COMPAT shouldn't be in the checkpoint
state at all - only the per-process personalities should be.

> >> We checkpoint whether the system is running with CONFIG_MMU or not and
> >> require the same configuration for the system on which we restore the
> >> process. It might be possible to allow something more fine-grained,
> >> if it's worth the energy. Input on this item is also very welcome,
> >> specifically from someone who knows the exact meaning of the end_brk
> >> field.
> >
> > Processes which run on MMU and non-MMU CPUs are unlikely to be
> > interchangable - the run time environments are quite different. =A0I
> > think this is a sane check.
> >
> thanks.

It's possible in principle to run many non-MMU binaries on MMU
kernels, but I've never heard of anyone doing it.

-- Jamie
