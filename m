From: Tejun Heo <tj@kernel.org>
Subject: Re: [patch 2/2] fs, proc: Introduce the /proc/<pid>/map_files/
 directory v6
Date: Fri, 2 Sep 2011 10:58:07 +0900
Message-ID: <20110902015807.GG2752@htj.dyndns.org>
References: <20110831075814.003575573@openvz.org>
 <20110831080229.100652529@openvz.org>
 <4E603758.6050003@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4E603758.6050003@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Nicholas Miell <nmiell@gmail.com>
Cc: Cyrill Gorcunov <gorcunov@openvz.org>, containers@lists.osdl.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, Nathan Lynch <ntl@pobox.com>, Oren Laadan <orenl@cs.columbia.edu>, Daniel Lezcano <dlezcano@fr.ibm.com>, Glauber Costa <glommer@parallels.com>, James Bottomley <jbottomley@parallels.com>, Vasiliy Kulikov <segoon@openwall.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Alexey Dobriyan <adobriyan@gmail.com>, Al Viro <viro@ZenIV.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelyanov <xemul@parallels.com>
List-Id: containers.vger.kernel.org

On Thu, Sep 01, 2011 at 06:54:32PM -0700, Nicholas Miell wrote:
> This doesn't seem to fully export all the information passed to mmap(2)
> -- it encompasses the addr, size, fd and (assuming the generated
> symlink's permissions are accurate) prot parameters, but does nothing to
> export the flags or offset parameters.

It looks like,

/proc/*/fd : fdinfo ~= map_files : maps

-- 
tejun
