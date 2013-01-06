From: Rusty Russell <rusty-8n+1lVoiYb80n/F98K4Iww@public.gmane.org>
Subject: Re: [PATCH 06/13] cpuset: cleanup cpuset[_can]_attach()
Date: Mon, 07 Jan 2013 09:58:22 +1030
Message-ID: <87vcb951t5.fsf@rustcorp.com.au>
References: <1354138460-19286-1-git-send-email-tj@kernel.org>
	<1354138460-19286-7-git-send-email-tj@kernel.org>
	<50DACF5B.6050705@huawei.com>
	<20121226120415.GA18193@mtj.dyndns.org>
	<87zk0s5h7c.fsf@rustcorp.com.au>
	<20130102153439.GA11220@mtj.dyndns.org>
	<871ue35bzk.fsf@rustcorp.com.au>
	<20130103022911.GH11220@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20130103022911.GH11220-9pTldWuhBndy/B6EtB590w@public.gmane.org>
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
Cc: paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mhocko-AlSwsSmVLrQ@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> writes:

> Hello, Rusty.
>
> On Thu, Jan 03, 2013 at 11:17:11AM +1030, Rusty Russell wrote:
>> > So, I guess this currently is caught in a place which isn't here or
>> > there.  I'm pretty skeptical whether it makes sense to bother about
>> > static usages tho.  Can I keep them for static ones?
>> 
>> I didn't realize that cpuset_attach was a fastpath.  If it is, put a
>
> It isn't a hot path.  It's just a bit nasty to have to allocate them
> separately.
>
>> static there and I'll fix turn it into a bitmap when I need to.
>> Otherwise, please don't change the code in the first place.
>
> So, the plan to drop cpumask_t is still on?  If so, I'll leave
> cpumask_var_t.

Yep!

Thanks,
Rusty.
