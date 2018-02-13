From: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH net-next 3/3] bpf: Add eBPF seccomp sample programs
Date: Tue, 13 Feb 2018 12:18:18 -0800
Message-ID: <CAGXu5jK6o7515-5hfy=3aHZDCY3fryS522sB4RxgjJ4m67arZA__40570.991804316$1518553043$gmane$org@mail.gmail.com>
References: <20180213154320.GA3319@ircssh-2.c.rugged-nimbus-611.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20180213154320.GA3319-du9IEJ8oIxHXYT48pCVpJ3c7ZZ+wIVaZYkHkVr5ML8kVGlcevz2xqA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>
Cc: Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>, Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Feb 13, 2018 at 7:43 AM, Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org> wrote:
> +++ b/samples/bpf/seccomp1_kern.c
> @@ -0,0 +1,17 @@
> +#include <uapi/linux/seccomp.h>
> +#include <uapi/linux/bpf.h>
> +#include <uapi/linux/unistd.h>
> +#include "bpf_helpers.h"
> +#include <uapi/linux/errno.h>
> +
> +/* Returns EPERM when trying to close fd 999 */
> +SEC("seccomp")
> +int bpf_prog1(struct seccomp_data *ctx)
> +{
> +       if (ctx->nr == __NR_close && ctx->args[0] == 999)
> +               return SECCOMP_RET_ERRNO | EPERM;
> +
> +       return SECCOMP_RET_ALLOW;
> +}
> +
> +char _license[] SEC("license") = "GPL";
> [...]
> +++ b/samples/bpf/seccomp2_kern.c
> @@ -0,0 +1,24 @@
> +#include <uapi/linux/seccomp.h>
> +#include <uapi/linux/bpf.h>
> +#include <uapi/linux/unistd.h>
> +#include "bpf_helpers.h"
> +#include <uapi/linux/errno.h>
> +
> +static inline int unknown(struct seccomp_data *ctx)
> +{
> +       if (ctx->args[0] % 2 == 0)
> +               return SECCOMP_RET_KILL;
> +       return SECCOMP_RET_LOG;
> +}
> +
> +/* Returns errno on sched_yield syscall */
> +SEC("seccomp")
> +int bpf_prog1(struct seccomp_data *ctx)
> +{
> +       if (ctx->nr == __NR_sched_yield)
> +               return SECCOMP_RET_ERRNO | EPERM;
> +
> +       return SECCOMP_RET_ALLOW;
> +}
> +
> +char _license[] SEC("license") = "aGPL";

Nit: these should check architecture before syscall number. Since
they're samples, people look at them for and copy them regularly, they
should be as safe/correct as possible.

-Kees

-- 
Kees Cook
Pixel Security
