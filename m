From: Greg KH <gregkh-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [PATCH] cgroupfs: create /sys/fs/cgroup to mount cgroupfs on
Date: Thu, 22 Jul 2010 12:12:00 -0700
Message-ID: <20100722191200.GA5609__13105.1755430692$1279826333$gmane$org@suse.de>
References: <20100722182638.GA12712@kroah.com>
	<AANLkTinRGBksuWAZhdmvr39FNACU18+kc5ut49VUf=mp@mail.gmail.com>
	<20100722183614.GA5443@suse.de>
	<AANLkTimbcuzH6_bBhYX0U6vqftYgRwE0ZTmcbaRNzXef@mail.gmail.com>
	<20100722185301.GA528@suse.de>
	<AANLkTik07hZot_x0p7xJuY8s4f8pGRd2Mn1+jYfHH2iq@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <AANLkTik07hZot_x0p7xJuY8s4f8pGRd2Mn1+jYfHH2iq-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Lennart Poettering <lennart-mdGvqq1h2p+GdvJs77BJ7Q@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Jul 22, 2010 at 12:07:43PM -0700, Paul Menage wrote:
> On Thu, Jul 22, 2010 at 11:53 AM, Greg KH <gregkh-l3A5Bk7waGM@public.gmane.org> wrote:
> >
> > If you are using /dev/cgroup/ that's nice, but I don't think that people
> > are expecting a whole filesystem under a /dev/ subdirectory.
> 
> Sure - as I said that's just for historical reasons from when we
> migrated from cpusets which were traditionally mounted at /dev/cpuset,
> so it involved less change. There's no particular reason to mount it
> there (although having said that, what about /dev/pts and /dev/shm?).

Yeah, /dev/pts and /dev/shm are long-time users of the /dev filesystem.
I don't know if we want to encourage that as a mount point, do you?

What are the different names you are giving to your mount points now for
cgroupfs so I can get an idea of how it is used currently?

thanks,

greg k-h
