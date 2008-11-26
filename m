From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 1/5] ftrace: add function tracing to single thread
Date: Wed, 26 Nov 2008 07:54:25 +0100
Message-ID: <20081126065425.GA26036@elte.hu>
References: <20081126051622.134970943@goodmis.org> <20081126051709.571204072@goodmis.org> <m1hc5vasye.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753252AbYKZGz2@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <m1hc5vasye.fsf@frodo.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Frederic Weisbecker <fweisbec@gmail.com>, containers@lists.osdl.org, Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>, "Serge E. Hallyn" <serue@us.ibm.com>, Steven Rostedt <srostedt@redhat.com>
List-Id: containers.vger.kernel.org


* Eric W. Biederman <ebiederm@xmission.com> wrote:

> > +/* ftrace_pid_trace >= 0 will only trace threads with this pid */
> > +static int ftrace_pid_trace = -1;
> 
> Why not?
> static struct pid *ftrace_pid_trace = NULL;

ok, looks reasonably simple at first sight.

Steve, mind sending the conversion of this facility to struct pid as a 
delta patch? (that would have education purposes as well, for similar 
situations)

	Ingo
