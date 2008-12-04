From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH 2/3] ftrace: use struct pid
Date: Thu, 4 Dec 2008 10:44:44 -0500 (EST)
Message-ID: <alpine.DEB.1.10.0812041044250.19693@gandalf.stny.rr.com>
References: <20081204052638.425740534@goodmis.org>  <20081204052735.175697908@goodmis.org> <m1d4g8un6b.fsf@frodo.ebiederm.org>  <1228395378.13111.23.camel@nimitz> <1228396022.13111.27.camel@nimitz>  <m1prk8t5xr.fsf@frodo.ebiederm.org>
 <1228405291.13111.86.camel@nimitz>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759291AbYLDPpI@vger.kernel.org>
In-Reply-To: <1228405291.13111.86.camel@nimitz>
Sender: linux-kernel-owner@vger.kernel.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, Frederic Weisbecker <fweisbec@gmail.com>, linux-kernel@vger.kernel.org, Steven Rostedt <srostedt@redhat.com>, containers@lists.osdl.org, Ingo Molnar <mingo@elte.hu>, Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Dipankar Sarma <dipankar@in.ibm.com>
List-Id: containers.vger.kernel.org


On Thu, 4 Dec 2008, Dave Hansen wrote:
> > 
> > We probably should.  Historically read_lock(&tasklist_lock) implies
> > rcu_read_lock().  And the tasklist lock is what we hold when it is
> > safe.
> 
> So, Dipankar tells me that you really do need rcu_read_lock/unlock() for
> the guarantee here; the tasklist lock is not sufficient.  The realtime
> kernel will preempt even those sections covered by spinlocks.

Yes it will.

-- Steve
