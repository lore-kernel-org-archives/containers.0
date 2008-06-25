From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 11/11] sysfs: user namespaces: fix bug with
	clone(CLONE_NEWUSER) with fairsched
Date: Wed, 25 Jun 2008 13:44:09 -0500
Message-ID: <20080625184409.GA8353@us.ibm.com>
References: <20080618170729.808539948@theryb.frec.bull.fr> <20080618170731.746054454@theryb.frec.bull.fr> <485F0812.4090903@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757545AbYFYSoi@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <485F0812.4090903@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Tejun Heo <htejun@gmail.com>
Cc: Benjamin Thery <benjamin.thery@bull.net>, Greg Kroah-Hartman <gregkh@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Eric Biederman <ebiederm@xmission.com>, Daniel Lezcano <dlezcano@fr.ibm.com>, Serge Hallyn <serue@us.ibm.com>, linux-kernel@vger.kernel.org, Al Viro <viro@ftp.linux.org.uk>, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

Quoting Tejun Heo (htejun@gmail.com):
> Benjamin Thery wrote:
> > Mark the /sys/kernel/uids directory to be tagged so that processes in
> > different user namespaces can remount /sys and see their own uid
> > listings.
> > 
> > Without this patch, having CONFIG_FAIR_SCHED=y makes user namespaces
> > unusable, because when you 
> >   clone(CLONE_NEWUSER)
> > it will auto-create the root userid and try to create
> > /sys/kernel/uids/0.  Since that already exists from the parent user
> > namespace, the create fails, and the clone misleadingly ends up
> > returning -ENOMEM.
> > 
> > This patch fixes the issue by allowing each user namespace to remount
> > /sys, and having /sys filter the /sys/kernel/uid/ entries by user
> > namespace.
> > 
> > Signed-off-by: Serge Hallyn <serue@us.ibm.com>
> > Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
> 
> Ditto as patch #10.

Except the sysfs mount holds no refcount on the userns.  So as long as we
do the ida tagging as you suggested in your response to patch 6, there
should be no reference to the user_ns left in sysfs code.

The extra reference in patch #9 is for a light ref on the network
namespace.  I'm still not sure that needs to be there, since if the
network namespace goes away, it will properly unregister its sysfs
mounts.  Eric, Benjamin, I really don't see any use for the hold_net()
from sysfs.  What is it doing?

-serge
