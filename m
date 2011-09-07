From: Alex Bligh <alex-rWA27mgs/Jz10XsdtD+oqA@public.gmane.org>
Subject: Re: Kernel oops on 2.6.38 on destroying a container
Date: Wed, 07 Sep 2011 23:17:50 +0100
Message-ID: <0EA203C5B2BC7A3F8AF5BE57@nimrod.local>
References: <88648D2CBB3136EB9A6EFE7B@nimrod.local> <4E67E4B1.6050101@free.fr>
Reply-To: Alex Bligh <alex-rWA27mgs/Jz10XsdtD+oqA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4E67E4B1.6050101-GANU6spQydw@public.gmane.org>
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
To: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Daniel,

--On 7 September 2011 23:40:01 +0200 Daniel Lezcano 
<daniel.lezcano-GANU6spQydw@public.gmane.org> wrote:

> IMO you should fill a bug at :
>
> https://bugs.launchpad.net/ubuntu/+source/linux/
>
> and/or ask kernel-team-nLRlyDuq1AZFpShjVBNYrg@public.gmane.org
>
> They will be able to identify the fix in the mainstream, backport it and
> release a new kernel.
>
> An oops is critical enough to have them to pay attention to this problem.

I have:
 
https://bugs.launchpad.net/ubuntu/+source/linux-lts-backport-natty/+bug/843892

No one has responded just yet - I think they are all at the kernel
plumbers summit.

I was hoping someone might know why it does it.

-- 
Alex Bligh
