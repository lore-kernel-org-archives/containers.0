From: Colin Cross <ccross-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 02/10] freezer: skip waking up tasks with PF_FREEZER_SKIP
	set
Date: Mon, 29 Apr 2013 15:02:19 -0700
Message-ID: <CAMbhsRQHkm=XTYtummEZq1h4sa-tRGwLpk8Uyhpj9D3+jQF3dg__38299.6412263767$1367272952$gmane$org@mail.gmail.com>
References: <1367271946-7239-1-git-send-email-ccross@android.com>
	<1367271946-7239-3-git-send-email-ccross@android.com>
	<20130429215157.GA2395@htj.dyndns.org>
	<20130429215745.GB2395@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20130429215745.GB2395-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
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
Cc: Len Brown <len.brown-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Linux PM list <linux-pm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>, =?ISO-8859-1?Q?Arve_Hj=F8nnev=E5g?= <arve-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>, Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, Apr 29, 2013 at 2:57 PM, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:
> On Mon, Apr 29, 2013 at 02:51:57PM -0700, Tejun Heo wrote:
>> I feel a bit weary of changes which try to optimize state checks for
>> freezer because the synchronization rules are kinda fragile and things
>> may not work reliably depending on who's testing the flag, and it has
>> been subtly broken in various ways in the past (maybe even now).  Can
>
> And BTW, this is why the function is only used when checking whether a
> task is frozen rather than to decide to issue freeze_task() on it, and
> it seems your change is correct now that we don't have per-task FREEZE
> flag but I can't say I like the change.  I'd really like to keep
> things as dumb as possible for freezer.

See the first patch in the series (which isn't available in the
archive yet, so I can't link to it).  The short version is that
Android goes through suspend/resume very often (every few seconds when
on a busy wifi network with the screen off), and a significant portion
of the energy used to go in and out of suspend is spent in the
freezer.  This patch series takes the most common userspace sleep
points and converts them to PF_FREEZER_SKIP, which reduces the number
of context switches for every suspend or resume event on a
freshly-booted Android device from 1000 to 25, and reduces the time
spent freezing by a factor of 5.  It will have a similar effect on a
non-Android system, although those generally don't care about
suspend/resume optimization.
