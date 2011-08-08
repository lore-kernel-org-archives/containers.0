From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [patch 2/4] vfs: Introduce the fd closing helper
Date: Mon, 8 Aug 2011 13:54:27 +0400
Message-ID: <20110808095427.GA24017@sun>
References: <20110807210112.245578619@openvz.org>
 <20110807210526.994391865@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110807210526.994391865@openvz.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Nathan Lynch <ntl@pobox.com>, Oren Laadan <orenl@cs.columbia.edu>, Daniel Lezcano <dlezcano@fr.ibm.com>, Serge Hallyn <serue@us.ibm.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akp>
Cc: Glauber Costa <glommer@parallels.com>, containers@lists.osdl.org, linux-kernel@vger.kernel.org, Pavel Emelyanov <xemul@parallels.com>, Serge Hallyn <serge.hallyn@canonical.com>
List-Id: containers.vger.kernel.org

On Mon, Aug 08, 2011 at 01:01:14AM +0400, Cyrill Gorcunov wrote:
> From: Pavel Emelyanov <xemul@parallels.com>
> 
> This is nothing but making is possible to call the
> sys_close from the kernel.
> 
> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
> Acked-by: Serge Hallyn <serge.hallyn@canonical.com>
> Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
> ---

Drop this one for a while.
