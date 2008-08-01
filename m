From: Dave Hansen <dave@linux.vnet.ibm.com>
Subject: Re: Per-instance devpts
Date: Fri, 01 Aug 2008 12:23:44 -0700
Message-ID: <1217618624.20260.50.camel@nimitz>
References: <20080412172933.GA19295@us.ibm.com>
	 <1208027215.28187.17.camel@x61.ebiederm.org>  <48935205.3090807@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758009AbYHATX7@vger.kernel.org>
In-Reply-To: <48935205.3090807@zytor.com>
Sender: linux-kernel-owner@vger.kernel.org
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, Greg KH <greg@kroah.com>, linux-kernel@vger.kernel.org, Containers <containers@lists.osdl.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Pavel Emelyanov <xemul@openvz.org>
List-Id: containers.vger.kernel.org

On Fri, 2008-08-01 at 11:12 -0700, H. Peter Anvin wrote:
> 1. /dev/ptmx would have to change to a symlink, ptmx -> pts/ptmx.
...
> I worry #1 would have substantial user-space impact, but I don't see a 
> way around it, since there would be no obvious way to associate 
> /dev/ptmx with a filesystem.

Are your worries just about replacing what is now a normal file with a
symlink, and the behavioral changes that come with that?  

I wonder if using a bind mount for the file would be more robust.  We
wouldn't, of course, be able to do it persistently, but I bet it would
be something we could count on udev to do for us.

-- Dave
