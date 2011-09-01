From: Tejun Heo <tj@kernel.org>
Subject: Re: [patch 2/2] fs, proc: Introduce the /proc/<pid>/map_files/
 directory v6
Date: Fri, 2 Sep 2011 02:13:55 +0900
Message-ID: <20110901171355.GC2752@htj.dyndns.org>
References: <20110831075814.003575573@openvz.org>
 <20110831080229.100652529@openvz.org>
 <20110831090612.GA3253@albatros>
 <20110831112642.GI25465@sun>
 <20110831140416.GA17626@shutemov.name>
 <20110831142622.GB30615@sun>
 <20110831151023.5b7e12da.akpm@linux-foundation.org>
 <4E5F3B25.9030701@parallels.com>
 <20110901115006.GB2752@htj.dyndns.org>
 <4E5F7702.2070808@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4E5F7702.2070808@parallels.com>
Sender: linux-fsdevel-owner@vger.kernel.org
To: Pavel Emelyanov <xemul@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Cyrill Gorcunov <gorcunov@gmail.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Vasiliy Kulikov <segoon@openwall.com>, "containers@lists.osdl.org" <containers@lists.osdl.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Nathan Lynch <ntl@pobox.com>, Oren Laadan <orenl@cs.columbia.edu>, Daniel Lezcano <dlezcano@fr.ibm.com>, Glauber Costa <glommer@parallels.com>, James Bottomley <jbottomley@parallels.com>, Alexey Dobriyan <adobriyan@gmail.com>, Al Viro <viro@ZenIV.linux.org.uk>
List-Id: containers.vger.kernel.org

Hello,

On Thu, Sep 01, 2011 at 04:13:54PM +0400, Pavel Emelyanov wrote:
> Because with the handler restore process looks very natural and simple - each
> task does the following steps
> 
> 1. restore task resources (open files, set IDs, restore connections, wire back timers, etc.)
> 2. call execve() to jump into new memory+registers context which is
>    a. unmap all the user memory
>    b. map required mappings
>    c. populate them with data
>    d. restore registers
>    e. restore IP

But what about multiple threads?  exec is already scary enough as it
is and I don't think it would be wise to overload it for this.

I don't really think binfmt handler would be able to achieve
completeness without ending up with full de-serializer in kernel.
There are a lot of states which already have API to manipulate from
the userland thread itself and they all will need to be replicated in
the binfmt handler.  It really has to be full de-serializer if it
wants to function like you described.

And if we're gonna have interventions anyway, I can't see much point
in implementing something which seems simpler - it's not gonna be
actually simpler.

Thanks.

-- 
tejun
