From: Paolo Valente <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
Subject: Re: [PATCH RFC - TAKE TWO - 00/12] New version of the BFQ I/O
	Scheduler
Date: Sat, 31 May 2014 00:23:01 +0200
Message-ID: <464F6CBE-A63E-46EF-A90D-BF8450430444@unimore.it>
References: <20140528221929.GG1419@htj.dyndns.org>
	<1401354343-5527-1-git-send-email-paolo.valente@unimore.it>
	<20140530160712.GG24871@htj.dyndns.org>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.2\))
Content-Type: text/plain; charset="us-ascii"
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
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Fabio Checconi <fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Arianna Avanzini <avanzini.arianna-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org


Il giorno 30/mag/2014, alle ore 18:07, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> ha scritto:

> Hello, Paolo.
> 
> On Thu, May 29, 2014 at 11:05:31AM +0200, Paolo Valente wrote:
>> this patchset introduces the last version of BFQ, a proportional-share
>> storage-I/O scheduler. BFQ also supports hierarchical scheduling with
>> a cgroups interface. The first version of BFQ was submitted a few
>> years ago [1]. It is denoted as v0 in the patches, to distinguish it
>> from the version I am submitting now, v7r4. In particular, the first
>> two patches introduce BFQ-v0, whereas the remaining patches turn it
>> progressively into BFQ-v7r4. Here are some nice features of this last
>> version.
> 
> So, excellent work.  I haven't acteually followed the implementation
> of the scheduling logic itself but read all the papers and it seems
> great to me; however, the biggest problem that I have is that while
> being proposed as a separate iosched, this basically is an improvement
> of cfq.  It shares most of the infrastructure code, aims the same set
> of devices and usages scenarios and while a lot more clearly
> characterized and in general better performing even the scheduling
> behavior isn't that different from cfq.
> 

I am really glad to hear that, thanks.

> We do have multiple ioscheds but sans for anticipatory which pretty
> much has been superceded by cfq, they serve different purposes and I'd
> really hate the idea of carrying two mostly similar ioscheds in tree.
> 
> For some reason, blkcg implementation seems completely different but
> outside of that, bfq doesn't really seem to have diverged a lot from
> cfq and the most likely and probably only way for it to be merged
> would be if you just mutate cfq into bfq.  The whole effort is mostly
> about characterizing and refining the scheduling algorithm anyway,
> right?  I'd really love to see that happening.
> 

I do agree that bfq has essentially the same purpose as cfq. I am not sure that it is what you are proposing, but, in my opinion, since both the engine and all the new heuristics of bfq differ from those of cfq, a replacement would be most certainly a much easier solution than any other transformation of cfq into bfq (needless to say, leaving the same name for the scheduler would not be a problem for me). Of course, before that we are willing to improve what has to be improved in bfq.

BTW, we are already working on your recommendations for patch 01.

Paolo

> Thanks.
> 
> -- 
> tejun


--
Paolo Valente                                                 
Algogroup
Dipartimento di Fisica, Informatica e Matematica		
Via Campi, 213/B
41125 Modena - Italy        				  
homepage:  http://algogroup.unimore.it/people/paolo/
