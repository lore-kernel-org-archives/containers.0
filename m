From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 00/30] C/R OpenVZ/Virtuozzo style
Date: Tue, 14 Apr 2009 14:11:26 -0700
Message-ID: <1239743486.32604.132.camel__30742.3815051608$1239743741$gmane$org@nimitz>
References: <20090410023207.GA27788@x200.localdomain>
	<1239340031.24083.21.camel@nimitz>
	<20090413091423.GA19236@x200.localdomain>
	<49E4108A.8050201@cs.columbia.edu>
	<20090414145830.GA27461@x200.localdomain>
	<49E4D115.5080601@cs.columbia.edu>
	<20090414204912.GA28458@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090414204912.GA28458-2ev+ksY9ol182hYKe6nXyg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, 2009-04-15 at 00:49 +0400, Alexey Dobriyan wrote:
> > Going back to my example of a subtree above: what sort of security
> > issues you would have here, assuming all restart operations go via
> > the usual security checks just like syscalls, and we take special
> > care about values we allow as input, e.g. cpu debug registers etc ?
> 
> This is like asking if everything goes through correct security checks
> how will you screw something up. Everything won't go via usual security
> checks.
> 
> Just for giggles, writing exploit for localhost hole becomes easier --
> you very effectively turn off all randomization kernel does because VMA
> boundaries comes from disk.

Alexey, I think there's a bit of a misunderstanding here.  We're
proposing that whatever gets done during the restart would not be able
to elevate above the privilege level of the user doing the restart.  For
instance, a user would not be able to restart a suid application -- that
would require privilege.

In the same way, at checkpoint time, we should deny users the ability to
checkpoint things that are privileged.  We need to pay very close
attention to the kernel interfaces that we use to ensure that all the
normal security checks are observed, of course.  

There's no new hole.  A restore operation is just a pieced-together set
of operations that the user would have already been able to perform.

Again, I think this stems from some of us that think that c/r should be
used outside exclusively checkpointing whole containers.  I think we'll
find some expanded use for c/r on things that aren't strict system
containers.

-- Dave
