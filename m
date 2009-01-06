From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 1/6] proc: implement support for automounts in task directories
Date: Tue, 06 Jan 2009 04:20:55 -0800
Message-ID: <m1vdss1v88.fsf@frodo.ebiederm.org>
References: <20090105233241.GA3924@x200.localdomain>
	<20090106092114.GA11877@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753234AbZAFM1x@vger.kernel.org>
In-Reply-To: <20090106092114.GA11877@infradead.org> (Christoph Hellwig's
	message of "Tue, 6 Jan 2009 04:21:14 -0500")
Sender: linux-kernel-owner@vger.kernel.org
To: Christoph Hellwig <hch@infradead.org>
Cc: Alexey Dobriyan <adobriyan@gmail.com>, viro@zeniv.linux.org.uk, linux-kernel@vger.kernel.org, containers@lists.osdl.org, sds@tycho.nsa.gov, jmorris@namei.org
List-Id: containers.vger.kernel.org

Christoph Hellwig <hch@infradead.org> writes:

> On Tue, Jan 06, 2009 at 02:32:41AM +0300, Alexey Dobriyan wrote:
>> This is current version of /proc/net as separate file system patchset,
>> rebased, etc. I'll put it into -next again when merge window closes.
>
> I still don't see the point for that.  Why not /proc/nets/<netid> with
> symlinks from /proc/<pid>/net into those?

Simple really.

/proc/nets/<netid> is the other possible viable solution.  Where netid
is some pid value that we assign to the network namespace during
unshare or clone.  While there is precedent of using a pid value
to identify a process group or a session it is a bit of a stretch
to have it cover a namespace.

When I talked it over with Al his preference was to for the
current approach, and it happens to be my preference as well.

It gives more control of naming policy to user space allowing us to
avoid the maintenance pain that is sysfs where user space depends upon
a fixed kernel naming policy (which makes change hard).

It gives us a guarantee that we only have a single dentry tree for
any given network namespace.

It allows us to eventually separate out maintenance of proc/generic
and proc/net, as inherently they have nothing in common.

The only cost of this is that we actually use one of the rare but
fully supported vfs features, on demand submounts.

Beyond that proc has wanted to be several filesystems for ages, and doing
it this way allows us to actually start splitting proc up without breaking
backwards compatibility with out existing user space.

Eric
