From: Greg KH <gregkh@suse.de>
Subject: Re: [PATCH 00/11] sysfs tagged directories V5
Date: Tue, 10 Jun 2008 16:00:58 -0700
Message-ID: <20080610230058.GA25072@suse.de>
References: <20080606154654.356185262@theryb.frec.bull.fr> <20080610225024.GB22478@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758907AbYFJXG7@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080610225024.GB22478@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Cc: Benjamin Thery <benjamin.thery@bull.net>, Andrew Morton <akpm@linux-foundation.org>, Eric Biederman <ebiederm@xmission.com>, linux-kernel@vger.kernel.org, Tejun Heo <htejun@gmail.com>, Al Viro <viro@ftp.linux.org.uk>, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

On Tue, Jun 10, 2008 at 05:50:24PM -0500, Serge E. Hallyn wrote:
> Quoting Benjamin Thery (benjamin.thery@bull.net):
> > Greg,
> > 
> > Here is an updated version of the sysfs tagged directories that improves
> > a bit the situation over the previous one. 
> > 
> > I've modified the patch 09 ("Enable tagging for net_class directories in 
> > sysfs") to be a bit less intrusive in sysfs core. I removed the #ifdef'd
> > parts you didn't like in fs/sysfs/mount.c, and replaced it by a generic 
> > routine sysfs_ns_exit() that is called, if needed, by the namespace when
> > it exits. This routine goes through every sysfs super blocks and calls 
> > the callback passed by the namespace to clean its tag.
> > 
> > The patch is now splitted in two: 
> > * 09/11: the generic routine,
> > * 10/11: the remaining network parts.
> > 
> > The generic part can be merge with patch 05 ("sysfs: Implement sysfs 
> > tagged directory support.") but I left it separate for now to ease 
> > reviews.
> 
> Thanks.  Not nearly as radical as I'd feared.
> 
> Greg, does this address your concern?  It stops the need to put any
> non-braindead code (i.e. the _exit notifier stuff) in fs/sysfs/mount.c for
> any new namespaces needing sysfs tagging, leaving only simple
> comparison/assignments.

Sorry, I've been swamped with other things this week and haven't gotten
a chance to look this over.  Hopefully by the end of the week...  It's
in my queue though, don't worry it will not get lost.

thanks,

greg k-h
