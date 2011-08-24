From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC] fs, proc: Introduce the /proc/<pid>/map_files/ directory v2
Date: Wed, 24 Aug 2011 11:34:31 +0200
Message-ID: <20110824093431.GA3286@htj.dyndns.org>
References: <20110824085329.GL29452@sun>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110824085329.GL29452@sun>
Sender: linux-fsdevel-owner@vger.kernel.org
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Nathan Lynch <ntl@pobox.com>, Oren Laadan <orenl@cs.columbia.edu>, Daniel Lezcano <dlezcano@fr.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Glauber Costa <glommer@parallels.com>, containers@lists.osdl.org, linux-kernel@vger.kernel.org, Pavel Emelyanov <xemul@parallels.com>, Serge Hallyn <serge.hallyn@canonical.com>, LINUXFS-ML <linux-fsdevel@vger.kernel.org>, James Bottomley <jbottomley@parallels.com>
List-Id: containers.vger.kernel.org

Hello,

On Wed, Aug 24, 2011 at 12:53:29PM +0400, Cyrill Gorcunov wrote:
> +static const struct dentry_operations tid_map_files_dentry_operations = {
> +	.d_revalidate	= pid_revalidate,
> +	.d_delete	= pid_delete_dentry,
> +};

Why pid_revalidate?  Shouldn't it be verifying the entry against the
current vmas?  vmas (of course) can change while the process is
running.

Thanks.

-- 
tejun
