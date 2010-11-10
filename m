From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/7] cgroups: Shrink struct cgroup_subsys
Date: Tue, 9 Nov 2010 18:15:13 -0800
Message-ID: <AANLkTinLtTfp0VxhRtbk916R8g4skGAMGXKF9M1tRzvD__17043.7473025688$1289355370$gmane$org@mail.gmail.com>
References: <4CC146A4.9090505@cn.fujitsu.com> <4CC146BA.7080009@cn.fujitsu.com>
	<AANLkTikf-1kLStxqi5UjP=vn3pqVBHy0OA7ibeWTkJ5z@mail.gmail.com>
	<4CD78946.5060405@cn.fujitsu.com>
	<AANLkTim6d1fQLZbkmZST3PTN0RMSs3m=oossF81pYBn9@mail.gmail.com>
	<4CD9ECD2.3030805@cn.fujitsu.com>
	<AANLkTinMr7VE4Os7rXWjiHWOVysv=oE0vHKduLWCN0bC@mail.gmail.com>
	<4CD9FE2D.2070108@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4CD9FE2D.2070108-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "akpm >> Andrew Morton" <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Stephane Eranian <eranian-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Nov 9, 2010 at 6:06 PM, Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
> That said, I'll happily drop this patch. It just came to me when I
> started to add new bool values to the structure. Or if you prefer
> bool xxx:1 or just bool xxx, I can do that.

bool xxx:1 is fine with me - I think it's worth keeping the semantics
of these being boolean flags as obvious as possible.

I just wouldn't invest much effort in similar patches in the future
(given that there are only likely to be, what, <20 instances of
cgroup_subsys in the kernel?). Shrinking a structure that had
potentially very many instances, such as css_set or cg_cgroup_link,
would be different of course.

Paul
