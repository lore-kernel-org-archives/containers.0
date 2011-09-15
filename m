From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [patch 2/2] fs, proc: Introduce the /proc/<pid>/map_files/
 directory v12
Date: Thu, 15 Sep 2011 14:29:22 +0400
Message-ID: <20110915102922.GB27755@sun>
References: <20110913235222.043927b3.akpm@linux-foundation.org>
 <20110914105607.GP25367@sun>
 <20110914111437.GA22516@atrey.karlin.mff.cuni.cz>
 <20110914113912.GQ25367@sun>
 <20110914134405.GV25367@sun>
 <20110914144841.GA7906@albatros>
 <20110914160018.GW25367@sun>
 <20110914160724.GA10612@albatros>
 <20110915091417.GA27755@sun>
 <20110915092757.GA23404@albatros>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110915092757.GA23404@albatros>
Sender: linux-kernel-owner@vger.kernel.org
To: Vasiliy Kulikov <segoon@openwall.com>
Cc: Pavel Machek <pavel@ucw.cz>, Andrew Morton <akpm00@gmail.com>, linux-kernel@vger.kernel.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Kirill Shutemov <kirill@shutemov.name>, Pavel Emelyanov <xemul@parallels.com>, James Bottomley <jbottomley@parallels.com>, Nathan Lynch <ntl@pobox.com>, Zan Lynx <zlynx@acm.org>, Daniel Lezcano <dlezcano@fr.ibm.com>, Tejun Heo <tj@kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>, Al Viro <viro@ZenIV.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>
List-Id: containers.vger.kernel.org

On Thu, Sep 15, 2011 at 01:27:57PM +0400, Vasiliy Kulikov wrote:
...
> 
> > in case two of them has a mapping shared, we map
> >    the memory by the 1st one and then open its /proc/$pid/map_files/address file and
> >    map it by the 2nd task.
> 
> How can you restore a set of processes in case they share an RW mapping
> as RW in both tasks if you deny opening /proc/$pid/map_files/$address as W?

I can read the link first to figure out the file path and re-open it as rw via
path itself (which implies the restorer still must have enough rights to open
it as rw).

> 
> > Using /proc/$pid/maps for this is quite inconvenient since it brings repeatable
> > re-reading and reparsing for this text file which slows down restore procesure
> > significantly. Also as being pointed in (3) it is a way easier to use top level
> > shared mapping in children as /proc/$pid/map_files/address when needed.
> [...]
> > v14: (by Vasiliy Kulikov)
> >  - for security reason the links are created with FMODE_READ mode
> >    only even if the former file has FMODE_WRITE
> >  - proc_map_files_lookup fails on any non-read-only queries.
> 
> Do you have a PoC of the dumper?  At least without the restorer.  If we
> see an implementation of map_files/ user we probably identify what
> operation it needs and what security restrictions we have to define.

Yeah, i'll ping you the link (while beign trying various approaches
the code end up in being a pure mess, so until all cleaned up and
works as expected i'll not public it).

	Cyrill
