From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH] Send quota messages via netlink
Date: Wed, 29 Aug 2007 08:57:09 -0700
Message-ID: <20070829085709.8deaaa4e.randy.dunlap@oracle.com>
References: <20070828141318.GC5869@duck.suse.cz>
	<20070828211335.37fce4c9.akpm@linux-foundation.org>
	<20070829122647.GB7814@duck.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759650AbXH2P7o@vger.kernel.org>
In-Reply-To: <20070829122647.GB7814@duck.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Balbir Singh <balbir@in.ibm.com>, "Serge E. Hallyn" <serue@us.ibm.com>, "Eric W. Biederman" <ebiederm@xmission.com>, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

On Wed, 29 Aug 2007 14:26:47 +0200 Jan Kara wrote:

> On Tue 28-08-07 21:13:35, Andrew Morton wrote:
> > On Tue, 28 Aug 2007 16:13:18 +0200 Jan Kara <jack@suse.cz> wrote:
> > 
> > >   Hello,
> > > 
> > >   I'm sending rediffed patch implementing sending of quota messages via netlink
> > > interface (some rationale in patch description). I've already posted it to
> > > LKML some time ago and there were no objections, so I guess it's fine to put
> > > it to -mm. Andrew, would you be so kind? Thanks.
> > >   Userspace deamon reading the messages from the kernel and sending them to
> > > dbus and/or user console is also written (it's part of quota-tools). The
> > > only remaining problem is there are a few changes needed to libnl needed for
> > > the userspace daemon. They were basically acked by the maintainer but it
> > > seems he has not merged the patches yet. So this will take a bit more time.
> > > 
> > 
> > So it's a new kernel->userspace interface.
> > 
> > But we have no description of the interface :(
>   Oops, forgotten about it. I'll write one. Do we have some standard place
> where to document such interfaces? I could create some file in
> Documentation/filesystems/ but that seems a bit superfluous...

It looks like other quota documentation is in Documentation/filesystems/,
and that seems reasonable to me for the other quota docs & this one.

---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
