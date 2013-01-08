From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH UPDATED 15/24] cfq-iosched: enable full blkcg hierarchy
	support
Date: Tue, 8 Jan 2013 09:19:29 -0800
Message-ID: <20130108171929.GX3926@htj.dyndns.org>
References: <1356726946-26037-1-git-send-email-tj@kernel.org>
	<1356726946-26037-16-git-send-email-tj@kernel.org>
	<20130107163405.GE3926@htj.dyndns.org>
	<20130108144240.GA29635@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130108144240.GA29635-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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

On Tue, Jan 08, 2013 at 09:42:40AM -0500, Vivek Goyal wrote:
> > +A has children and further distributes its 57% among the children and
> > +the implicit leaf node. The total active weight at this level is
> > +AA:500 + AB:1000 + A-leaf:750 = 2250.
> > +
> > + A-leaf    : ( 750 / 2250) * A =~ 19%
> > + AA(-leaf) : ( 500 / 2250) * A =~ 12%
> > + AB(-leaf) : (1000 / 2250) * A =~ 25%
> 
> Hi Tejun,
> 
> What does (-leaf) is supposed to signify? I can understand that A-leaf
> tells the share of A's tasks which are effectively in A-leaf group. 

It's saying that the weight for AA and AA-leaf are the same.

> Will just plain AA and AB be more clear?

I don't know, maybe.

Thanks.

-- 
tejun
