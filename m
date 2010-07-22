From: Greg KH <gregkh-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [PATCH] cgroupfs: create /sys/fs/cgroup to mount cgroupfs on
Date: Thu, 22 Jul 2010 11:53:01 -0700
Message-ID: <20100722185301.GA528__30151.3074468405$1279825100$gmane$org@suse.de>
References: <20100722182638.GA12712@kroah.com>
	<AANLkTinRGBksuWAZhdmvr39FNACU18+kc5ut49VUf=mp@mail.gmail.com>
	<20100722183614.GA5443@suse.de>
	<AANLkTimbcuzH6_bBhYX0U6vqftYgRwE0ZTmcbaRNzXef@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <AANLkTimbcuzH6_bBhYX0U6vqftYgRwE0ZTmcbaRNzXef-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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

On Thu, Jul 22, 2010 at 11:44:50AM -0700, Paul Menage wrote:
> On Thu, Jul 22, 2010 at 11:36 AM, Greg KH <gregkh-l3A5Bk7waGM@public.gmane.org> wrote:
> >
> > Really? =A0I see systems mounting it at /cgroups/ in the filesystem tod=
ay.
> =

> Sure, it *can* be mounted as a single instance, but you then lose
> flexibility. E.g. at Google we want to have a different hierarchy for
> the CPU subsystem (with the tree grouped according to
> latency-sensitive versus batch, etc) and memory (grouped according to
> what jobs are sharing memory with each other).
> =

> > Where are you expecting it to be mounted at?
> =

> I have no particular expectation. (At Google we're actually using
> /dev/cgroup/* but that's just for historical reasons, from
> /dev/cpuset). Under /sys/fs/cgroup sounds reasonable, but you'd want
> people to have the ability to manually create subdirs in there for
> separate mount points.

Ok, that's great, but it's not where the distros are starting to mount
it at.  As I learned with debugfs, you need to pick a location for
people to mount it at, otherwise it ends up all over the place.

If you are using /dev/cgroup/ that's nice, but I don't think that people
are expecting a whole filesystem under a /dev/ subdirectory.

I didn't realize that cgroupfs had so many different options that would
enable it to handle multiple mounts in this way.

Hm, Lennart, Kay, any ideas as to where to put it in a "standard" way?

thanks,

greg k-h
