From: Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>
Subject: Re: [net-next v3 1/2] bpf, seccomp: Add eBPF filter capabilities
Date: Mon, 26 Feb 2018 19:49:48 -0800
Message-ID: <CAMp4zn9Gk62Wa6WYtmn9qj5zuFFR4MzS4TUGsG5Bx-JYZEc_4A@mail.gmail.com>
References: <20180226072702.GA27057@ircssh-2.c.rugged-nimbus-611.internal>
	<20180227005446.cmwsmh3fz4vhimmt@smitten>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20180227005446.cmwsmh3fz4vhimmt@smitten>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tycho Andersen <tycho-E0fblnxP3wo@public.gmane.org>
Cc: Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, Feb 26, 2018 at 4:54 PM, Tycho Andersen <tycho-E0fblnxP3wo@public.gmane.org> wrote:
> On Mon, Feb 26, 2018 at 07:27:05AM +0000, Sargun Dhillon wrote:
>> +config SECCOMP_FILTER_EXTENDED
>> +     bool "Extended BPF seccomp filters"
>> +     depends on SECCOMP_FILTER && BPF_SYSCALL
>> +     depends on !CHECKPOINT_RESTORE
>
> Why not just give -EINVAL or something in case one of these is
> requested, instead of making them incompatible at compile time?
>
> Tycho
There's already code to return -EMEDIUMTYPE if it's a non-classic, or
non-saved filter. Under the normal case, with CHECKPOINT_RESTORE
enabled, you should never be able to get that. I think it makes sense
to preserve this behaviour.

My rough plan is to introduce a mechanism to dump filters like you can
cBPF filters. If you look at my v1, there was a patch that did this.
Once this gets in, I can prepare that patch, and we can lift this
restriction.
