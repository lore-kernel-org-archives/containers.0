From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [PATCH 2/5] ftrace: use code patching for ftrace graph tracer
Date: Tue, 25 Nov 2008 21:35:46 -0800
Message-ID: <20081125213546.ff4eddf4.akpm@linux-foundation.org>
References: <20081126051622.134970943@goodmis.org>
	<20081126051709.774546196@goodmis.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20081126051709.774546196-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>
Cc: Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Rostedt <srostedt-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Frederic-FOgKQjlUJ6BQetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Steven-FOgKQjlUJ6BQetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Sukadev-FOgKQjlUJ6BQetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Harvey Harrison <harvey.harrison-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, 26 Nov 2008 00:16:24 -0500 Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org> wrote:

> From: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>
> 
> Impact: more efficient code for ftrace graph tracer
> 
> This patch uses the dynamic patching, when available, to patch
> the function graph code into the kernel.
> 
> This patch will ease the way for letting both function tracing
> and function graph tracing run together.
> 
> ...
>
> +static int ftrace_mod_jmp(unsigned long ip,
> +			  int old_offset, int new_offset)
> +{
> +	unsigned char code[MCOUNT_INSN_SIZE];
> +
> +	if (probe_kernel_read(code, (void *)ip, MCOUNT_INSN_SIZE))
> +		return -EFAULT;
> +
> +	if (code[0] != 0xe9 || old_offset != *(int *)(&code[1]))

erk.  I suspect that there's a nicer way of doing this amongst our
forest of get_unaligned_foo() interfaces.  Harvey will know.

> +		return -EINVAL;
> +
> +	*(int *)(&code[1]) = new_offset;

Might be able to use put_unaligned_foo() here.

The problem is that these functions use sizeof(*ptr) to work out what
to do, so a cast is still needed.  A get_unaligned32(ptr) would be
nice.  One which takes a void* and assumes CPU ordering.

> +	if (do_ftrace_mod_code(ip, &code))
> +		return -EPERM;
> +
> +	return 0;
> +}
> +
