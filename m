From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [RFC] fs, proc: Introduce the /proc/<pid>/map_files/ directory v2
Date: Fri, 26 Aug 2011 10:58:57 +0400
Message-ID: <20110826065857.GC3903@sun>
References: <20110824085329.GL29452@sun>
 <20110824111806.GA7191@albatros>
 <20110825082944.GH10030@sun>
 <20110825170147.GM2803@mtj.dyndns.org>
 <20110825170705.GA6387@sun>
 <20110825205426.GO2803@mtj.dyndns.org>
 <20110825211213.GP2803@mtj.dyndns.org>
 <20110825213459.GA1929@sun>
 <20110825213931.GR2803@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110825213931.GR2803@mtj.dyndns.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Tejun Heo <tj@kernel.org>
Cc: Vasiliy Kulikov <segoon@openwall.com>, Nathan Lynch <ntl@pobox.com>, Oren Laadan <orenl@cs.columbia.edu>, Daniel Lezcano <dlezcano@fr.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelyanov <xemul@parallels.com>, linux-kernel@vger.kernel.org, James Bottomley <jbottomley@parallels.com>, LINUXFS-ML <linux-fsdevel@vger.kernel.org>, containers@lists.osdl.org, Zan Lynx <zlynx@acm.org>, Andi Kleen <andi@firstfloor.org>
List-Id: containers.vger.kernel.org

On Thu, Aug 25, 2011 at 11:39:31PM +0200, Tejun Heo wrote:
> Hello,
> 
> On Fri, Aug 26, 2011 at 01:34:59AM +0400, Cyrill Gorcunov wrote:
> > > Unfortunately, not quite as easy as I expected.  The information still
> > > seems redundant but it seems we'll need to change
> > > proc_inode->get_link() to take dentry instead of inode before doing
> > > away with proc_inode->fd, but, at any rate, I don't think this is a
> > > big deal one way or the other.
> > 
> > Hohum... picking up an additional reference to dentry might be dangerous
> > I think. How exactly you imagine we would do that? (without this problem
> > I guess we indeed may drop or rather not change proc-inode).
> 
> Why would you need an extra reference?  All these data structures are
> created dynamically on access and dentry is always available while any
> operation on the inode is in progress so it's guaranteed to be
> available and there's no reason to diddle with reference count.
> Anyways, we can deal with this optimization later, I think.
> 

Hi Tejun, yeah, I somehow missed that you propose to lift up
proc_get_link a bit. Letme try such approach indeed. Thanks!

	Cyrill
