From: Tao Ma <tm-d1IQDZat3X0@public.gmane.org>
Subject: Re: [PATCH 18/21] blkcg: move blkio_group_conf->weight to cfq
Date: Tue, 03 Apr 2012 06:20:10 +0800
Message-ID: <4F7A261A.9000200__1645.54405860162$1333405222$gmane$org@tao.ma>
References: <1332975091-10950-1-git-send-email-tj@kernel.org>
	<1332975091-10950-19-git-send-email-tj@kernel.org>
	<4F7A1C8B.3010402@tao.ma>
	<20120402214938.GA19634@dhcp-172-17-108-109.mtv.corp.google.com>
	<4F7A2217.2030201@tao.ma>
	<20120402221702.GA21017@dhcp-172-17-108-109.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20120402221702.GA21017-RcKxWJ4Cfj1J2suj2OqeGauc2jM2gXBXkQQo+JxHRPFibQn6LdNjmg@public.gmane.org>
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
Cc: axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On 04/03/2012 06:17 AM, Tejun Heo wrote:
> On Tue, Apr 03, 2012 at 06:03:03AM +0800, Tao Ma wrote:
>> Currently weight is just used to calculate the time slice of different
>> cfq group, right? So why can't it be used to indicate other weight? So
>> say, if we are just want to use iops to indicate the difference between
>> different cgroups(100 weight vs 200 weight), so one process will send
>> 100 ios while the other will send 200 ios just for example.
> 
> Because it's configuring stuff which is completely unrelated.  Let's
> say you added a new elevator w/ iops based proportional IO which
> shares blkio.weight configuration with cfq but nothing else and in
> turn your new thing would probably need some other config parameters
> which don't make much sense for cfq, right?
> 
> Now, let's say there's a system which has two hard drives and sda is
> using cfq and sdb is using your new elevator and you're trying to
> configure cgroup blkio limits.  Now, you have blkio.weight which
> applies to both elevators and other configurations which aren't and
> from the looks of it there's no way to tell which configuration
> controls what.
> 
> It also makes the configuration implementation hairier.  We'll need
> callbacks from blkcg core layer to all policies to notify changes to
> per-cgroup configuration and from there policies would have to decide
> whether it has overriding per-cgroup-device configuration.  It's not
> even clear we even want per-cgroup configuration.  blk-throttle only
> has per-cgroup-device configuration after all.
Fair enough.
> 
> So, again, no.  blkcg.weight isn't and won't be generic.
> 
>> We will need a new iops_weight in your option to be exported?
> 
> Yeah, just add config and stat files prefixed with the name of the new
> blkcg policy.
OK, I will add a new config file for it.

Thanks
Tao
