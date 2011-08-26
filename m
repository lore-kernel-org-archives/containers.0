From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC] fs, proc: Introduce the /proc/<pid>/map_files/ directory v2
Date: Fri, 26 Aug 2011 17:23:34 +0300
Message-ID: <20110826142334.GA26675@shutemov.name>
References: <20110825170147.GM2803@mtj.dyndns.org>
 <20110825170705.GA6387@sun>
 <20110825205426.GO2803@mtj.dyndns.org>
 <20110825211213.GP2803@mtj.dyndns.org>
 <20110825213459.GA1929@sun>
 <20110825213931.GR2803@mtj.dyndns.org>
 <20110826112943.GI3903@sun>
 <20110826122851.GA25853@shutemov.name>
 <20110826131620.GM3903@sun>
 <20110826140620.GE2632@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110826140620.GE2632@htj.dyndns.org>
Sender: linux-fsdevel-owner@vger.kernel.org
To: Tejun Heo <tj@kernel.org>
Cc: Cyrill Gorcunov <gorcunov@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelyanov <xemul@parallels.com>, linux-kernel@vger.kernel.org, James Bottomley <jbottomley@parallels.com>, containers@lists.osdl.org, Andi Kleen <andi@firstfloor.org>, Nathan Lynch <ntl@pobox.com>, LINUXFS-ML <linux-fsdevel@vger.kernel.org>, Zan Lynx <zlynx@acm.org>, Daniel Lezcano <dlezcano@fr.ibm.com>, Vasiliy Kulikov <segoon@openwall.com>
List-Id: containers.vger.kernel.org

On Fri, Aug 26, 2011 at 04:06:20PM +0200, Tejun Heo wrote:
> > +struct map_files_info {
> > +	struct file	*file;
> > +	unsigned char	name[16+16+2]; /* max: %016lx-%016lx\0 */
> > +	unsigned long	len;
> > +};
> 
> That's slightly above 50 bytes.

We can use 4 * sizeof(unsigned long) + 2 for name to save a bit on 32 bit
architectures.

BTW, show_map_vma() uses "%08lx-%08lx" to print ->start, ->end. I think
it's good idea to use this here as well to be consistent with
/proc/$PID/{s,}maps

-- 
 Kirill A. Shutemov
