From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 1/5 V3] cgroup: remove redundate get/put of old css_set
	from migrate
Date: Tue, 20 Dec 2011 15:42:59 -0800
Message-ID: <20111220234259.GO10752@google.com>
References: <1324422873-31001-1-git-send-email-msb@chromium.org>
	<1324422873-31001-2-git-send-email-msb@chromium.org>
	<20111220231823.GK10752@google.com>
	<20111220234131.GV13529@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20111220234131.GV13529-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Mandeep Singh Baines <msb-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Cc: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>
List-Id: containers.vger.kernel.org

Hello,

On Tue, Dec 20, 2011 at 03:41:31PM -0800, Mandeep Singh Baines wrote:
> > Either put this as part of patch description or if you don't want it
> > to be part of commit message, put it between --- and diffstat.
> > Unfortunately, no tool understands "-- >8 --".
> > 
> 
> git-am should. From "man git-am":
> 
>        -c, --scissors
>            Remove everything in body before a scissors line (see git-
>            mailinfo(1)).
> 
> From "man git-mailinfo":
> 
>        --scissors
>            Remove everything in body before a scissors line. A line that
>            mainly consists of scissors (either ">8" or "8<") and perforation
>            (dash "-") marks is called a scissors line, and is used to request
>            the reader to cut the message at that line. If such a line appears
>            in the body of the message before the patch, everything before it
>            (including the scissors line itself) is ignored when this option is
>            used.
> 
>            This is useful if you want to begin your message in a discussion
>            thread with comments and suggestions on the message you are
>            responding to, and to conclude it with a patch submission,
>            separating the discussion and the beginning of the proposed commit
>            log message with a scissors line.
> 
>            This can enabled by default with the configuration option
>            mailinfo.scissors.
> 
> But I can stop using scissors if that is what you prefer.

Heh, that's cute.  If git-am is happy, I'm happy too.  Thanks for
letting me know.

Thanks.

-- 
tejun
