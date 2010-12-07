From: "Serge E. Hallyn" <serge.hallyn@canonical.com>
Subject: Re: [PATCH] user_ns: Improve the user_ns on-the-slab packaging
Date: Tue, 7 Dec 2010 08:50:43 -0600
Message-ID: <20101207145043.GD4674@hallyn.com>
References: <4CFE40D1.5000309@parallels.com>
 <20101207142747.GB4674@hallyn.com>
 <4CFE45A0.8070408@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4CFE45A0.8070408@parallels.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Pavel Emelyanov <xemul@parallels.com>
Cc: "Serge E. Hallyn" <serge.hallyn@canonical.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Containers <containers@lists.osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-Id: containers.vger.kernel.org

Quoting Pavel Emelyanov (xemul@parallels.com):
> On 12/07/2010 05:27 PM, Serge E. Hallyn wrote:
> > Quoting Pavel Emelyanov (xemul@parallels.com):
> >> Currently on 64-bit arch the user_namespace is 2096 and when
> >> being kmalloc-ed it resides on a 4k slab wasting 2003 bytes.
> >>
> >> If we allocate a separate cache for it and reduce the hash size
> >> from 128 to 64 chains the packaging becomes *much* better - the
> > 
> > Hey Pavel,
> > 
> > I trust you've done some performance tests and found no
> > regressions with a few hundred users?
> 
> How many hundreds are you interested in? :) 128 users didn't
> reveal any regressions.

I have no good guess, would have said 500, 128 sounds good :)  So
long as actual benchmarks showed no regression within a 95%
confidence interval.

Thanks for the patch, the memory savings are impressive.

Acked-by: Serge E. Hallyn <serge@hallyn.com>

-serge

PS - I'm hoping to send out a version of the targeted capabilities
(based on userns) patchset later this week.
