From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 5/5] ftrace: add cpu annotation for function graph
 tracer
Date: Tue, 25 Nov 2008 21:55:28 -0800
Message-ID: <20081125215528.eff18969.akpm@linux-foundation.org>
References: <20081126051622.134970943@goodmis.org>
	<20081126051710.339437727@goodmis.org>
	<20081125213909.d4eb3f09.akpm@linux-foundation.org>
	<20081126054728.GD9732@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753178AbYKZF4d@vger.kernel.org>
In-Reply-To: <20081126054728.GD9732@elte.hu>
Sender: linux-kernel-owner@vger.kernel.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Steven Rostedt <rostedt@goodmis.org>, linux-kernel@vger.kernel.org, Frederic Weisbecker <fweisbec@gmail.com>, containers@lists.osdl.org, Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>, "Serge E. Hallyn" <serue@us.ibm.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Steven Rostedt <srostedt@redhat.com>
List-Id: containers.vger.kernel.org

On Wed, 26 Nov 2008 06:47:28 +0100 Ingo Molnar <mingo@elte.hu> wrote:

> 
> * Andrew Morton <akpm@linux-foundation.org> wrote:
> 
> > On Wed, 26 Nov 2008 00:16:27 -0500 Steven Rostedt <rostedt@goodmis.org> wrote:
> > 
> > > This patch adds the annotation of 'CPU[###]' where ### is a three 
> > > digit number
> > 
> > Is this a plot to get yourself sent a 1024-way test box?
> 
> So you are suggesting to change it to 4 digit printout?

Not really.  I somehow doubt that it's economic to do your software tuning
on the 1024-way ;)

> (Is this a plot to get yourself snt a 16384-way test box? ;-)

I'd settle for 1.6384 testers.
