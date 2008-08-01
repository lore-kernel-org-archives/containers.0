From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: Per-instance devpts
Date: Fri, 1 Aug 2008 20:35:05 +0100
Message-ID: <20080801193505.GS28946@ZenIV.linux.org.uk>
References: <20080412172933.GA19295@us.ibm.com> <1208027215.28187.17.camel@x61.ebiederm.org> <48935205.3090807@zytor.com> <1217618624.20260.50.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758259AbYHATfm@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1217618624.20260.50.camel@nimitz>
Sender: linux-kernel-owner@vger.kernel.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Greg KH <greg@kroah.com>, linux-kernel@vger.kernel.org, Containers <containers@lists.osdl.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Pavel Emelyanov <xemul@openvz.org>
List-Id: containers.vger.kernel.org

On Fri, Aug 01, 2008 at 12:23:44PM -0700, Dave Hansen wrote:
> On Fri, 2008-08-01 at 11:12 -0700, H. Peter Anvin wrote:
> > 1. /dev/ptmx would have to change to a symlink, ptmx -> pts/ptmx.
> ...
> > I worry #1 would have substantial user-space impact, but I don't see a 
> > way around it, since there would be no obvious way to associate 
> > /dev/ptmx with a filesystem.
> 
> Are your worries just about replacing what is now a normal file with a
> symlink, and the behavioral changes that come with that?  
> 
> I wonder if using a bind mount for the file would be more robust.  We
> wouldn't, of course, be able to do it persistently, but I bet it would
> be something we could count on udev to do for us.

Not on my boxen.  However, devpts tends to be mounted by initscripts,
which is where one would naturally do that.
