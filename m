From: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>
Subject: Re: [PATCH RFC - TAKE TWO - 00/12] New version of the BFQ I/O
	Scheduler
Date: Fri, 30 May 2014 18:48:54 -0600
Message-ID: <538926F6.7080409__49218.7291187749$1401497351$gmane$org@kernel.dk>
References: <20140528221929.GG1419@htj.dyndns.org>
	<1401354343-5527-1-git-send-email-paolo.valente@unimore.it>
	<20140530160712.GG24871@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20140530160712.GG24871-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Paolo Valente <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Fabio Checconi <fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Arianna Avanzini <avanzini.arianna-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paolo Valente <posta_paolo-whZMOeQn8C0@public.gmane.org>
List-Id: containers.vger.kernel.org

On 2014-05-30 10:07, Tejun Heo wrote:
> We do have multiple ioscheds but sans for anticipatory which pretty
> much has been superceded by cfq, they serve different purposes and I'd
> really hate the idea of carrying two mostly similar ioscheds in tree.

AS was removed, and exactly for that reason. So lets make one thing very 
clear: we are not going to carry two implementations of CFQ, that differ 
in various ways. That will not happen. We're going to end up with one 
"smart" IO scheduler, not several of them.

> For some reason, blkcg implementation seems completely different but
> outside of that, bfq doesn't really seem to have diverged a lot from
> cfq and the most likely and probably only way for it to be merged
> would be if you just mutate cfq into bfq.  The whole effort is mostly
> about characterizing and refining the scheduling algorithm anyway,
> right?  I'd really love to see that happening.

Patching CFQ would be the right way to go, imho. That would also make it 
very clear what the steps are to get there, leaving us with something 
that can actually be backtracked and debugged. I think the patch series 
already looks pretty good, basically patch #2 "just" needs to be turned 
into a series of patches for CFQ.

What I really like about the implementation is, as Tejun highlights, 
that the algorithm is detailed and characterized. Nobody ever wrote any 
detailed documentation on CFQ - I think the closest is a talk I gave at 
LCA in 2007 or so. That said, the devil is _always_ in the details when 
it comes to nice algorithms. When theory meets practice, then the little 
tweaks and tunings required to not drop 10% there or 20% here is when it 
gets ugly. And that's where CFQ has the history going for it, at least. 
Which is another reason for turning patch #2 into a series of changes 
for CFQ instead. We need to end up with something where we can 
potentially bisect our way down to whatever caused any given regression. 
The worst possible situation is "CFQ works fine for this workload, but 
BFQ does not" or vice versa. Or hangs, or whatever it might be.


-- 
Jens Axboe
