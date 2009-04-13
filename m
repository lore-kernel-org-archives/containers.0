From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 00/30] C/R OpenVZ/Virtuozzo style
Date: Mon, 13 Apr 2009 11:39:25 +0400
Message-ID: <20090413073925.GB7085__34608.301256276$1239608600$gmane$org@x200.localdomain>
References: <20090410023207.GA27788@x200.localdomain>
	<alpine.LFD.2.00.0904100758410.4583@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.0904100758410.4583-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, Apr 10, 2009 at 08:06:55AM -0700, Linus Torvalds wrote:
> On Fri, 10 Apr 2009, Alexey Dobriyan wrote:
> >
> > This is to show how we see C/R and to provoke discussion on number of
> > important issues (mounts, ...).
> 
> My only initial reaction is that I absolutely hate the naming (not to say 
> I love the code - just to say that I didn't even look at it, because I got 
> hung up on the name).
> 
> "cr"? It could be anything. I realize that to _you_ that is meaningful, 
> but to somebody less specifically interested in checkpoint-restore 'cr' 
> means 'carriage return' or just doesn't really say anything at all. 

Well, in OpenVZ everything is in kernel/cpt/ and prefixed with "cpt_"
and "rst_". And I think "cr_" is super nice prefix: it's short, it's C-like,
it reminds about restart part. Eventually, C/R will become standard
in-kernel thing everyone should be at least aware of, so it's like
learning what "vma" means.

> That goes both for file naming (kernel/cr/xyzzy.c) and to a lesser degree 
> for function naming too. I also don't think it makes sense to have 
> something like kernel/cr/cr-x86_32.c or kernel/cr/cr-tty.c - maybe that is 
> good right now, but I sure hope that the long-term goal is to have these 
> things in the code that will need to change them when the code gets 
> updated (ie arch/x86/kernel and drivers/char/)

In the long run, yes, C/R should be moved closer to core code it tries to
checkpoint. Right now, however, doing "make kernel/cr/" is much quicker
and C/R can not do much, so it's unclear how exactly splitting should be
done.
