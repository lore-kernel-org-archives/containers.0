From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 07/12] cfq-iosched: implement hierarchy-ready cfq_group
	charge scaling
Date: Mon, 17 Dec 2012 13:17:38 -0800
Message-ID: <20121217211738.GD1844__49164.8889416412$1355779093$gmane$org@htj.dyndns.org>
References: <1355524885-22719-1-git-send-email-tj@kernel.org>
	<1355524885-22719-8-git-send-email-tj@kernel.org>
	<20121217205317.GI7235@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20121217205317.GI7235-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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

On Mon, Dec 17, 2012 at 03:53:18PM -0500, Vivek Goyal wrote:
> On Fri, Dec 14, 2012 at 02:41:20PM -0800, Tejun Heo wrote:
> > Currently, cfqg charges are scaled directly according to cfqg->weight.
> > Regardless of the number of active cfqgs or the amount of active
> > weights, a given weight value always scales charge the same way.  This
> > works fine as long as all cfqgs are treated equally regardless of
> > their positions in the hierarchy, which is what cfq currently
> > implements.  It can't work in hierarchical settings because the
> > interpretation of a given weight value depends on where the weight is
> > located in the hierarchy.
> 
> I did not understand this. Why the current scheme will not work with
> hierarchy?

Because the meaning of a weight changes depending on where the weight
exists in the hierarchy?

> While we calculate the vdisktime, this is calculated with the help
> of CFQ_DEFAULT_WEIGHT and cfqg->weight. So we scale used time slice
> in proportion to CFQ_DEFAULT_WEIGTH/cfqg->weight. So higher the weight
> lesser the charge and cfqg gets scheduled again faster and lower the
> weight, higher the vdisktime and cfqg gets scheduled less  frequently.
> 
> As every cfqg does the same thing on service tree, they automatically
> get fair share w.r.t their weight.
> 
> And this mechanism should not be impacted by the hierarchy because we
> have a separate service tree at separate level. This will not work
> only if you come up with one compressed tree and then weights will
> have to be adjusted. If we have a separate service tree in each group
> then it should work just fine.

Why would you create N service trees when you can almost trivially use
one by calcualting the effective weight?  You would have to be
adjusting all trees above whenever something changes in a child.

Thanks.

-- 
tejun
