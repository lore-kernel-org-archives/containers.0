From: chris hyser <chris.hyser-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: Re: [net-next v3 0/2] eBPF seccomp filters
Date: Tue, 27 Feb 2018 16:22:45 -0500
Message-ID: <cda8f13d-79b6-077a-2129-d2d52dc8efd1@oracle.com>
References: <20180226072651.GA27045@ircssh-2.c.rugged-nimbus-611.internal>
	<20180226230418.46nczgkh5csakyu7@ast-mbp>
	<CAGXu5jLdOcrn16q9pQ7JwTf88AVsL0o5LMJ=4P6vRN36u-_k_g@mail.gmail.com>
	<CALCETrXNODxWkcwF-LbXBn+Ju7QJEyi3JR+spsRX4ecg8d1iMQ@mail.gmail.com>
	<CAGXu5j+64WzxjBnpQxYCU50ak+VqVw1y0W+MWygFodxsDqEZRw@mail.gmail.com>
	<db759dd2-31dc-d094-251d-d4c1e8af8704@oracle.com>
	<CAGXu5j+idW9AjZHVdeedqLOFXriObUJLvcw8-9k5WxyQF8EWrg@mail.gmail.com>
	<ddbefdda-f3b8-3956-fa0f-dcba8cf8e7d9@oracle.com>
	<CAGXu5jKnk90Yruhx_=t8yW2ziLaubqW80pxB95g5W_XnMuT1mA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CAGXu5jKnk90Yruhx_=t8yW2ziLaubqW80pxB95g5W_XnMuT1mA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Content-Language: en-US
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Cc: Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>, Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>, Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

On 02/27/2018 02:19 PM, Kees Cook wrote:
> On Tue, Feb 27, 2018 at 8:59 AM, chris hyser <chris.hyser-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org> wrote:
>> I will try to find that discussion. As someone pointed out here though, eBPF
> 
> A good starting point might be this:
> https://lwn.net/Articles/441232/

Thanks. A fair amount of reading referenced there :-). In particular I'll be curious to find out what happened to this idea:

"Essentially, that would make for three choices for each system call: enabled, disabled, or filtered."

Something like that might address some of the security concerns in that a simple go/no go on syscall number need not 
incur the performance hit nor increased attack surface of running c/eBPF code, but it is there for argument checking, 
etc if you need it. Basically instead of the kernel making the flexibility/performance/security trade-off in advance, 
you leave it to user code/policy.

Anyway, lest it is not clear :-), I think your instincts on security and eBPF are dead on. At the same time it is 
powerful and useful. So, how to make it optional?

-chrish
