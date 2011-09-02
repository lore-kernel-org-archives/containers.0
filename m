From: Vasiliy Kulikov <segoon@openwall.com>
Subject: Re: [patch 2/2] fs, proc: Introduce the /proc/<pid>/map_files/
 directory v6
Date: Fri, 2 Sep 2011 20:37:11 +0400
Message-ID: <20110902163711.GA3124@albatros>
References: <20110831075814.003575573@openvz.org>
 <20110831080229.100652529@openvz.org>
 <20110831090612.GA3253@albatros>
 <20110831112642.GI25465@sun>
 <20110831140416.GA17626@shutemov.name>
 <20110831142622.GB30615@sun>
 <20110831151023.5b7e12da.akpm@linux-foundation.org>
 <20110901080508.GF30615@sun>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110901080508.GF30615@sun>
Sender: linux-kernel-owner@vger.kernel.org
To: Cyrill Gorcunov <gorcunov@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, containers@lists.osdl.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, Nathan Lynch <ntl@pobox.com>, kernel-hardening@lists.openwall.com, Oren Laadan <orenl@cs.columbia.edu>, Daniel Lezcano <dlezcano@fr.ibm.com>, Glauber Costa <glommer@parallels.com>, James Bottomley <jbottomley@parallels.com>, Tejun Heo <tj@kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>, Al Viro <viro@ZenIV.linux.org.uk>, Pavel Emelyanov <xemul@parallels.com>
List-Id: containers.vger.kernel.org

Hi,

On Thu, Sep 01, 2011 at 12:05 +0400, Cyrill Gorcunov wrote:
> ...
> > > +/*
> > > + * NOTE: The getattr/setattr for both /proc/$pid/map_files and
> > > + * /proc/$pid/fd seems to have share the code, so need to be
> > > + * unified and code duplication eliminated!
> > 
> > Why not do this now?
> 
> There are a couple of reasons. Yesterday I was talking to
> Vasiliy Kulikov about this snippet, so he seems about to send
> you patches related to /proc/$pid/fd update, and after those
> patches will be merged we are to drop code duplication.
> Vasiliy, what the status of the update?

It looks like protecting directories with sensible contents is a nasty
thing.  The problem here is that if the dentry is present in the cache,
->lookup() is not called at all and the permissions can be checked in
fop/dop/iop specific handler (getattr(), readlink(), etc.).  However, it
would be much simplier to hook ->lookup() only.  Otherwise, we have to
define procfs handlers for all operations, which don't call
->d_revalidate().

Is it possible to disable caching dentry for specific files?  It is not
performace critical thing in fd and map_files and it would much simplify
the task.  Creating handlers for all these op handler bloats procfs.

Also I'm not sure what other handlers might reveal dentry presence.
Besides ->getattr() I could find only one thing - ->link() (Cyrill,
AFAICS ->setattr() doesn't reveal files' presence).  Someone more
familiar with vfs than me - please, help to identify all infoleak
sources!


Thank you,

-- 
Vasiliy Kulikov
http://www.openwall.com - bringing security into open computing environments
