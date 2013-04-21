From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 09/10] cpuset: allow to keep tasks in empty cpusets
Date: Sat, 20 Apr 2013 18:41:36 -0700
Message-ID: <20130421014136.GB19097@mtj.dyndns.org>
References: <517137A7.4020605@huawei.com> <517138A4.3070209@huawei.com>
	<20130419205821.GA15543@mtj.dyndns.org>
	<5171EDC1.4070805@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <5171EDC1.4070805-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Cc: Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

Hello, Li.

On Sat, Apr 20, 2013 at 09:22:09AM +0800, Li Zefan wrote:
> > migration is being done.  Another approach would be converting cgroup
> > to use SRCU instead, which would lessen pain on other places too.  The
> > only problem there would be that srcu_read_lock() is a bit more
> > expensive than rcu_read_lock().  I'm not sure whether that'd show up
> > in some hot path or not.  Ideas?
> 
> I guess we can live with rcu_read_lock() for now, and see if we can
> change it to srcu when other significant changes are done in all
> cgroup controllers. (hierarchy support in blkcg, etc..)

Ooh, I'm almost done with converting blk-throttle to support hierarchy
as cfq is already ready, blkcg will be ready very soon.  The only
thing left to do in terms of hierarchy support would be internal
weight for cpu.  :)

Thanks.

-- 
tejun
