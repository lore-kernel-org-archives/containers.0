From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH 1/3] ftrace: graph of a single function
Date: Wed, 3 Dec 2008 16:11:56 -0500 (EST)
Message-ID: <alpine.DEB.1.10.0812031611000.29045@gandalf.stny.rr.com>
References: <20081203203656.776893226@goodmis.org> <20081203203828.920111079@goodmis.org> <20081203130859.fcf5a51e.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756527AbYLCVMT@vger.kernel.org>
In-Reply-To: <20081203130859.fcf5a51e.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, mingo@elte.hu, fweisbec@gmail.com, peterz@infradead.org, arjan@infradead.org, dave@linux.vnet.ibm.com, containers@lists.osdl.org, ebiederm@xmission.com, sukadev@linux.vnet.ibm.com, serue@us.ibm.com, srostedt@redhat.com
List-Id: containers.vger.kernel.org


On Wed, 3 Dec 2008, Andrew Morton wrote:

> On Wed, 03 Dec 2008 15:36:57 -0500
> Steven Rostedt <rostedt@goodmis.org> wrote:
> 
> > +static struct seq_operations ftrace_graph_seq_ops = {
> > +	.start = g_start,
> > +	.next = g_next,
> > +	.stop = g_stop,
> > +	.show = g_show,
> > +};
> 
> This could be static I think.

s/static/const/

Damn damn damn damn!!!! I said to myself, I need to add const there and 
still forgot :-(

> 
> It's probably not worth even commenting on or fixing this sort
> of thing.  Just rely on someone(tm) doing periodic sweeps to
> fix them all up.

Still on my todo list for kernel/trace/*.c

-- Steve
