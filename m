From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 1/3] ftrace: graph of a single function
Date: Thu, 04 Dec 2008 09:43:07 +0100
Message-ID: <1228380187.5092.16.camel@twins>
References: <20081203203656.776893226@goodmis.org>
	 <20081203203828.920111079@goodmis.org>
	 <20081203130859.fcf5a51e.akpm@linux-foundation.org>
	 <alpine.DEB.1.10.0812031611000.29045@gandalf.stny.rr.com>
	 <20081204084118.GG32594@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756158AbYLDIn7@vger.kernel.org>
In-Reply-To: <20081204084118.GG32594@elte.hu>
Sender: linux-kernel-owner@vger.kernel.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Steven Rostedt <rostedt@goodmis.org>, Andy Whitcroft <apw@shadowen.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, fweisbec@gmail.com, arjan@infradead.org, dave@linux.vnet.ibm.com, containers@lists.osdl.org, ebiederm@xmission.com, sukadev@linux.vnet.ibm.com, serue@us.ibm.com, srostedt@redhat.com
List-Id: containers.vger.kernel.org

On Thu, 2008-12-04 at 09:41 +0100, Ingo Molnar wrote:
> * Steven Rostedt <rostedt@goodmis.org> wrote:
> 
> > 
> > On Wed, 3 Dec 2008, Andrew Morton wrote:
> > 
> > > On Wed, 03 Dec 2008 15:36:57 -0500
> > > Steven Rostedt <rostedt@goodmis.org> wrote:
> > > 
> > > > +static struct seq_operations ftrace_graph_seq_ops = {
> > > > +	.start = g_start,
> > > > +	.next = g_next,
> > > > +	.stop = g_stop,
> > > > +	.show = g_show,
> > > > +};
> > > 
> > > This could be static I think.
> > 
> > s/static/const/
> > 
> > Damn damn damn damn!!!! I said to myself, I need to add const there and 
> > still forgot :-(
> 
> No need to get stressed up about such details - we need checkpatch help 
> for this.

I guess it would be too much for checkpatch, but I think sparse can do
it, it just means steve has to install sparse and actually run the
thing ;-)
