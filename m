From: Dave Hansen <dave@linux.vnet.ibm.com>
Subject: Re: [cgroup or VFS ?]  WARNING: at fs/namespace.c:636
	mntput_no_expire+0xac/0xf2()
Date: Mon, 09 Feb 2009 09:48:59 -0800
Message-ID: <1234201739.20090.194.camel@nimitz>
References: <49617D35.4040805@cn.fujitsu.com>
	 <20090209004046.3ce1dde0.akpm@linux-foundation.org>
	 <20090209093414.GU28946@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756347AbZBIRtT@vger.kernel.org>
In-Reply-To: <20090209093414.GU28946@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, containers@lists.osdl.org, Paul Menage <menage@google.com>, LKML <linux-kernel@vger.kernel.org>, Arjan van de Ven <arjan@infradead.org>
List-Id: containers.vger.kernel.org

On Mon, 2009-02-09 at 09:34 +0000, Al Viro wrote:
> On Mon, Feb 09, 2009 at 12:40:46AM -0800, Andrew Morton wrote:
> > > Thread 1:
> > >   for ((; ;))
> > >   {
> > >       mount -t cgroup -o cpuset xxx /mnt > /dev/null 2>&1
> > >       mkdir /mnt/0 > /dev/null 2>&1
> > >       rmdir /mnt/0 > /dev/null 2>&1
> > >       umount /mnt > /dev/null 2>&1
> > >   }
> > > 
> > > Thread 2:
> > >   {
> > >       mount -t cpuset xxx /mnt > /dev/null 2>&1
> > >       umount /mnt > /dev/null 2>&1
> > >   }
> 
> How cute...  Same mountpoint in both, so these mount(2) will sometimes
> fail (cgroup picks the same sb on the same options, AFAICS) and fail
> silently due to these redirects...
> 
> That's a lovely way to stress-test a large part of ro-bind stuff *and*
> umount()-related code.  Could you do C equivalent of the above (just
> the same syscalls in loop, nothing fancier) and do time-stamped
> strace?

Could you also add a printk of what ->__mnt_writers was at the time of
the WARN_ON()?  That will hopefully at least tell us whether we're
looking at a real leak or just a single missed mnt_want/drop_write().
Also hopefully in which direction the thing is biased.  With the mount
not being around long I'm not horribly hopeful, but it can't hurt.

-- Dave
