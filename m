From: "Paul Menage" <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] Add a 'trigger' callback on struct cftype.
Date: Tue, 11 Mar 2008 09:16:48 -0700
Message-ID: <6599ad830803110916i1bbc7c7an2412c0facb3496ef@mail.gmail.com>
References: <47D6A36F.2080706@openvz.org>
	<6599ad830803110900j7d47bd6eqf8747bdb704c9226@mail.gmail.com>
	<47D6AF98.4030204@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <47D6AF98.4030204-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
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
To: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Mar 11, 2008 at 9:13 AM, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org> wrote:
>
> --- a/include/linux/cgroup.h
>  +++ b/include/linux/cgroup.h
>  @@ -243,7 +243,7 @@ struct cftype {
>
>          */
>         int (*write_s64) (struct cgroup *cgrp, struct cftype *cft, s64 val);
>
>  -       void (*trigger) (struct cgroup *cgrp, unsigned int event);
>  +       int (*trigger) (struct cgroup *cgrp, unsigned int event);

To be more name-compatible with the other read_X/write_X functions,
how about write_void rather than trigger?

Paul
