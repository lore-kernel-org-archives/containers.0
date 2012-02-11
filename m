From: "Serge E. Hallyn" <serge@hallyn.com>
Subject: Re: prevent containers from turning host filesystem readonly
Date: Sat, 11 Feb 2012 20:28:03 +0000
Message-ID: <20120211202803.GA19961@hallyn.com>
References: <20120211031939.GA4772@sergelap>
 <20120211033732.GK23916@ZenIV.linux.org.uk>
 <20120211040722.GA5891@sergelap>
 <m1zkcp2np9.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <m1zkcp2np9.fsf@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Serge Hallyn <serge.hallyn@canonical.com>, Al Viro <viro@ZenIV.linux.org.uk>, lkml <linux-kernel@vger.kernel.org>, Andy Whitcroft <apw@canonical.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <haveblue@us.ibm.com>, linux-security-module@vger.kernel.org, Linux Containers <containers@lists.osdl.org>, St?phane Graber <stgraber@ubuntu.com>, Daniel Lezcano <daniel.lezcano@free.fr>
List-Id: containers.vger.kernel.org

Quoting Eric W. Biederman (ebiederm@xmission.com):
> Serge Hallyn <serge.hallyn@canonical.com> writes:
> 
> > Quoting Al Viro (viro@ZenIV.linux.org.uk):
> >> On Fri, Feb 10, 2012 at 09:19:39PM -0600, Serge Hallyn wrote:
> >> > When a container shuts down, it likes to do 'mount -o remount,ro /'.
> >> > That sets the superblock's readonly flag, not the mount's.  So unless
> >> > the mount action fails for some reason (i.e. a file is held open on
> >> > the fs), if the container's rootfs is just a directory on the host's
> >> > fs, the host fs will be marked readonly.
> >> > 
> >> > Thanks to Dave Hansen for pointing out how simple the fix can be.  If
> >> > the devices cgroup denies the mounting task write access to the
> >> > underlying superblock (as it usually does when the container's root fs
> >> > is on a block device shared with the host), then it do_remount_sb should
> >> > deny the right to change mount flags as well.
> >> > 
> >> > This patch adds that check.
> >> > 
> >> > Note that another possibility would be to have the LSM step in.  We
> >> > can't catch this (as is) at the LSM level because security_remount_sb
> >> > doesn't get the mount flags, so we can't distinguish
> >> > 	mount -o remount,ro
> >> > from
> >> > 	mount --bind -o remount,ro.
> >> > Sending the flags to that hook would probably be a good idea in addition
> >> > to this patch, but I haven't done it here.
> >> 
> >> NAK.  This is just plain wrong - what about the filesystems that are not
> >
> > BTW, sorry - the patch clearly should've taken non-bdevs into account, but
> > I accept that wouldn't have been enough to evade a NAK.
> >
> >> bdev-backed or, as e.g. btrfs, sit on more than one device?
> >
> > btrfs is actually one of my main motivators - to quickly snapshot containers
> > with btrfs means that the containers all share one fs, but that means one
> > container can mark them all ro.
> 
> Serge let me respectfully suggest that getting the user namespace done
> will deal with this issue nicely.
> 
> In the simple case you simply won't be root so remount will just be
> denied.
> 
> When/if we allow a limited form of unprivileged mounts in a user
> namespace your user won't have mounted the filesystem so you should not
> have the privilege to call remount on the filesystem.

Hm, that's a good point.  Though note it'll require the userns code to
distinguish between the a bind remount and superblock remount.  The
last time we seriously discussed this, that wasn't even on the roadmap.
It was only going to support fully assigning the whole filesystem to
a user namespace.  In that case, the remount issue doesn't apply anyway
as the fs isn't shared with another container.

In any case, there are other workarounds, so I wasn't in a hurry to
address this - it just should be addressed eventually.  I just figured
that to bring up the issue I needed a patch :)

> I think I will have a set of patches ready for serious scrutiny in
> the next week or so.  So we aren't talking impossible pie in the sky
> distance to see this happen.

Awesome.

thanks,
-serge
