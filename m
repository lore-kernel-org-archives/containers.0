From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 1/3] ftrace: graph of a single function
Date: Thu, 4 Dec 2008 09:39:17 +0100
Message-ID: <20081204083917.GF32594@elte.hu>
References: <20081203203656.776893226@goodmis.org> <20081203203828.920111079@goodmis.org> <20081203130741.473c1262.akpm@linux-foundation.org> <alpine.DEB.1.10.0812031608560.29045@gandalf.stny.rr.com> <20081203133242.4e80bbe6.akpm@linux-foundation.org> <alpine.DEB.1.10.0812031635060.28153@gandalf.stny.rr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756018AbYLDIkb@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0812031635060.28153@gandalf.stny.rr.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, fweisbec@gmail.com, peterz@infradead.org, arjan@infradead.org, dave@linux.vnet.ibm.com, containers@lists.osdl.org, ebiederm@xmission.com, sukadev@linux.vnet.ibm.com, serue@us.ibm.com, srostedt@redhat.com
List-Id: containers.vger.kernel.org


* Steven Rostedt <rostedt@goodmis.org> wrote:

> 
> On Wed, 3 Dec 2008, Andrew Morton wrote:
> 
> > On Wed, 3 Dec 2008 16:10:38 -0500 (EST)
> > Steven Rostedt <rostedt@goodmis.org> wrote:
> > > > > +
> > > > > +	seq_printf(m, "%s\n", str);
> > > > 
> > > > Can we use %pF here?
> > > 
> > > If there's a way to not print the "+offset".
> > 
> > Could be added, I guess.  I wonder if it would be
> > reused elsewhere.
> 
> There's lots of places in ftrace that would use it, and probably clean 
> up a bunch of code in the process.

Well, we do eventually want to have a trace_option that extends all 
function names with the +offset/size portion - and one that switches them 
to raw RIPs.

In rare occasions, when the same function has multiple call sites of the 
same child function, it can be useful. I ran into such scenarios with the 
latency tracer and it had this capability to do 'verbose' symbol 
printing.

So plain %pF wont cut it - please abstract out the "print function symbol 
string" bit within the ftrace infrastructure.

And the default trace_option for this should be to print without 
+offset/size spam, emphatically :)

	Ingo
