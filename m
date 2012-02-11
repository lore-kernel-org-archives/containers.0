From: Serge Hallyn <serge.hallyn@canonical.com>
Subject: Re: prevent containers from turning host filesystem readonly
Date: Fri, 10 Feb 2012 21:57:06 -0600
Message-ID: <20120211035705.GA5563@sergelap>
References: <20120211031939.GA4772@sergelap>
 <20120211033732.GK23916@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120211033732.GK23916@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: lkml <linux-kernel@vger.kernel.org>, Andy Whitcroft <apw@canonical.com>, Andrew Morton <akpm@linux-foundation.org>, "Eric W. Biederman" <ebiederm@xmission.com>, Dave Hansen <haveblue@us.ibm.com>, linux-security-module@vger.kernel.org, Linux Containers <containers@lists.osdl.org>, St?phane Graber <stgraber@ubuntu.com>, Daniel Lezcano <daniel.lezcano@free.fr>
List-Id: containers.vger.kernel.org

Quoting Al Viro (viro@ZenIV.linux.org.uk):
> On Fri, Feb 10, 2012 at 09:19:39PM -0600, Serge Hallyn wrote:
> > When a container shuts down, it likes to do 'mount -o remount,ro /'.
> > That sets the superblock's readonly flag, not the mount's.  So unless
> > the mount action fails for some reason (i.e. a file is held open on
> > the fs), if the container's rootfs is just a directory on the host's
> > fs, the host fs will be marked readonly.
> > 
> > Thanks to Dave Hansen for pointing out how simple the fix can be.  If
> > the devices cgroup denies the mounting task write access to the
> > underlying superblock (as it usually does when the container's root fs
> > is on a block device shared with the host), then it do_remount_sb should
> > deny the right to change mount flags as well.
> > 
> > This patch adds that check.
> > 
> > Note that another possibility would be to have the LSM step in.  We
> > can't catch this (as is) at the LSM level because security_remount_sb
> > doesn't get the mount flags, so we can't distinguish
> > 	mount -o remount,ro
> > from
> > 	mount --bind -o remount,ro.
> > Sending the flags to that hook would probably be a good idea in addition
> > to this patch, but I haven't done it here.
> 
> NAK.  This is just plain wrong - what about the filesystems that are not
> bdev-backed or, as e.g. btrfs, sit on more than one device?
> 
> <comments about inadequacy of cgroup as an API censored - far too unprintable>

Drat.

Would passing the mount flags from do_remount() to security_sb_remount()
be acceptable?  Then at least the LSM could distinguish and act
accordingly.

Thanks for looking.

-serge
