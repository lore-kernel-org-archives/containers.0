From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/2] Add checkpoint/restart support for epoll files.
Date: Fri, 2 Oct 2009 13:36:09 -0700
Message-ID: <20091002203609.GD4189@count0.beaverton.ibm.com>
References: <1254164482-2193-2-git-send-email-matthltc@us.ibm.com>
	<4AC29086.8080407@librato.com>
	<20091002093050.GA4189@count0.beaverton.ibm.com>
	<4AC644C8.2070905@librato.com> <4AC656A8.8070103@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4AC656A8.8070103-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, Oct 02, 2009 at 03:38:16PM -0400, Oren Laadan wrote:
> 
> >>> I should probably change the code elsewhere too, but this test
> >>> is unnecessary because ckpt_obj_fetch() will complain anyway.
> >> I don't think it will complain since I don't see anything in the read or hash
> >> code that checks for negative objrefs. However moving this into
> > 
> > What is "this" that you want to move ?
> > 
> >> ckpt_obj_fetch() would get rid of alot of code much like passing NULL into
> >> kfree() does, so I'll remove this test.
> > 
> > ckpt_obj_fetch() won't complain about a negative value a-priori, but
> > the search is certain to fail. Nevertheless, I'll tighten the restart
> > related calls in objhash to ensure that.
> 
> I take it back:  ckpt_obj_fetch() returns -EINVAL when an objref isn't
> found, not that the original value was invalid.

Right, so then the question is whether it's possible to insert a negative
objref by modifying the checkpoint image before restart. As far as I can tell
that will work. Are you saying we don't need to care about that?

Cheers,
	-Matt Helsley
