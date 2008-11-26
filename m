From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 5/5] ftrace: add cpu annotation for function graph
	tracer
Date: Wed, 26 Nov 2008 06:47:28 +0100
Message-ID: <20081126054728.GD9732@elte.hu>
References: <20081126051622.134970943@goodmis.org> <20081126051710.339437727@goodmis.org> <20081125213909.d4eb3f09.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753160AbYKZFsF@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081125213909.d4eb3f09.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, linux-kernel@vger.kernel.org, Frederic Weisbecker <fweisbec@gmail.com>, containers@lists.osdl.org, Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>, "Serge E. Hallyn" <serue@us.ibm.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Steven Rostedt <srostedt@redhat.com>
List-Id: containers.vger.kernel.org


* Andrew Morton <akpm@linux-foundation.org> wrote:

> On Wed, 26 Nov 2008 00:16:27 -0500 Steven Rostedt <rostedt@goodmis.org> wrote:
> 
> > This patch adds the annotation of 'CPU[###]' where ### is a three 
> > digit number
> 
> Is this a plot to get yourself sent a 1024-way test box?

So you are suggesting to change it to 4 digit printout?

(Is this a plot to get yourself snt a 16384-way test box? ;-)

	Ingo
