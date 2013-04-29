From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 02/10] freezer: skip waking up tasks with PF_FREEZER_SKIP
	set
Date: Mon, 29 Apr 2013 15:08:31 -0700
Message-ID: <20130429220831.GC2395@htj.dyndns.org>
References: <1367271946-7239-1-git-send-email-ccross@android.com>
	<1367271946-7239-3-git-send-email-ccross@android.com>
	<20130429215157.GA2395@htj.dyndns.org>
	<20130429215745.GB2395@htj.dyndns.org>
	<CAMbhsRQHkm=XTYtummEZq1h4sa-tRGwLpk8Uyhpj9D3+jQF3dg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAMbhsRQHkm=XTYtummEZq1h4sa-tRGwLpk8Uyhpj9D3+jQF3dg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Colin Cross <ccross-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>
Cc: Len Brown <len.brown-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Linux PM list <linux-pm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>, Arve =?iso-8859-1?B?SGr4bm5lduVn?= <arve-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>, Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Hey,

On Mon, Apr 29, 2013 at 03:02:19PM -0700, Colin Cross wrote:
> See the first patch in the series (which isn't available in the
> archive yet, so I can't link to it).  The short version is that

It didn't arrive in my lkml folder either.  Maybe vger is taking some
time distributing emails.

> Android goes through suspend/resume very often (every few seconds when
> on a busy wifi network with the screen off), and a significant portion
> of the energy used to go in and out of suspend is spent in the
> freezer.  This patch series takes the most common userspace sleep
> points and converts them to PF_FREEZER_SKIP, which reduces the number
> of context switches for every suspend or resume event on a
> freshly-booted Android device from 1000 to 25, and reduces the time

Ah, okay, so you're spreading PF_FREEZER_SKIP.  When you post patches
which touch the freezer can you please cc me and Oleg Nesterov
<oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> (I'll ping him this time)?  Freezer has been very
subtly broken in various ways and many kthread users are still broken,
so let's tread carefully.

> spent freezing by a factor of 5.  It will have a similar effect on a
> non-Android system, although those generally don't care about
> suspend/resume optimization.

Yeah, if it's something which makes actual difference rather than
"this seems to be a good idea" thing, sure, let's find a way.

Thanks.

-- 
tejun
