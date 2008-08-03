From: sukadev@us.ibm.com
Subject: Re: Per-instance devpts
Date: Sun, 3 Aug 2008 10:46:46 -0700
Message-ID: <20080803174646.GA20254@us.ibm.com>
References: <20080412172933.GA19295@us.ibm.com> <1208027215.28187.17.camel@x61.ebiederm.org> <48935205.3090807@zytor.com> <20080803050800.GA4322@us.ibm.com> <20080803130439.743ff0ae@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758813AbYHCRtP@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080803130439.743ff0ae@lxorguk.ukuu.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: "H. Peter Anvin" <hpa@zytor.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Andrew Morton <akpm@osdl.org>, serue@us.ibm.com, matthltc@us.ibm.com, Pavel Emelyanov <xemul@openvz.org>, Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org, Greg KH <greg@kroah.com>
List-Id: containers.vger.kernel.org

Alan Cox [alan@lxorguk.ukuu.org.uk] wrote:
| > > 1. /dev/ptmx would have to change to a symlink, ptmx -> pts/ptmx.
| > 
| > IIRC, /dev/tty also needs a similar symlink.
| 
| Making them symlinks is asking for trouble because some code does go
| around using stat and the like and tools like MAKEDEV have definite ideas.
| 
| For /dev/tty the definition is precisely that it is your controlling
| tty. No reference to namespace and a task whose controlling tty is in a
| different namespace should still open the controlling tty not some
| parallel in another universe when you open /dev/tty.

Well, I thought the problem was something like this:

If /dev/pts/1 is the controlling terminal and there are multiple mounts
of devpts, when we open /dev/tty, kernel would somehow have to find the
right instance of devpts.

When init_dev() calls devpts_get_tty(), it would need to specify the devpts
instance. So tty_open() of "/dev/tty" would somehow have to find it based on
the /dev/tty inode (which could be in ext3).

(I thought the issue was similar with /dev/ptmx, ptmx allocates a new
index, /dev/tty accesses an existing index, but both need to somehow
find the right pts instance -no ?)

| 
| If you want to make sure the controlling tty is in the right namespace
| that can be done in userspace when transferring control into a namespace.
| In many cases I doubt that is even what is wanted.
| 
| > > 2. Permissions on /dev/ptmx would not be persistent, and would have to
| > >    be set via devpts mount options (unless they're 0666 root.tty, which
| > >    would presumably be the default.)
| > > 3. The /proc/sys/kernel/pty limit would be global; a per-filesystem
| > >    limit could be added on top or instead (presumably via a filesystem
| > >    mount options.)
| > >
| > > I worry #1 would have substantial user-space impact, but I don't see a way 
| > > around it, since there would be no obvious way to associate /dev/ptmx with 
| > > a filesystem.
| 
| /dev/tty and /dev/ptmx already primarily operate by identifying a device
| and switching the work to that. Actually putting a bit of namespace logic
| in the driver code so the actual files stay as expected (device nodes
| etc) seems a *lot* simpler than trying to do symlink hacks.
| 
| Alan
