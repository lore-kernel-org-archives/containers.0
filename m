From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [RFC] fs, proc: Introduce the /proc/<pid>/map_files/ directory v2
Date: Thu, 25 Aug 2011 18:30:04 +0400
Message-ID: <20110825143004.GC3455@sun>
References: <20110824085329.GL29452@sun>
 <4E551331.1010709@acm.org>
 <4E551693.5030400@parallels.com>
 <m2wre2d83p.fsf@firstfloor.org>
 <4E55EEE4.4050902@parallels.com>
 <20110825140434.GU25996@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110825140434.GU25996@one.firstfloor.org>
Sender: linux-fsdevel-owner@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Pavel Emelyanov <xemul@parallels.com>, Zan Lynx <zlynx@acm.org>, Nathan Lynch <ntl@pobox.com>, Oren Laadan <orenl@cs.columbia.edu>, Daniel Lezcano <dlezcano@fr.ibm.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Glauber Costa <glommer@parallels.com>, "containers@lists.osdl.org" <containers@lists.osdl.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Serge Hallyn <serge.hallyn@canonical.com>, LINUXFS-ML <linux-fsdevel@vger.kernel.org>, James Bottomley <jbottomley@parallels.com>
List-Id: containers.vger.kernel.org

On Thu, Aug 25, 2011 at 04:04:35PM +0200, Andi Kleen wrote:
...
> > > 
> > > For example if I pass a file descriptor into a chroot process for
> > > reading, and with this interface you can open it for writing too.
> > > I could see this causing problems.
> > 
> > How does it differ from the /proc/pid/fd links?
> 
> Those cannot be opened I thought.
> -Andi
> 

We have ptrace_may_access in lookup so I don't think you'll be
able to open it from another namespace or/and if you have not
enough credentials to.

	Cyrill
