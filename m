From: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>
Subject: Re: [PATCHSET] block: cosmetic updates to blkcg API
Date: Fri, 20 Apr 2012 10:10:05 +0200
Message-ID: <20120420081004.GH7505@kernel.dk>
References: <1334609847-12747-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1334609847-12747-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, Apr 16 2012, Tejun Heo wrote:
> Hello,
> 
> With recent blkcg updates, any out-of-tree change is already way
> broken and it's a good time to clean up blkcg API for more
> consistency.  This patchset makes a series of mostly cosmetic changes
> in an attempt to make the blkcg API easier on the eyes.
> 
> This is finally the last patchset of the long blkcg API update effort.
> I think that we now have something which at least is sane & logical
> and can be improved incrementally without having to be turned upside
> down.  My thanks to everyone involved for enduring the boring and
> rather painful process.
> 
> This patchset contains the following six patches.
> 
> 0001-blkcg-blkg_rwstat_read-was-missing-inline.patch
> 0002-blkcg-remove-blkio_group-path.patch
> 0003-blkcg-style-cleanups-for-blk-cgroup.h.patch
> 0004-blkcg-mass-rename-of-blkcg-API.patch
> 0005-blkcg-embed-struct-blkg_policy_data-in-policy-specif.patch
> 0006-blkcg-collapse-blkcg_policy_ops-into-blkcg_policy.patch
> 
> Other than 0002 which removes blkg->path[], none of the patches makes
> any functional difference.
> 
> This patchset is on top of
> 
>   block/for-3.5/core 5bc4afb1ec "blkcg: drop BLKCG_STAT_{PRIV|POL|OFF} macros"
> + [1] [PATCHSET] block: per-queue policy activation, take#2

Applied, thanks.

-- 
Jens Axboe
