From: Pavel Emelyanov <xemul@parallels.com>
Subject: Re: [patch 2/2] fs, proc: Introduce the /proc/<pid>/map_files/ directory
 v6
Date: Fri, 09 Sep 2011 04:24:29 +0400
Message-ID: <4E695CBD.50208@parallels.com>
References: <20110906165144.GJ18425@mtj.dyndns.org>	<20110906172952.GA28055@albatros>	<20110906173341.GM18425@mtj.dyndns.org>	<20110907112301.GA12157@albatros>	<20110907215329.GB28162@sun>	<20110907151323.613e62e7.akpm@linux-foundation.org>	<20110907224234.GD28162@sun>	<20110907155332.beda7d3d.akpm@linux-foundation.org>	<20110908054826.GF28162@sun>	<20110908055025.GG28162@sun>	<20110908060405.GH28162@sun> <20110908165201.59e82c71.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110908165201.59e82c71.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Cyrill Gorcunov <gorcunov@gmail.com>, Vasiliy Kulikov <segoon@openwall.com>, Tejun Heo <tj@kernel.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, "containers@lists.osdl.org" <containers@lists.osdl.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Nathan Lynch <ntl@pobox.com>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, Oren Laadan <orenl@cs.columbia.edu>, Daniel Lezcano <dlezcano@fr.ibm.com>, Glauber Costa <glommer@parallels.com>, James Bottomley <jbottomley@parallels.com>, Alexey Dobriyan <adobriyan@gmail.com>, Al Viro <viro@ZenIV.linux.org.uk>
List-Id: containers.vger.kernel.org

On 09/09/2011 03:52 AM, Andrew Morton wrote:
> On Thu, 8 Sep 2011 10:04:05 +0400
> Cyrill Gorcunov <gorcunov@gmail.com> wrote:
> 
>> fs, proc: Introduce the /proc/<pid>/map_files/ directory v11
> 
> Ho hum, I've pretty much run out of excuses to avoid merging this.
> 
> except...
> 
> We don't really want to bloat fs/proc/base.o by 4k until all the other
> things which support c/r are mergeable and we know that the whole
> project is actually useful.  When will we be at this stage?

Well, I see no other stuff that will be required for us in the nearest
future (well, and in the not-so-near future as well) in the fs/proc/base.o
to checkpoint or restore a task.

Thanks,
Pavel
