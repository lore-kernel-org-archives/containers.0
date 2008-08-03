From: sukadev@us.ibm.com
Subject: Re: Per-instance devpts
Date: Sat, 2 Aug 2008 22:08:00 -0700
Message-ID: <20080803050800.GA4322@us.ibm.com>
References: <20080412172933.GA19295@us.ibm.com> <1208027215.28187.17.camel@x61.ebiederm.org> <48935205.3090807@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755685AbYHCFK0@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <48935205.3090807@zytor.com>
Sender: linux-kernel-owner@vger.kernel.org
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, Andrew Morton <akpm@osdl.org>, serue@us.ibm.com, matthltc@us.ibm.com, Pavel Emelyanov <xemul@openvz.org>, Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org, Alan Cox <alan@lxorguk.ukuu.org.uk>, Greg KH <greg@kroah.com>, sukadev@us.ibm.com
List-Id: containers.vger.kernel.org

H. Peter Anvin [hpa@zytor.com] wrote:
> Since the issue of PTY namespaces came up (and was rejected) back in April, 
> I have thought a little bit about changing ptys to be tied directly into a 
> devpts instance.  devpts would then be a "normal" filesystem, which can be 
> mounted multiple times (or not at all).  pty's would then become private to 
> a devpts instance.

Sorry, I thought we were going with a complete device namespace - since that
would address other devices as well and would avoid the following user-space
issue. 

I guess this issue came up in OLS recently and have been looking into this
again.  I have some helper patches to explore multiple mounts of devpts
without namespace stuff and can send them out in a couple of days.

>
> This is what it would appear would have to change, and I'd like to get 
> people's feeing for the user-space impact:
>
> 1. /dev/ptmx would have to change to a symlink, ptmx -> pts/ptmx.

IIRC, /dev/tty also needs a similar symlink.

> 2. Permissions on /dev/ptmx would not be persistent, and would have to
>    be set via devpts mount options (unless they're 0666 root.tty, which
>    would presumably be the default.)
> 3. The /proc/sys/kernel/pty limit would be global; a per-filesystem
>    limit could be added on top or instead (presumably via a filesystem
>    mount options.)
>
> I worry #1 would have substantial user-space impact, but I don't see a way 
> around it, since there would be no obvious way to associate /dev/ptmx with 
> a filesystem.

Sukadev
