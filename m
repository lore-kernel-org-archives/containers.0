From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [patch 2/2] fs, proc: Introduce the /proc/<pid>/map_files/
 directory v6
Date: Fri, 9 Sep 2011 09:48:19 +0400
Message-ID: <20110909054819.GN28162@sun>
References: <20110906173341.GM18425@mtj.dyndns.org>
 <20110907112301.GA12157@albatros>
 <20110907215329.GB28162@sun>
 <20110907151323.613e62e7.akpm@linux-foundation.org>
 <20110907224234.GD28162@sun>
 <20110907155332.beda7d3d.akpm@linux-foundation.org>
 <20110908054826.GF28162@sun>
 <20110908055025.GG28162@sun>
 <20110908060405.GH28162@sun>
 <20110908165201.59e82c71.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110908165201.59e82c71.akpm@linux-foundation.org>
Sender: linux-fsdevel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vasiliy Kulikov <segoon@openwall.com>, Tejun Heo <tj@kernel.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, containers@lists.osdl.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, Nathan Lynch <ntl@pobox.com>, kernel-hardening@lists.openwall.com, Oren Laadan <orenl@cs.columbia.edu>, Daniel Lezcano <dlezcano@fr.ibm.com>, Glauber Costa <glommer@parallels.com>, James Bottomley <jbottomley@parallels.com>, Alexey Dobriyan <adobriyan@gmail.com>, Al Viro <viro@ZenIV.linux.org.uk>, Pavel Emelyanov <xemul@parallels.com>
List-Id: containers.vger.kernel.org

On Thu, Sep 08, 2011 at 04:52:01PM -0700, Andrew Morton wrote:
> On Thu, 8 Sep 2011 10:04:05 +0400
> Cyrill Gorcunov <gorcunov@gmail.com> wrote:
> 
> > fs, proc: Introduce the /proc/<pid>/map_files/ directory v11
> 
> Ho hum, I've pretty much run out of excuses to avoid merging this.
> 
> except...
> 
> We don't really want to bloat fs/proc/base.o by 4k until all the other
> things which support c/r are mergeable and we know that the whole
> project is actually useful.  When will we be at this stage?

I hope we will bring in a final set in a couple of weeks.

> 
> <looks at the warning>
> 
> fs/proc/base.c: In function 'proc_map_files_instantiate':
> fs/proc/base.c:2348: warning: assignment from incompatible pointer type
> 
> err, that code will crash at runtime and it isn't trivial to fix. 
> How could this happen?
> 

Hmm. I never saw this warning. (Andrew, I'm still unable to fetch
your current -mm tree, is there some place other than kernel.org?
So the patch is done on top of 3.1-rc3). I guess this warrning is
from p = flex_array_get(fa, i); ? (since I don't have any warning
at all).

> >
> > ...
> >
> > +				if (fa)
> > +					flex_array_free(fa);
> >
> > ...
> >
> > +		if (fa)
> > +			flex_array_free(fa);
> 
> I think I'll do this:
> 
> From: Andrew Morton <akpm@linux-foundation.org>
> 
> Lots of callers are avoiding passing NULL into flex_array_free().  Move
> the check into flex_array_free() in the usual fashion.
> 
> Cc: Stephen Smalley <sds@tycho.nsa.gov>
> Cc: James Morris <jmorris@namei.org>
> Cc: Cyrill Gorcunov <gorcunov@gmail.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---

Yeah, great. Moreover, flex_array_free calls for kfree which
support NULL argument so it's natural to make this one NULL
capable as well.

	Cyrill
