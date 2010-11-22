From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Subject: Re: [Ksummit-2010-discuss] checkpoint-restart: naked patch
Date: Mon, 22 Nov 2010 10:02:41 -0800
Message-ID: <20101122180241.GA25301@us.ibm.com>
References: <4CE3C334.9080401@kernel.org> <20101117153902.GA1155@hallyn.com> <4CE3F8D1.10003@kernel.org> <20101119041045.GC24031@hallyn.com> <4CE683E1.6010500@kernel.org> <4CE69B8C.6050606@cs.columbia.edu> <Pine.LNX.4.64.1011201312470.15662@takamine.ncl.cs.columbia.edu> <4CE8228C.3000108@kernel.org> <20101121081853.GA21672@sundance.ccs.neu.edu> <20101121082143.GB21672@sundance.ccs.neu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20101121082143.GB21672@sundance.ccs.neu.edu>
Sender: linux-kernel-owner@vger.kernel.org
To: Gene Cooperman <gene@ccs.neu.edu>
Cc: Kapil Arya <kapil@ccs.neu.edu>, linux-kernel@vger.kernel.org, xemul@sw.ru, Linux Containers <containers@lists.osdl.org>, "Eric W. Biederman" <ebiederm@xmission.com>, Tejun Heo <tj@kernel.org>
List-Id: containers.vger.kernel.org

Gene Cooperman [gene@ccs.neu.edu] wrote:
| > RELIABILITY     checkpoint w/ single syscall;   non-atomic, cannot find leaks
| >                 atomic operation. guaranteed    to determine restartability
| >                 restartability for containers
| 
| My understanding is that the guarantees apply for Linux containers, but not
| for a tree of processes.  Does this imply that linux-cr would have some
| of the same reliability issues as DMTCP for a tree of processes?  (I mean
| the question sincerely, and am not intending to be rude.)  In any case,
| won't DMTCP and Linux C/R have to handle orthogonal reliability issues
| such as external database, time virtualization, and other examples
| from our previous post?

Yes if the user attempts to checkpoint a partial container (what we refer
to process subtree) or fails to snapshot/restore filesystem there could be
leaks that we cannot detect.

But one guarantee we are trying to provide is that if the user checkpoints
a _complete_ container, then we will detect a leak if one exists.

Is there a way to establish a set of constraints (eg: run application in a
container, snapshot/restore filesystem) and then provide leak detection with
a pure userpsace implementation ?

Sukadev
