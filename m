From: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: [PATCH v3 06/12] cgroup, memcg: move cgroup_event implementation
	to memcg
Date: Fri, 30 Aug 2013 13:05:08 +0200
Message-ID: <20130830110508.GA31605__27105.3521581509$1377860724$gmane$org@dhcp22.suse.cz>
References: <1376582550-12548-1-git-send-email-tj@kernel.org>
	<1376582550-12548-7-git-send-email-tj@kernel.org>
	<20130829181911.GA8517@mtj.dyndns.org>
	<20130830104755.GC28658@dhcp22.suse.cz>
	<20130830105210.GA30910@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130830105210.GA30910-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
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
Cc: hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri 30-08-13 06:52:10, Tejun Heo wrote:
> Hello, Michal.
> 
> On Fri, Aug 30, 2013 at 12:47:55PM +0200, Michal Hocko wrote:
> > > Updated as requested.  If there's still somthing missing, please let
> > > me know.  In case you're okay with the change, how do you wanna route
> > > it?  01-05 are already in cgroup/for-3.12 and the rest can either be
> > > applie to cgroup/for-3.12, which will likely to require some, mostly
> > > trivial, adjustments to memcg patches in -mm, or these all can be
> > > routed through -mm.  Any preference?
> > 
> > I do not care much but as Andrew wasn't CCed and this comes quite late he
> > might be reluctant to take it now and push in the next merge window. So
> > if you hurry with this then route it via your tree.
> 
> Hmmm... yeah, it's quite late and I think it'd be better to do it in
> the next cycle so that we can avoid disturbing memcg patches (again).
> If you ack the changes, I'll queue them in a separate branch after
> v3.11 is released so that memcg tree can be based on top of it.  Would
> that work?

Yes. Thanks!
-- 
Michal Hocko
SUSE Labs
