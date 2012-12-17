From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 07/12] cfq-iosched: implement hierarchy-ready cfq_group
	charge scaling
Date: Mon, 17 Dec 2012 13:33:14 -0800
Message-ID: <20121217213314.GF1844__5990.7445837327$1355780022$gmane$org@htj.dyndns.org>
References: <1355524885-22719-1-git-send-email-tj@kernel.org>
	<1355524885-22719-8-git-send-email-tj@kernel.org>
	<20121217205317.GI7235@redhat.com>
	<20121217211738.GD1844@htj.dyndns.org>
	<20121217212736.GB13691@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20121217212736.GB13691-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello,

On Mon, Dec 17, 2012 at 04:27:36PM -0500, Vivek Goyal wrote:
> What I do care about is atleast being able to read and understand the
> code easily. Right now, it is hard to understand. I am still struggling
> to wrap my head around it.

Hmm... I thought it was really simple.  Maybe I'm just too familiar
with it.  You just walk up the tree multiplying the fraction you have
at each level.  It really doesn't get much simpler than that.

> For example, while adding a group to service tree we calculate
> cfqg->vfaction as follows.
> 
> vfr = vfr * pos->leaf_weight / pos->level_weight;
> 
> and then 
> 
> vfr = vfr * pos->weight / parent->level_weight;
> 
> cfqg->vfraction = max_t(unsigned, vfr, 1)
> 
> If cfqg->vfraction is about cfqg then why should we take into account
> leaf_weight and level_weight. We should be just worried about pos->weight
> and parent->level_weight and that should determine vfaction of cfqg.

Eh?  Then how would it compete with the children cfqgs?  You can
consider it as the hidden leaf node competing with the children cfqgs,
right?  So, you take the leaf weight and divide it by the total active
weight of all the children (including the hidden leaf node).  It isn't
different from the rest of the calculation.  It just looks different
because leaf_weight is stored elsewhere and we look down there and
then walke up.  The calculation being done is exactly the same one.

Thanks.

-- 
tejun
