From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 3/3] cgroups: introduce link_css_set() to remove duplicate
	code
Date: Tue, 2 Dec 2008 14:16:29 -0800
Message-ID: <6599ad830812021416s76e393c8x5e3f5afa1bc370e2__20409.1171538041$1228256418$gmane$org@mail.gmail.com>
References: <492FC1C2.9050001@cn.fujitsu.com>
	<6599ad830812011620ld861aabgc70846a07ce1d487@mail.gmail.com>
	<4934A8FB.80904@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4934A8FB.80904-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, Dec 1, 2008 at 7:18 PM, Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
>
> How about:
>
> /**
>  * link_css_set - a helper function to link a css_set to a cgroup
>  * @ tmp_cg_links: cg_cgroup_link objects allocated by allocate_cg_links()
>  * @ cg: the css_set to be linked
>  * @ cgrp: the destination cgroup
>  */

Sounds good.

>
> Because we are linking all the css_sets to the root cgroup, so I think root_cgrp
> helps readability.
>

But we're creating the hierarchy at this point, so there can clearly
only be one cgroup any (which is the root cgroup).

I don't think it's any more or less readable, it just seems an
unnecessary change.

Paul
