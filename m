From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [patch 2/2] fs, proc: Introduce the /proc/<pid>/map_files/
 directory v6
Date: Fri, 2 Sep 2011 09:54:55 +0400
Message-ID: <20110902055455.GL30615@sun>
References: <20110831075814.003575573@openvz.org>
 <20110831080229.100652529@openvz.org>
 <20110831090612.GA3253@albatros>
 <20110831112642.GI25465@sun>
 <20110831140416.GA17626@shutemov.name>
 <20110831142622.GB30615@sun>
 <20110831151023.5b7e12da.akpm@linux-foundation.org>
 <20110901104633.GG30615@sun>
 <20110901154946.b43ba91b.akpm@linux-foundation.org>
 <20110901230440.GA4432@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110901230440.GA4432@mtj.dyndns.org>
Sender: linux-fsdevel-owner@vger.kernel.org
To: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Vasiliy Kulikov <segoon@openwall.com>, containers@lists.osdl.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, Nathan Lynch <ntl@pobox.com>, Oren Laadan <orenl@cs.columbia.edu>, Daniel Lezcano <dlezcano@fr.ibm.com>, Glauber Costa <glommer@parallels.com>, James Bottomley <jbottomley@parallels.com>, Alexey Dobriyan <adobriyan@gmail.com>, Al Viro <viro@ZenIV.linux.org.uk>, Pavel Emelyanov <xemul@parallels.com>
List-Id: containers.vger.kernel.org

On Fri, Sep 02, 2011 at 01:04:40AM +0200, Tejun Heo wrote:
> On Thu, Sep 01, 2011 at 03:49:46PM -0700, Andrew Morton wrote:
> > The most robust implementation here is to allocate a large number of
> > small objects - one per vma.  A list would be a suitable way of
> > managing them.
> 
> Or just use flex_array?
> 

Hey, looks interesting! I'll check. Thanks for the point!

	Cyrill
