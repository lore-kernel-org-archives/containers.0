From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [patch 2/2] fs, proc: Introduce the /proc/<pid>/map_files/
 directory v6
Date: Wed, 31 Aug 2011 18:09:11 +0400
Message-ID: <20110831140911.GA30615@sun>
References: <20110831075814.003575573@openvz.org>
 <20110831080229.100652529@openvz.org>
 <20110831090612.GA3253@albatros>
 <20110831112642.GI25465@sun>
 <20110831140416.GA17626@shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110831140416.GA17626@shutemov.name>
Sender: linux-fsdevel-owner@vger.kernel.org
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Vasiliy Kulikov <segoon@openwall.com>, containers@lists.osdl.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, Nathan Lynch <ntl@pobox.com>, Oren Laadan <orenl@cs.columbia.edu>, Daniel Lezcano <dlezcano@fr.ibm.com>, Glauber Costa <glommer@parallels.com>, James Bottomley <jbottomley@parallels.com>, Tejun Heo <tj@kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>, Al Viro <viro@ZenIV.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelyanov <xemul@parallels.com>
List-Id: containers.vger.kernel.org

On Wed, Aug 31, 2011 at 05:04:16PM +0300, Kirill A. Shutemov wrote:
...
> > 
> > OK, here is an updated one. Thanks for feedback. Hope this time
> > all nits are addressed. Still reviews/complains are *very* appreciated.
> 
> Please run checkpatch. It points several warnings and one dangerous error.
> 

Doh! Thanks Kirill, it's a parasite semicolon :(

	Cyrill
