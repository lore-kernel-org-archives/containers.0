From: Bastian Blank <bastian@waldi.eu.org>
Subject: Re: Per-instance devpts
Date: Sat, 2 Aug 2008 10:54:43 +0200
Message-ID: <20080802085443.GA7817@wavehammer.waldi.eu.org>
References: <20080412172933.GA19295@us.ibm.com> <1208027215.28187.17.camel@x61.ebiederm.org> <48935205.3090807@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754754AbYHBIy5@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <48935205.3090807@zytor.com>
Sender: linux-kernel-owner@vger.kernel.org
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, Greg KH <greg@kroah.com>, linux-kernel@vger.kernel.org, Containers <containers@lists.osdl.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Pavel Emelyanov <xemul@openvz.org>
List-Id: containers.vger.kernel.org

On Fri, Aug 01, 2008 at 11:12:21AM -0700, H. Peter Anvin wrote:
> 2. Permissions on /dev/ptmx would not be persistent, and would have to
>     be set via devpts mount options (unless they're 0666 root.tty, which
>     would presumably be the default.)

On Debian based systems /dev/ptmx is 0666 root.root.  But the gid of tty
is already supplied for devpts.

> I worry #1 would have substantial user-space impact, but I don't see a 
> way around it, since there would be no obvious way to associate 
> /dev/ptmx with a filesystem.

Hmm. Several possibilities:
- Change the filesysteme name and the old name remains usable with
  /dev/ptmx.
  Problem: You could mount the filesystem with the old name within a
  container.
- Make the first mounted one special. 
  Problem: Will not survive a umount/mount cycle. But this would be not
  the case anyway.

But you are sure, none of them is a pretty solution.

Bastian

-- 
I'm a soldier, not a diplomat.  I can only tell the truth.
		-- Kirk, "Errand of Mercy", stardate 3198.9
