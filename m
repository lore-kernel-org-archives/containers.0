From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: Re: [PATCH 2/5] ftrace: use code patching for ftrace graph tracer
Date: Wed, 26 Nov 2008 10:06:00 -0800
Message-ID: <1227722760.5511.75.camel@brick>
References: <20081126051622.134970943@goodmis.org>
	 <20081126051709.774546196@goodmis.org>
	 <20081125213546.ff4eddf4.akpm@linux-foundation.org>
	 <alpine.DEB.1.10.0811261144360.26743@gandalf.stny.rr.com>
	 <20081126100255.d53f9347.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755162AbYKZSGU@vger.kernel.org>
In-Reply-To: <20081126100255.d53f9347.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, Frederic Weisbecker <fweisbec@gmail.com>, containers@lists.osdl.org, Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>, "Serge E. Hallyn" <serue@us.ibm.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Steven Rostedt <srostedt@redhat.com>
List-Id: containers.vger.kernel.org

On Wed, 2008-11-26 at 10:02 -0800, Andrew Morton wrote:
> > > 
> > > > +		return -EINVAL;
> > > > +
> > > > +	*(int *)(&code[1]) = new_offset;
> > > 
> > > Might be able to use put_unaligned_foo() here.
> > > 
> > > The problem is that these functions use sizeof(*ptr) to work out what
> > > to do, so a cast is still needed.  A get_unaligned32(ptr) would be
> > > nice.  One which takes a void* and assumes CPU ordering.
> > 
> > Is there a correctness concern here? This is arch specific code, so I'm
> > not worried about other archs.
> 
> No, the code is OK as-is.
> 
> It's just that "read a word from an [maybe-]unaligned address" is such
> a common operation that there should be a nice clean simple function to
> do it, rather than doing open-coded (and different) weird C tricks at each
> and\ every site.
> 

Also it is arch-specific, so if you know unaligned access is OK, just doing the
cast+deref is OK.

Harvey
