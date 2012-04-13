From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 07/11] blkcg: make request_queue bypassing on allocation
Date: Fri, 13 Apr 2012 16:32:05 -0400
Message-ID: <20120413203205.GI26383__2981.40169256858$1334349143$gmane$org@redhat.com>
References: <1334347895-6268-1-git-send-email-tj@kernel.org>
	<1334347895-6268-8-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1334347895-6268-8-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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

On Fri, Apr 13, 2012 at 01:11:31PM -0700, Tejun Heo wrote:
> With the previous change to guarantee bypass visiblity for RCU read
> lock regions, entering bypass mode involves non-trivial overhead and
> future changes are scheduled to make use of bypass mode during init
> path.  Combined it may end up adding noticeable delay during boot.
> 
> This patch makes request_queue start its life in bypass mode, which is
> ended on queue init completion at the end of
> blk_init_allocated_queue(), and updates blk_queue_bypass_start() such
> that draining and RCU synchronization are performed only when the
> queue actually enters bypass mode.
> 
> This avoids unnecessarily switching in and out of bypass mode during
> init avoiding the overhead and any nasty surprises which may step from
> leaving bypass mode on half-initialized queues.

Tejun, I am not sure that this will fix the problem completely. I think
we will still face the overhead of synchronize_rcu() in
blkcg_deactivate_policy() as it will be called from cfq_exit_queue() for
initialized queues.

In the past I had I had used synchronize_rcu() in cfq_exit_queue() and
noticed the overhead. Looks like driver was creating fully initialized
queues and tearing these apart soon.

Thanks
Vivek
