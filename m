From: Fengguang Wu <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [Lsf] [RFC] writeback and cgroup
Date: Tue, 17 Apr 2012 10:14:24 +0800
Message-ID: <20120417021424.GA9418@localhost>
References: <20120407080027.GA2584@quack.suse.cz>
	<20120410180653.GJ21801@redhat.com>
	<20120410210505.GE4936@quack.suse.cz>
	<20120410212041.GP21801@redhat.com>
	<20120410222425.GF4936@quack.suse.cz>
	<20120411154005.GD16692@redhat.com>
	<1334406314.2528.90.camel@twins>
	<20120416125432.GB12776@redhat.com>
	<20120416130707.GA10532@localhost>
	<20120416155207.GB15437@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120416155207.GB15437-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, andrea-oIIqvOZpAevzfdHfmsDf5w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, lsf-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, Apr 16, 2012 at 11:52:07AM -0400, Vivek Goyal wrote:
> On Mon, Apr 16, 2012 at 09:07:07PM +0800, Fengguang Wu wrote:
> 
> [..]
> > Vivek, I noticed these lines in cfq code
> > 
> >                 sscanf(dev_name(bdi->dev), "%u:%u", &major, &minor);
> > 
> > Why not use bdi->dev->devt?  The problem is that dev_name() will
> > return "btrfs-X" for btrfs rather than "major:minor".
> 
> Isn't bdi->dev->devt 0?  I see following code.
> 
> add_disk()
>    bdi_register_dev()
>       bdi_register()
>          device_create_vargs(MKDEV(0,0))
> 	      dev->devt = devt = MKDEV(0,0);
> 
> So for normal block devices, I think bdi->dev->devt will be zero, that's
> why probably we don't use it.

Yes indeed. I can confirm this with tracing. There are two main cases

- some filesystems do not have a real device for the bdi.

- add_disk() calls bdi_register_dev() with the devt, however this
  information is not passed down for some reason.
  device_create_vargs() will try to create a sysfs dev file if the
  devt is not MKDEV(0,0).

Thanks,
Fengguang
