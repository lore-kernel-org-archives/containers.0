From: Manfred Spraul <manfred-nhLOkwUX5cPe2c5cEj3t2g@public.gmane.org>
Subject: Re: [PATCH 3/3] ipc namespace: copy settings from parent namespace
Date: Tue, 12 Aug 2014 22:39:05 +0200
Message-ID: <53EA7B69.9060800@colorfullife.com>
References: <1407828557-31995-1-git-send-email-manfred@colorfullife.com>
	<1407828557-31995-2-git-send-email-manfred@colorfullife.com>
	<1407828557-31995-3-git-send-email-manfred@colorfullife.com>
	<1407828557-31995-4-git-send-email-manfred@colorfullife.com>
	<877g2ec7tg.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <877g2ec7tg.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Rik van Riel <riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Rafael Aquini <aquini-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Davidlohr Bueso <davidlohr.bueso-VXdhtT5mjnY@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, 1vier1-S0/GAf8tV78@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Hi Eric,

On 08/12/2014 12:37 PM, Eric W. Biederman wrote:
> Manfred Spraul <manfred-nhLOkwUX5cPe2c5cEj3t2g@public.gmane.org> writes:
>
> Sigh. Patches for new code during the merge window.  It is a really
> rotten time to look at new things.
>
>> Right now, each new IPC namespace starts with the kernel default values.
>> This means that changes that were made to the limits get overwritten.
>>
>> With this patch, a new namespace inherits the settings from the parent
>> namespace, which is less surprising.
> In principle I agree.
>
> In practice I have to ask what have you done to survey applications
> that use the ipc namespace to see if they will break with this change in
> semantics.
I know this is the wrong answer, but:
What I find are problems caused by the current behavior.

See e.g.:
https://bugzilla.redhat.com/show_bug.cgi?id=1004724

Some background:
The e.g. sysvshm limits were not updated for many years and many
applications only ran properly if sysvshm limits are increased.
(now the defaults are large, but only since ~3.15)

Increasing is simple: sysctl kernel.shmmax=<>, but somehow this
must happen inside the container.

Right now, the most common approach seems to be the solution from the 
bugzilla above:
Just marc /proc as read-write and do it manually.

With the patch, the kernel would propagate the value from parent to child.

--
     Manfred
