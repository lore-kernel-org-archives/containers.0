From: "Kyle Moffett" <kyle@moffetthome.net>
Subject: Re: Per-instance devpts
Date: Sat, 2 Aug 2008 03:06:29 -0400
Message-ID: <f73f7ab80808020006i7f0ac456ve9b9f73568c11294@mail.gmail.com>
References: <20080412172933.GA19295@us.ibm.com>
	 <1208027215.28187.17.camel@x61.ebiederm.org>
	 <48935205.3090807@zytor.com>
	 <f73f7ab80808020004j15b0d0e5x5fa911242641b34d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753664AbYHBHGl@vger.kernel.org>
In-Reply-To: <f73f7ab80808020004j15b0d0e5x5fa911242641b34d@mail.gmail.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, sukadev@us.ibm.com, Andrew Morton <akpm@osdl.org>, serue@us.ibm.com, matthltc@us.ibm.com, Pavel Emelyanov <xemul@openvz.org>, Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org, Alan Cox <alan@lxorguk.ukuu.org.uk>, Greg KH <greg@kroah.com>
List-Id: containers.vger.kernel.org

My apologies, I accidentally hit "reply" instead of "reply all" and
this got sent only to Peter.

On Fri, Aug 1, 2008 at 2:12 PM, H. Peter Anvin <hpa@zytor.com> wrote:
> This is what it would appear would have to change, and I'd like to get
> people's feeing for the user-space impact:
>
> 1. /dev/ptmx would have to change to a symlink, ptmx -> pts/ptmx.
> 2. Permissions on /dev/ptmx would not be persistent, and would have to
>   be set via devpts mount options (unless they're 0666 root.tty, which
>   would presumably be the default.)
> 3. The /proc/sys/kernel/pty limit would be global; a per-filesystem
>   limit could be added on top or instead (presumably via a filesystem
>   mount options.)

Here's my suggestion:

By default, without any mount options, use the current "legacy"
behavior.  The devpts filesystem would point to a "global" instance on
the whole box, controlled by the traditional /dev/ptmx device node.
There would *NOT* be a /dev/pts/ptmx node.

If the devpts filesystem is mounted with a special option ("permount"?
"noglobal"?), then it will create a new devpts instance associated
with the filesystem.  A devpts mounted that way *WILL* have a magic
/dev/pts/ptmx node.

If the kernel is built with CONFIG_DEVPTS_FORCE_PERMOUNT then the
traditional /dev/ptmx device node will be neutered (IE: always return
-ENODEV) and the "permount" option will be forced for all devpts
mounts.  This will also remove the static global devpts instance.

Once distros add the ptmx=>pts/ptmx symlink and validate their
software they can turn on that config option and be able to safely
virtualize /dev/pts.

For the distros which don't, sysadmins can easily patch their own udev
and init scripts to turn on the "permount" option and set up the ptmx
symlink, although child namespaces will still theoretically be able to
get outside of their namespace through the mostly-unused global devpts
instance.

Cheers,
Kyle Moffett
