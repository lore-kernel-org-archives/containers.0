From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 10/10] memcg: check memcg dirty limits in page writeback
Date: Wed, 6 Oct 2010 09:32:29 +0900
Message-ID: <AANLkTin0ymtTBbqpmcpCT835n8XWTJfaJKeU=CAj-=ej@mail.gmail.com>
References: <1286175485-30643-1-git-send-email-gthelen@google.com>
	<1286175485-30643-11-git-send-email-gthelen@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <1286175485-30643-11-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-Id: containers.vger.kernel.org

On Mon, Oct 4, 2010 at 3:58 PM, Greg Thelen <gthelen@google.com> wrote:
> If the current process is in a non-root memcg, then
> global_dirty_limits() will consider the memcg dirty limit.
> This allows different cgroups to have distinct dirty limits
> which trigger direct and background writeback at different
> levels.
>
> Signed-off-by: Andrea Righi <arighi@develer.com>
> Signed-off-by: Greg Thelen <gthelen@google.com>
> ---
> =A0mm/page-writeback.c | =A0 87 +++++++++++++++++++++++++++++++++++++++++=
+---------
> =A01 files changed, 72 insertions(+), 15 deletions(-)
>
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index a0bb3e2..c1db336 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -180,7 +180,7 @@ static unsigned long highmem_dirtyable_memory(unsigne=
d long total)
> =A0* Returns the numebr of pages that can currently be freed and used
> =A0* by the kernel for direct mappings.
> =A0*/
> -static unsigned long determine_dirtyable_memory(void)
> +static unsigned long get_global_dirtyable_memory(void)
> =A0{
> =A0 =A0 =A0 =A0unsigned long x;
>
> @@ -192,6 +192,58 @@ static unsigned long determine_dirtyable_memory(void=
)
> =A0 =A0 =A0 =A0return x + 1; =A0 /* Ensure that we never return 0 */
> =A0}
>

Just a nitpick.
You seem to like get_xxxx name.
But I think it's a redundant and just makes function name longer
without any benefit.
In kernel, many place doesn't use get_xxx naming.

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
