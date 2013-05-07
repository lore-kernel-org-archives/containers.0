From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCHSET v2] blk-throttle: implement proper hierarchy support
Date: Tue, 7 May 2013 10:16:57 -0400
Message-ID: <20130507141657.GC7082@redhat.com>
References: <1367880372-28312-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1367880372-28312-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, May 06, 2013 at 03:45:39PM -0700, Tejun Heo wrote:
> Changes since the last take[L] are
> 
> * Unnecessary throtl_schedule_delayed_work() call dropped from 0007.
> 
> * throtl_log() implement in 0021 forgot to print space after blkg
>   path.  Fixed.
> 
> * 0030-blk-throttle-add-throtl_qnode-for-dispatch-fairness.patch added
>   to address dispatch fairness.
> 
> * 0031-blk-throttle-Account-for-child-group-s-start-time-in.patch
>   added to address unwarranted penalty of nested limit enforcement due
>   to staggered delays of slice start times at multiple levels.
> 
> The original patchset description follows.

Hi Tejun,

Can you please also update blkio-controller.txt file to reflect the
fact that now throttling also supports hierarchy. One of the places
which needs updation is following.

Hierarchical Cgroups
====================
- Currently only CFQ supports hierarchical groups. For throttling,
  cgroup interface does allow creation of hierarchical cgroups and
  internally it treats them as flat hierarchy.

Thanks
Vivek
