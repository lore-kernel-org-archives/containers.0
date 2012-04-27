From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 02/11] blkcg: __blkg_lookup_create() doesn't have to
	fail on radix tree preload failure
Date: Fri, 27 Apr 2012 07:47:09 -0700
Message-ID: <20120427144709.GJ27486__49704.8468016603$1335538042$gmane$org@google.com>
References: <1335477561-11131-1-git-send-email-tj@kernel.org>
	<1335477561-11131-3-git-send-email-tj@kernel.org>
	<20120427144258.GI10579@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120427144258.GI10579-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
Cc: axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

Hello,

On Fri, Apr 27, 2012 at 10:42:58AM -0400, Vivek Goyal wrote:
> On Thu, Apr 26, 2012 at 02:59:12PM -0700, Tejun Heo wrote:
> > __blkg_lookup_create() currently fails if radix_tree_preload() fails;
> > however, preload failrue doesn't imply insertion failure.  Don't fail
> > __blkg_lookup_create() on preload failure.
> > 
> 
> If we are going to try the insertion anyway irrespective of the fact
> whether preload succeeded or not, they why call radix_tree_preload()
> at all? How does that help?

Hmmm... it seems I originally misread radix_tree_node_alloc() - I
thought it didn't go through kmem_cache_alloc() if gfp_mask didn't
contain __GFP_WAIT.  If we don't use more permissible GFP flag during
preloading there's no point in preloading.  Will drop it.

Thanks.

-- 
tejun
