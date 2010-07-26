From: Greg KH <gregkh-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [PATCH] cgroupfs: create /sys/fs/cgroup to mount cgroupfs on
Date: Mon, 26 Jul 2010 15:05:46 -0700
Message-ID: <20100726220546.GB9671__27201.4779308394$1280182068$gmane$org@suse.de>
References: <20100722182638.GA12712@kroah.com>
	<AANLkTinRGBksuWAZhdmvr39FNACU18+kc5ut49VUf=mp@mail.gmail.com>
	<20100722183614.GA5443@suse.de>
	<AANLkTinsd2gWOHb3w9gzvKO5vdwLBT7DZOY+2xCUz_5_@mail.gmail.com>
	<AANLkTimm9XGvK2H55V7N76JPU05iHk_dY5JjOLifQTsr@mail.gmail.com>
	<AANLkTi=OMaKuk+ReeqCfBGes76BjKYyUdqxPOQfH8EcZ@mail.gmail.com>
	<20100726212858.GA15904@suse.de>
	<AANLkTimmAfhw7WhPHHU6d4izkzvp2oxOSzNN8JjNu_nU@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <AANLkTimmAfhw7WhPHHU6d4izkzvp2oxOSzNN8JjNu_nU-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
Cc: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Lennart Poettering <lennart-mdGvqq1h2p+GdvJs77BJ7Q@public.gmane.org>, Dhaval Giani <dhaval.giani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, Jul 26, 2010 at 02:55:18PM -0700, Paul Menage wrote:
> On Mon, Jul 26, 2010 at 2:28 PM, Greg KH <gregkh-l3A5Bk7waGM@public.gmane.org> wrote:
> >
> > Ok, again, after all of this, who is going to be applying this patch to
> > their tree for the .36 merge window?
> 
> There's no specific cgroups tree - cgroups patches generally go via akpm.
> 
> >
> > Or should I apply it to my driver-core one?
> >
> 
> That sounds like an OK option too.

Wonderful, can I get some acks from the cgroups maintainers?  I'll
gladly take it through my tree.

thanks,

greg k-h
