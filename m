From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 6/6] freezer: kill unused set_freezable_with_signal()
Date: Sun, 11 Sep 2011 10:37:42 +0900
Message-ID: <20110911013742.GJ29319__32293.6326418587$1315705194$gmane$org@htj.dyndns.org>
References: <1314988070-12244-1-git-send-email-tj@kernel.org>
	<1314988070-12244-7-git-send-email-tj@kernel.org>
	<20110904184626.GA30101@redhat.com>
	<20110905023315.GB9807@htj.dyndns.org>
	<20110905162012.GA4445@redhat.com>
	<20110906032846.GA18425@mtj.dyndns.org>
	<20110908180159.GA4197@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110908180159.GA4197-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rjw-KKrjLPT3xs0@public.gmane.org, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello, Matt.

On Thu, Sep 08, 2011 at 11:01:59AM -0700, Matt Helsley wrote:
> Looking at the code and docs I realize I didn't explicitly mention that
> kthreads could not be frozen by the cgroup freezer. However, the code did
> not allow it. When freezing tasks the cgroup freezer always did:
> 
> 	freeze_task(task, true)
> 
> which would only freeze tasks without PF_FREEZER_NOSIG due to the second
> "sig_only" parameter. I believe this means it could not be used to
> freeze kthreads.
> 
> My feeling is kthreads should not be "managed" directly by userspace.
> Especially if that includes the ability to arbitrarily stop or freeze them.
> So it seems more appropriate to explicitly disallow freezing of kthreads
> via the cgroup freezer.

Oh yeah, that's what we should do and maybe that's what the current
code intends to achieve too but currently it ends up triggering
BUG_ON().

Thanks.

-- 
tejun
