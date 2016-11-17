From: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Subject: Re: [REVIEW][PATCH 1/3] ptrace: Capture the ptracer's creds not
	PT_PTRACE_CAP
Date: Thu, 17 Nov 2016 15:14:22 -0800
Message-ID: <CAGXu5jKbVkCGVSoxNQ=pTCBX1Boe3rPR1P56P-kR9AHWYHBs2w__38955.4304573268$1479424472$gmane$org@mail.gmail.com>
References: <87twcbq696.fsf@x220.int.ebiederm.org>
	<20161018135031.GB13117@dhcp22.suse.cz>
	<8737jt903u.fsf@xmission.com> <20161018150507.GP14666@pc.thejh.net>
	<87twc9656s.fsf@xmission.com> <20161018191206.GA1210@laptop.thejh.net>
	<87r37dnz74.fsf@xmission.com> <87k2d5nytz.fsf_-_@xmission.com>
	<CALCETrU4SZYUEPrv4JkpUpA+0sZ=EirZRftRDp+a5hce5E7HgA@mail.gmail.com>
	<87y41kjn6l.fsf@xmission.com> <20161019172917.GE1210@laptop.thejh.net>
	<CALCETrWSY1SRse5oqSwZ=goQ+ZALd2XcTP3SZ8ry49C8rNd98Q@mail.gmail.com>
	<87pomwi5p2.fsf@xmission.com>
	<CALCETrUz2oU6OYwQ9K4M-SUg6FeDsd6Q1gf1w-cJRGg2PdmK8g@mail.gmail.com>
	<87pomwghda.fsf@xmission.com>
	<CALCETrXA2EnE8X3HzetLG6zS8YSVjJQJrsSumTfvEcGq=r5vsw@mail.gmail.com>
	<87twb6avk8.fsf_-_@xmission.com> <87oa1eavfx.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87oa1eavfx.fsf_-_-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Michal Hocko <mhocko-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, "linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org" <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>, Linux FS Devel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, Willy Tarreau <w@1wt.eu>
List-Id: containers.vger.kernel.org

On Thu, Nov 17, 2016 at 9:05 AM, Eric W. Biederman
<ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
>
> When the flag PT_PTRACE_CAP was added the PTRACE_TRACEME path was
> overlooked.  This can result in incorrect behavior when an application
> like strace traces an exec of a setuid executable.
>
> Further PT_PTRACE_CAP does not have enough information for making good
> security decisions as it does not report which user namespace the
> capability is in.  This has already allowed one mistake through
> insufficient granulariy.
>
> I found this issue when I was testing another corner case of exec and
> discovered that I could not get strace to set PT_PTRACE_CAP even when
> running strace as root with a full set of caps.
>
> This change fixes the above issue with strace allowing stracing as
> root a setuid executable without disabling setuid.  More fundamentaly
> this change allows what is allowable at all times, by using the correct
> information in it's decision.
>
> Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Fixes: 4214e42f96d4 ("v2.4.9.11 -> v2.4.9.12")
> Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> ---
> [...]
> diff --git a/include/linux/sched.h b/include/linux/sched.h
> index 348f51b0ec92..8fe58255d219 100644
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -1656,6 +1656,7 @@ struct task_struct {
>         struct list_head cpu_timers[3];
>
>  /* process credentials */
> +       const struct cred __rcu *ptracer_cred; /* Tracer's dredentials at attach */

Typo: credentials.

-Kees

-- 
Kees Cook
Nexus Security
