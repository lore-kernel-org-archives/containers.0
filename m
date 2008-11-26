From: Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 1/2] Add flags for user-space and in-kernel process
	creation
Date: Wed, 26 Nov 2008 08:55:45 +0400
Message-ID: <200811260755.46949.major__41726.4764117592$1227675492$gmane$org@openvz.org>
References: <1227541175-30301-1-git-send-email-major@openvz.org>
	<1227541175-30301-2-git-send-email-major@openvz.org>
	<20081124160211.GE27238@hawkmoon.kerlabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20081124160211.GE27238-Hu8+6S1rdjywhHL9vcZdMVaTQe2KTcn/@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Monday 24 November 2008 19:02 Louis Rilling wrote:
> On 24/11/08 18:39 +0300, Andrey Mirkin wrote:
> > Introduce 2 flags for user-space and in-kernel process creation during
> > restart procedure.
> > Also a stub function for in-kernel process restart is introduced.
>
> [...]
>
> > diff --git a/checkpoint/sys.c b/checkpoint/sys.c
> > index 7745500..e4a9287 100644
> > --- a/checkpoint/sys.c
> > +++ b/checkpoint/sys.c
> > @@ -264,8 +264,8 @@ asmlinkage long sys_restart(int crid, int fd,
> > unsigned long flags) pid_t pid;
> >  	int ret;
> >
> > -	/* no flags for now */
> > -	if (flags)
> > +	if ((flags & (CR_CTX_RSTR_IN_USERSPACE | CR_CTX_RSTR_IN_USERSPACE)) ==
> > +			(CR_CTX_RSTR_IN_USERSPACE | CR_CTX_RSTR_IN_USERSPACE))
>
> I guess that the intent was:
> +	if ((flags & (CR_CTX_RSTR_IN_USERSPACE | CR_CTX_RSTR_IN_KERNEL)) ==
> +			(CR_CTX_RSTR_IN_USERSPACE | CR_CTX_RSTR_IN_KERNEL))
>
> ?

Oh, of course it should be like this.
I've sent wrong patch. Will resend correct one.

Andrey
