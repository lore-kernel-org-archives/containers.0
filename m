From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 12/12] cfq-iosched: add hierarchical cfq_group statistics
Date: Tue, 18 Dec 2012 14:26:33 -0500
Message-ID: <20121218192633.GC25908@redhat.com>
References: <1355524885-22719-1-git-send-email-tj@kernel.org>
	<1355524885-22719-13-git-send-email-tj@kernel.org>
	<20121218191117.GD24050@redhat.com>
	<20121218191425.GO1844@htj.dyndns.org>
	<20121218191854.GB25908@redhat.com>
	<20121218192155.GQ1844@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20121218192155.GQ1844-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
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
Cc: axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Dec 18, 2012 at 11:21:55AM -0800, Tejun Heo wrote:
> On Tue, Dec 18, 2012 at 02:18:54PM -0500, Vivek Goyal wrote:
> > > Yeah, hmmm, maybe we should add another set of counters to carry stats
> > > from dead ones?  Avoiding hierarchical accounting overhead in hot path
> > > while remembering by-gones shouldn't be that hard.  Will work on that.
> > 
> > So are you planning to migrate the stats to parent when a cgroup is being
> > deleted?  That should make sure we don't do hierarhical update.
> 
> Yeah, something like that.  The current statistics being !hierarchical
> means that we need to keep them separate from the actual stats, so
> it'll end up with another set of stats.  Kinda nasty but I don't see
> any better way out.

Separate stats for hierarchical migration make sense to me.

Thanks
Vivek
