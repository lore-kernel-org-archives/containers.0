From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 07/11] blkcg: make request_queue bypassing on allocation
Date: Wed, 18 Apr 2012 14:42:55 -0700
Message-ID: <20120418214255.GA4772@google.com>
References: <1334347895-6268-1-git-send-email-tj@kernel.org>
	<1334347895-6268-8-git-send-email-tj@kernel.org>
	<20120413203205.GI26383@redhat.com>
	<20120413203726.GE12233@google.com>
	<20120413204446.GK26383@redhat.com>
	<20120413204710.GF12233@google.com>
	<20120413205501.GL26383@redhat.com>
	<20120413210548.GG12233@google.com>
	<20120413211640.GH12233@google.com>
	<1334664298.3766.62.camel@dabdike>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1334664298.3766.62.camel@dabdike>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
Cc: axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Apr 17, 2012 at 04:04:58PM +0400, James Bottomley wrote:
> > So, the current code is technically correct although subtle like hell.
> > We can RCU defer blk_put_queue() from blk_cleanup_queue() using
> > call_rcu() to make clear that RCU grace period is necessary there.
> > Any better ideas?
> 
> Not really ... except that perhaps we might redo LUN scanning to use
> just a single queue, so repurpose the LUN underneath, but not destroy
> the old queue and setup the new one?  It's a bit counter intuitive, but
> it shouldn't be impossible.

I think we're fine as-is with comment explaining that there can't be
any active dereferencing going on by the time release is reached.

Thanks.

-- 
tejun
