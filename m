From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [patch 2/2] fs, proc: Introduce the /proc/<pid>/map_files/
 directory v6
Date: Thu, 8 Sep 2011 02:42:34 +0400
Message-ID: <20110907224234.GD28162@sun>
References: <20110905192009.GJ761@sun>
 <20110905194908.GA2690@albatros>
 <20110905203627.GL761@sun>
 <20110906101518.GA4799@albatros>
 <20110906165144.GJ18425@mtj.dyndns.org>
 <20110906172952.GA28055@albatros>
 <20110906173341.GM18425@mtj.dyndns.org>
 <20110907112301.GA12157@albatros>
 <20110907215329.GB28162@sun>
 <20110907151323.613e62e7.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110907151323.613e62e7.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vasiliy Kulikov <segoon@openwall.com>, Tejun Heo <tj@kernel.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, containers@lists.osdl.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, Nathan Lynch <ntl@pobox.com>, kernel-hardening@lists.openwall.com, Oren Laadan <orenl@cs.columbia.edu>, Daniel Lezcano <dlezcano@fr.ibm.com>, Glauber Costa <glommer@parallels.com>, James Bottomley <jbottomley@parallels.com>, Alexey Dobriyan <adobriyan@gmail.com>, Al Viro <viro@ZenIV.linux.org.uk>, Pavel Emelyanov <xemul@parallels.com>
List-Id: containers.vger.kernel.org

On Wed, Sep 07, 2011 at 03:13:23PM -0700, Andrew Morton wrote:
...
> > > 
> > > Andrew, are you OK with closing the hole with pid_no_revalidate()
> > > and 0600 /proc/slabinfo?  If so, I feel I have to start this discussion
> > > with people participating in the discussion above: Theodore, Dan, Linus, etc.
> 
> I fell asleep a long time ago and don't know what pid_no_revalidate()
> and slabinfo permissions have to do with this.  Perhaps summarising the
> issues in the changelog would be appropriate, dunno.

Well, time to poke Vasiliy ;)

...
> > 
> > I fear we still need to use two passes in proc_map_files_readdir, I found no way
> > to escape lockdep complains when doing all work in one pass with mmap_sem taken.
> > The /maps does the same thing -- ie it fills maps file with mmap_sem taken to produce
> > robust data.
> 
> The code's using three passes.

Yes, and I didn't find thy way to escape it (actually if there would not
be filldir+might_fault tuple I would create this all under mmap_sem and
would not need this flex_array or any temporary storage at all and code
would be a way simplier).

> 
> > And I'm not really sure what you mean with problematic put_filp?
> 
> I was thinking fput(), which can do a hell of a lot of stuff if it's
> the final put on the inode.

Ouch, somehow missed it, thanks!

> > +err:
> > +		up_read(&mm->mmap_sem);
> > +
> > +		for (i = 0; i < used && !ret; i++) {
> 
> The "&& !ret" is unneeded?

No, it's needed, since it makes sure that if "impossible"
scenario happens and flex-arrays fails with preallocated
data so we will reach this point with used > 0 and ret = -ENOMEM
and thus will not call for proc_map_files_instantiate as needed.

> 
> > +			p = flex_array_get(fa, i);
> > +			ret = proc_fill_cache(filp, dirent, filldir,
> > +					      p->name, p->len,
> > +					      proc_map_files_instantiate,
> > +					      task, p->file);
> > +			if (ret)
> > +				break;

1: Say we failed here

> > +			filp->f_pos++;
> > +			put_filp(p->file);
> > +		}
> > +
> > +		for (; i < used; i++) {
> > +			p = flex_array_get(fa, i);
> > +			put_filp(p->file);
> > +		}
> 
> Still unclear why we need the third loop.

Due to (1) -- so we will have a number of files reference
taken and need to put them back.

	Cyrill
