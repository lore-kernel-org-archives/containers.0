From: Sedat Dilek <sedat.dilek-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [GIT PULL] sysctl fixes for v4.13-rc1
Date: Thu, 13 Jul 2017 09:47:01 +0200
Message-ID: <CA+icZUUK8M3dwj9ns8951bzTcQ+-0Uo2r_6PDdeMX5XUq_VAsg@mail.gmail.com>
References: <87d195f9m7.fsf@xmission.com>
Reply-To: sedat.dilek-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87d195f9m7.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, Jul 13, 2017 at 2:45 AM, Eric W. Biederman
<ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
>
> Linus,
>
> Please pull the for-linus branch from the git tree:
>
>    git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/user-namespace.git for-linus
>
>    HEAD: 2fd1d2c4ceb2248a727696962cf3370dc9f5a0a4 proc: Fix proc_sys_prune_dcache to hold a sb reference
>
> A rather embarassing and hard to hit bug was merged into 4.11-rc1.
> Andrei Vagin tracked this bug now and after some starting at the
> code I came up with a fix.
>
> Eric
>
> From 2fd1d2c4ceb2248a727696962cf3370dc9f5a0a4 Mon Sep 17 00:00:00 2001
> From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> Date: Thu, 6 Jul 2017 08:41:06 -0500
> Subject: [PATCH] proc: Fix proc_sys_prune_dcache to hold a sb reference
>
> Andrei Vagin writes:
> FYI: This bug has been reproduced on 4.11.7
[...]

> Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org

Please add first affected Linux-kernel release.

Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org # 4.11

- Sedat -

> Reported-by: Andrei Vagin <avagin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Tested-by: Andrei Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
> Fixes: ace0c791e6c3 ("proc/sysctl: Don't grab i_lock under sysctl_lock.")
> Fixes: d6cffbbe9a7e ("proc/sysctl: prune stale dentries during unregistering")
> Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
