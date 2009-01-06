From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 1/6] proc: implement support for automounts in task
	directories
Date: Tue, 6 Jan 2009 04:21:14 -0500
Message-ID: <20090106092114.GA11877@infradead.org>
References: <20090105233241.GA3924@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754155AbZAFJVl@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090105233241.GA3924@x200.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Cc: ebiederm@xmission.com, viro@zeniv.linux.org.uk, linux-kernel@vger.kernel.org, containers@lists.osdl.org, sds@tycho.nsa.gov, jmorris@namei.org
List-Id: containers.vger.kernel.org

On Tue, Jan 06, 2009 at 02:32:41AM +0300, Alexey Dobriyan wrote:
> This is current version of /proc/net as separate file system patchset,
> rebased, etc. I'll put it into -next again when merge window closes.

I still don't see the point for that.  Why not /proc/nets/<netid> with
symlinks from /proc/<pid>/net into those?
