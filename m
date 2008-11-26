From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH 1/5] ftrace: add function tracing to single thread
Date: Wed, 26 Nov 2008 11:55:37 -0500 (EST)
Message-ID: <alpine.DEB.1.10.0811261155200.26743@gandalf.stny.rr.com>
References: <20081126051622.134970943@goodmis.org> <20081126051709.571204072@goodmis.org> <m1hc5vasye.fsf@frodo.ebiederm.org> <20081126065425.GA26036@elte.hu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754683AbYKZQzw@vger.kernel.org>
In-Reply-To: <20081126065425.GA26036@elte.hu>
Sender: linux-kernel-owner@vger.kernel.org
To: Ingo Molnar <mingo@elte.hu>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Frederic Weisbecker <fweisbec@gmail.com>, containers@lists.osdl.org, Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>, "Serge E. Hallyn" <serue@us.ibm.com>, Steven Rostedt <srostedt@redhat.com>
List-Id: containers.vger.kernel.org


On Wed, 26 Nov 2008, Ingo Molnar wrote:

> 
> * Eric W. Biederman <ebiederm@xmission.com> wrote:
> 
> > > +/* ftrace_pid_trace >= 0 will only trace threads with this pid */
> > > +static int ftrace_pid_trace = -1;
> > 
> > Why not?
> > static struct pid *ftrace_pid_trace = NULL;
> 
> ok, looks reasonably simple at first sight.
> 
> Steve, mind sending the conversion of this facility to struct pid as a 
> delta patch? (that would have education purposes as well, for similar 
> situations)

If I can trace specific kernel threads too, then I have no problem with 
it.

-- Steve
