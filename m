From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [patch 2/2] fs, proc: Introduce the /proc/<pid>/map_files/
 directory v6
Date: Tue, 6 Sep 2011 00:36:27 +0400
Message-ID: <20110905203627.GL761@sun>
References: <20110831090612.GA3253@albatros>
 <20110831112642.GI25465@sun>
 <20110831140416.GA17626@shutemov.name>
 <20110831142622.GB30615@sun>
 <20110831151023.5b7e12da.akpm@linux-foundation.org>
 <20110901080508.GF30615@sun>
 <20110902163711.GA3124@albatros>
 <20110905185358.GA2103@albatros>
 <20110905192009.GJ761@sun>
 <20110905194908.GA2690@albatros>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110905194908.GA2690@albatros>
Sender: linux-fsdevel-owner@vger.kernel.org
To: Vasiliy Kulikov <segoon@openwall.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, containers@lists.osdl.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, Nathan Lynch <ntl@pobox.com>, kernel-hardening@lists.openwall.com, Oren Laadan <orenl@cs.columbia.edu>, Daniel Lezcano <dlezcano@fr.ibm.com>, Glauber Costa <glommer@parallels.com>, James Bottomley <jbottomley@parallels.com>, Tejun Heo <tj@kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>, Al Viro <viro@ZenIV.linux.org.uk>, Pavel Emelyanov <xemul@parallels.com>
List-Id: containers.vger.kernel.org

On Mon, Sep 05, 2011 at 11:49:08PM +0400, Vasiliy Kulikov wrote:
...
> 
> Actually, it can be speed up by introducing the same ptrace check.  If
> ptrace check fails, then just drop the dentry, otherwise continue to use
> it.  Then each revalidate would trigger ptrace check instead of full
> drop-lookup-alloc cycle.  If one process actively looks into
> map_files/ or fd/, it will not become significantly slower.  However, it
> will trigger 2 capable() fail alerts in ptrace_may_access() instead of
> one :)

Hmm, at least it's better than trashing dcache I think.

> 
> But I still see one very nasty issue - one may trigger this ptrace check,
> trigger d_drop() and then look at /proc/slabinfo at "dentry" row.  If
> the number has changed, then the interested dentry existed before the
> revalidate call.  This infoleak is tricky to fix without any race.
> 
> Probably it's time to close /proc/slabinfo infoleak? 
> 

Actually I miss to see how exactly this infoleak can be used by attacker
or whoever. So, Vasiliy, what the security issue there?

	Cyrill
