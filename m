From: Matt Helsley <matthltc@us.ibm.com>
Subject: Re: [patch 2/2] fs, proc: Introduce the /proc/<pid>/map_files/
 directory v6
Date: Fri, 2 Sep 2011 12:15:10 -0700
Message-ID: <20110902191510.GB27179@count0.beaverton.ibm.com>
References: <20110831080229.100652529@openvz.org>
 <20110831090612.GA3253@albatros>
 <20110831112642.GI25465@sun>
 <20110831140416.GA17626@shutemov.name>
 <20110831142622.GB30615@sun>
 <20110831151023.5b7e12da.akpm@linux-foundation.org>
 <4E5F3B25.9030701@parallels.com>
 <20110901115006.GB2752@htj.dyndns.org>
 <4E5F7702.2070808@parallels.com>
 <20110901171355.GC2752@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110901171355.GC2752@htj.dyndns.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Tejun Heo <tj@kernel.org>
Cc: Pavel Emelyanov <xemul@parallels.com>, Daniel Lezcano <dlezcano@fr.ibm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, James Bottomley <jbottomley@parallels.com>, Cyrill Gorcunov <gorcunov@gmail.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Nathan Lynch <ntl@pobox.com>, Alexey Dobriyan <adobriyan@gmail.com>, "containers@lists.osdl.org" <containers@lists.osdl.org>, Andrew Morton <akpm@linux-foundation.org>, Vasiliy Kulikov <segoon@openwall.com>, Al Viro <viro@ZenIV.linux.org.uk>
List-Id: containers.vger.kernel.org

On Fri, Sep 02, 2011 at 02:13:55AM +0900, Tejun Heo wrote:
> Hello,
> 
> On Thu, Sep 01, 2011 at 04:13:54PM +0400, Pavel Emelyanov wrote:
> > Because with the handler restore process looks very natural and simple - each
> > task does the following steps
> > 
> > 1. restore task resources (open files, set IDs, restore connections, wire back timers, etc.)
> > 2. call execve() to jump into new memory+registers context which is
> >    a. unmap all the user memory
> >    b. map required mappings
> >    c. populate them with data
> >    d. restore registers
> >    e. restore IP
> 
> But what about multiple threads?  exec is already scary enough as it
> is and I don't think it would be wise to overload it for this.
> 
> I don't really think binfmt handler would be able to achieve
> completeness without ending up with full de-serializer in kernel.

Yeah, I think you'd have to remove the de_thread()-based assumptions 
in exec to avoid this. And then there's the can of worms opened by
non-pthread threads where files, signals, etc. may or may not be shared..

> There are a lot of states which already have API to manipulate from
> the userland thread itself and they all will need to be replicated in
> the binfmt handler.  It really has to be full de-serializer if it

Re-creating all possible states from userspace is not necessarily going
to be any prettier. I'd really like to see SEIZE used to restart threaded
tasks before I'll be convinced it's any more or less pretty than a binfmt
handler.

> wants to function like you described.
> 
> And if we're gonna have interventions anyway, I can't see much point
> in implementing something which seems simpler - it's not gonna be
> actually simpler.

You may have lost me here -- I have no idea whether this is a summary
or some new point you're trying to make.

Cheers,
	-Matt Helsley
