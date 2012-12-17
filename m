From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 07/12] cfq-iosched: implement hierarchy-ready cfq_group
	charge scaling
Date: Mon, 17 Dec 2012 14:12:54 -0800
Message-ID: <20121217221254.GH1844__15801.7790563919$1355782401$gmane$org@htj.dyndns.org>
References: <1355524885-22719-1-git-send-email-tj@kernel.org>
	<1355524885-22719-8-git-send-email-tj@kernel.org>
	<20121217205317.GI7235@redhat.com>
	<20121217211738.GD1844@htj.dyndns.org>
	<20121217212736.GB13691@redhat.com>
	<20121217213314.GF1844@htj.dyndns.org>
	<20121217214911.GC13691@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20121217214911.GC13691-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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

Hey, Vivek.

On Mon, Dec 17, 2012 at 04:49:11PM -0500, Vivek Goyal wrote:
> > Eh?  Then how would it compete with the children cfqgs?  You can
> > consider it as the hidden leaf node competing with the children cfqgs,
> > right?  So, you take the leaf weight and divide it by the total active
> > weight of all the children (including the hidden leaf node).  It isn't
> > different from the rest of the calculation.  It just looks different
> > because leaf_weight is stored elsewhere and we look down there and
> > then walke up.  The calculation being done is exactly the same one.
> 
> Again it is coming from multiplexing cfqg and cfqg->task_group. So
> effectively we are calculating the vfraction of task_group inside cfqg.

Or calculating the fraction of the hidden leaf node.

> Once you say cfqg->vfraction, I immediately think of total share of
> group (including task_group and all children cgroups).

Any tasks should be treated as member of the hidden leaf node, so...

> May be cfqg->task_group_vfraction (or cfqg->tg_fraction) is a better name.

I don't know.  Wouldn't just explaining clearly in the comment e
enough?  I think the name "vfraction" is already weird enough to
indicate that it's something which you need to read explanation about.
If that explanation is readily available as comment, I think it should
be okay.

> Also descrition says.
> 
> /* vfraction  the fraction of vdisktime that a cfqg is entitled to */
> 
> May be we can clarify it that it is share of task_group of cfqg.

Yeah, no objection.  Let's beef up the explanation there.

> I guess i am too familiar with how cpu has done it. I think I am getting
> confused with properties which belong to cfqg and properties which
> belong to cfqg->task_group.
> 
> I guess if we prefix fields belong to task_group with somete suitable
> string, it might become little easier to understand.

I usually am not a big fan of adding wordy prefixes.  I think they
tend to obfuscate/frustrate more than help.  Let's stick a weird (that
is, non-generic) name to something weird and explain it well in the
comment.

Thanks.

-- 
tejun
