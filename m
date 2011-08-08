From: Tejun Heo <tj@kernel.org>
Subject: Re: [patch 2/4] vfs: Introduce the fd closing helper
Date: Mon, 8 Aug 2011 16:39:42 +0200
Message-ID: <20110808143942.GA22863@htj.dyndns.org>
References: <20110807210112.245578619@openvz.org>
 <20110807210526.994391865@openvz.org>
 <20110808095427.GA24017@sun>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110808095427.GA24017@sun>
Sender: linux-kernel-owner@vger.kernel.org
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Nathan Lynch <ntl@pobox.com>, Oren Laadan <orenl@cs.columbia.edu>, Daniel Lezcano <dlezcano@fr.ibm.com>, Serge Hallyn <serue@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Glauber Costa <glommer@parallels.com>, containers@lists.osdl.org, linux-kernel@vger.kernel.org, Pavel Emelyanov <xemul@parallels.com>, Serge Hallyn <serge.hallyn@canonical.com>
List-Id: containers.vger.kernel.org

On Mon, Aug 08, 2011 at 01:54:27PM +0400, Cyrill Gorcunov wrote:
> On Mon, Aug 08, 2011 at 01:01:14AM +0400, Cyrill Gorcunov wrote:
> > From: Pavel Emelyanov <xemul@parallels.com>
> > 
> > This is nothing but making is possible to call the
> > sys_close from the kernel.
> > 
> > Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
> > Acked-by: Serge Hallyn <serge.hallyn@canonical.com>
> > Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
> > ---
> 
> Drop this one for a while.

Yeah, I don't see why this would be necessary.

Thanks.

-- 
tejun
