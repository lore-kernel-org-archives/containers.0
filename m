From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [patch 1/4] proc: Introduce the /proc/<pid>/mfd/ directory
Date: Mon, 8 Aug 2011 01:11:54 +0400
Message-ID: <20110807211154.GF2080@sun>
References: <20110807210112.245578619@openvz.org>
 <20110807210526.741513583@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110807210526.741513583@openvz.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Tejun Heo <tj@kernel.org>
Cc: Nathan Lynch <ntl@pobox.com>, Oren Laadan <orenl@cs.columbia.edu>, Daniel Lezcano <dlezcano@fr.ibm.com>, Serge Hallyn <serue@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Glauber Costa <glommer@parallels.com>, containers@lists.osdl.org, linux-kernel@vger.kernel.org, Pavel Emelyanov <xemul@parallels.com>, Serge Hallyn <serge.hallyn@canonical.com>
List-Id: containers.vger.kernel.org

On Mon, Aug 08, 2011 at 01:01:13AM +0400, Cyrill Gorcunov wrote:
> From: Pavel Emelyanov <xemul@parallels.com>
> 
> This one behaves similarly to the /proc/<pid>/fd/ one - it contains symlinks
> one for each mapping with file, the name of a symlink is vma->vm_start, the
> target is the file. Opening a symlink results in a file that point exactly
> to the same inode as them vma's one.
> 
> This thing is aimed to help checkpointing processes.
> 
> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
> Reviewed-by: Tejun Heo <tj@kernel.org>

Ouch, Tejun, I occasionally put your Reviewed-by tag to the wrong patch :/
Sorry. 

> Acked-by: Serge Hallyn <serge.hallyn@canonical.com>
> Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
> ---
