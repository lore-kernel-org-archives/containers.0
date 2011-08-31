From: Vasiliy Kulikov <segoon@openwall.com>
Subject: Re: [patch 2/2] fs, proc: Introduce the /proc/<pid>/map_files/
 directory v6
Date: Wed, 31 Aug 2011 13:06:12 +0400
Message-ID: <20110831090612.GA3253@albatros>
References: <20110831075814.003575573@openvz.org>
 <20110831080229.100652529@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110831080229.100652529@openvz.org>
Sender: linux-fsdevel-owner@vger.kernel.org
To: Cyrill Gorcunov <gorcunov@openvz.org>
Cc: containers@lists.osdl.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, Nathan Lynch <ntl@pobox.com>, Oren Laadan <orenl@cs.columbia.edu>, Daniel Lezcano <dlezcano@fr.ibm.com>, Glauber Costa <glommer@parallels.com>, James Bottomley <jbottomley@parallels.com>, Tejun Heo <tj@kernel.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Alexey Dobriyan <adobriyan@gmail.com>, Al Viro <viro@ZenIV.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelyanov <xemul@parallels.com>
List-Id: containers.vger.kernel.org

Hi,

On Wed, Aug 31, 2011 at 11:58 +0400, Cyrill Gorcunov wrote:
> From: Pavel Emelyanov <xemul@parallels.com>
> 
> This one behaves similarly to the /proc/<pid>/fd/ one - it contains symlinks
> one for each mapping with file, the name of a symlink is "vma->vm_start-vma->vm_end",
> the target is the file. Opening a symlink results in a file that point exactly
> to the same inode as them vma's one.

I'm late noting it before the RFCv6 :)  Besides checking
ptrace_may_access() on ->lookup and ->readdir you also should define
->stat, otherwise you can bypass ptrace checks if there is a
corresponding dentry in the cache.  The same issue existed in fd* handlers:

http://www.openwall.com/lists/kernel-hardening/2011/08/29/1

Thanks,

-- 
Vasiliy Kulikov
http://www.openwall.com - bringing security into open computing environments
