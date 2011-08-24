From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [RFC] fs, proc: Introduce the /proc/<pid>/map_files/ directory v2
Date: Wed, 24 Aug 2011 15:31:00 +0400
Message-ID: <20110824113100.GR29452@sun>
References: <20110824085329.GL29452@sun>
 <20110824111806.GA7191@albatros>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110824111806.GA7191@albatros>
Sender: linux-kernel-owner@vger.kernel.org
To: Vasiliy Kulikov <segoon@openwall.com>
Cc: Nathan Lynch <ntl@pobox.com>, Oren Laadan <orenl@cs.columbia.edu>, Daniel Lezcano <dlezcano@fr.ibm.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelyanov <xemul@parallels.com>, linux-kernel@vger.kernel.org, James Bottomley <jbottomley@parallels.com>, LINUXFS-ML <linux-fsdevel@vger.kernel.org>, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

On Wed, Aug 24, 2011 at 03:18:06PM +0400, Vasiliy Kulikov wrote:
...
> 
> You have no ptrace_may_access() check in ->lookup(), only in ->readdir().
> 

Thanks Vasiliy! I'm reworking it anyway ;)

	Cyrill
