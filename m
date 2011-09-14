From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [patch 1/2] fs, proc: Make proc_get_link to use dentry instead
 of inode
Date: Wed, 14 Sep 2011 04:37:57 +0300
Message-ID: <20110914013757.GA3948@shutemov.name>
References: <20110913211359.674453213@openvz.org>
 <20110913212447.682271914@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110913212447.682271914@openvz.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Cyrill Gorcunov <gorcunov@openvz.org>
Cc: linux-kernel@vger.kernel.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelyanov <xemul@parallels.com>, James Bottomley <jbottomley@parallels.com>, Nathan Lynch <ntl@pobox.com>, Zan Lynx <zlynx@acm.org>, Daniel Lezcano <dlezcano@fr.ibm.com>, Vasiliy Kulikov <segoon@openwall.com>, Tejun Heo <tj@kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>, Al Viro <viro@ZenIV.linux.org.uk>
List-Id: containers.vger.kernel.org

On Wed, Sep 14, 2011 at 01:14:00AM +0400, Cyrill Gorcunov wrote:
> This patch prepares the ground for the next "map_files"
> patch which needs a name of a link file to analyse.
> 
> So instead of squashing this change into one big
> patch the separate one is done.
> 
> Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
> CC: Pavel Emelyanov <xemul@parallels.com>
> CC: Tejun Heo <tj@kernel.org>
> CC: Vasiliy Kulikov <segoon@openwall.com>
> CC: "Kirill A. Shutemov" <kirill@shutemov.name>
> CC: Alexey Dobriyan <adobriyan@gmail.com>
> CC: Al Viro <viro@ZenIV.linux.org.uk>
> CC: Andrew Morton <akpm@linux-foundation.org>

Reviewed-by: Kirill Shutemov <kirill@shutemov.name>

-- 
 Kirill A. Shutemov
