From: Jarek Poplawski <jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [BUG] net_cls: Panic occured when net_cls subsystem use
Date: Fri, 29 May 2009 10:22:32 +0000
Message-ID: <20090529102232.GA6279__13922.2260601402$1243592592$gmane$org@ff.dom.local>
References: <20090529141830.8ba30a24.usui@mxm.nes.nec.co.jp>
	<20090529074812.GA5483@ff.dom.local>
	<20090529080330.GB5483@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090529080330.GB5483-8HppEYmqbBCE+EvaaNYduQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Minoru Usui <usui-vEbCzmPPqHe45+QrQBaojngSJqDPrsil@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Jamal Hadi Salim <hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, May 29, 2009 at 08:03:30AM +0000, Jarek Poplawski wrote:
> On Fri, May 29, 2009 at 07:48:12AM +0000, Jarek Poplawski wrote:
> > On 29-05-2009 07:18, Minoru Usui wrote:
> ...
> > > I investigated this problem, and I found a bug in tc_ctl_tfilter() in net/sched/cls_api.c.
> > > 
> > > When 'tc filter add' command is executed and proto-tcf does not exist, 
> > > tcf_ctl_tfilter() allocates, initializes and chanins proto-tcf(tp) to
> > > cops->tcf_chain()'s chain before calling tp->ops->change().
> > > 
> > > If tp->ops->change() returns an error, tcf_ctl_tfilter() returns an error
> > > too, but proto-tcf(tp) is not unchained yet. 
> > > 
> > > I think tcf_ctl_tfilter() shouldn't chain proto-tcf to the chain before it returns
> > > an error.
> > 
> > I didn't verify this too much, so I might be wrong, but it looks like
> > cls_cgroup_classify() does things a bit different than others (doesn't
> > check the 'head' etc. for NULL), so maybe you should consider fixing
> > it instead? (Btw., the tc classifier maintainer added to Cc).
> 
> OOPS! Others mostly don't check this either, so my suggestion was wrong.

Hmm... Or maybe I wasn't so wrong; it seems classifiers which
don't assign the head during init do this check for NULL later.

Jarek P.
