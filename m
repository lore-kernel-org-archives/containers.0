From: Paolo Valente <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
Subject: Re: [PATCH RFC - TAKE TWO - 02/12] block,
	bfq: add full hierarchical scheduling and cgroups support
Date: Fri, 30 May 2014 23:49:24 +0200
Message-ID: <1AE5EFA9-79A1-418A-8EF1-55764B8AA3BA@unimore.it>
References: <20140528221929.GG1419@htj.dyndns.org>
	<1401354343-5527-1-git-send-email-paolo.valente@unimore.it>
	<1401354343-5527-3-git-send-email-paolo.valente@unimore.it>
	<20140530153718.GB24871@htj.dyndns.org>
	<20140530153943.GC24871@htj.dyndns.org>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.2\))
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20140530153943.GC24871-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
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


Il giorno 30/mag/2014, alle ore 17:39, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> ha scritto:

> On Fri, May 30, 2014 at 11:37:18AM -0400, Tejun Heo wrote:
>> On Thu, May 29, 2014 at 11:05:33AM +0200, Paolo Valente wrote:
>>> diff --git a/include/linux/cgroup_subsys.h b/include/linux/cgroup_subsys.h
>>> index 768fe44..cdd2528 100644
>>> --- a/include/linux/cgroup_subsys.h
>>> +++ b/include/linux/cgroup_subsys.h
>>> @@ -39,6 +39,10 @@ SUBSYS(net_cls)
>>> SUBSYS(blkio)
>>> #endif
>>> 
>>> +#if IS_ENABLED(CONFIG_CGROUP_BFQIO)
>>> +SUBSYS(bfqio)
>>> +#endif
>> 
>> So, ummm, I don't think this is a good idea.  Why aren't you plugging
>> into the blkcg infrastructure as cfq does?  Why does it need to be a
>> separate controller?
> 
> If there's something which doesn't work for bfq in blkcg, please let
> me know.  I'd be happy to make it work.
> 

This will probably be very useful for us.

Thanks a lot,
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
