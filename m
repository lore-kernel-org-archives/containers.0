From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [cgroup or VFS ?]  WARNING: at fs/namespace.c:636
	mntput_no_expire+0xac/0xf2()
Date: Mon, 9 Feb 2009 09:34:14 +0000
Message-ID: <20090209093414.GU28946@ZenIV.linux.org.uk>
References: <49617D35.4040805@cn.fujitsu.com> <20090209004046.3ce1dde0.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754654AbZBIJe3@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090209004046.3ce1dde0.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Li Zefan <lizf@cn.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Paul Menage <menage@google.com>, containers@lists.osdl.org, Arjan van de Ven <arjan@infradead.org>
List-Id: containers.vger.kernel.org

On Mon, Feb 09, 2009 at 12:40:46AM -0800, Andrew Morton wrote:
> > Thread 1:
> >   for ((; ;))
> >   {
> >       mount -t cgroup -o cpuset xxx /mnt > /dev/null 2>&1
> >       mkdir /mnt/0 > /dev/null 2>&1
> >       rmdir /mnt/0 > /dev/null 2>&1
> >       umount /mnt > /dev/null 2>&1
> >   }
> > 
> > Thread 2:
> >   {
> >       mount -t cpuset xxx /mnt > /dev/null 2>&1
> >       umount /mnt > /dev/null 2>&1
> >   }

How cute...  Same mountpoint in both, so these mount(2) will sometimes
fail (cgroup picks the same sb on the same options, AFAICS) and fail
silently due to these redirects...

That's a lovely way to stress-test a large part of ro-bind stuff *and*
umount()-related code.  Could you do C equivalent of the above (just
the same syscalls in loop, nothing fancier) and do time-stamped strace?
