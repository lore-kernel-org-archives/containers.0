From: Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>
Subject: Re: [net-next v3 0/2] eBPF seccomp filters
Date: Mon, 26 Feb 2018 19:46:19 -0800
Message-ID: <CAMp4zn9BAxv40q56PPsmvXcD000N4ZuAN3g=OF=od18_gT8UEQ@mail.gmail.com>
References: <20180226072651.GA27045@ircssh-2.c.rugged-nimbus-611.internal>
	<20180226230418.46nczgkh5csakyu7@ast-mbp>
	<CAGXu5jLdOcrn16q9pQ7JwTf88AVsL0o5LMJ=4P6vRN36u-_k_g@mail.gmail.com>
	<20180227010153.leq7u45z57ypip2z@smitten>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20180227010153.leq7u45z57ypip2z@smitten>
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
Cc: Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>, Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, Feb 26, 2018 at 5:01 PM, Tycho Andersen <tycho-E0fblnxP3wo@public.gmane.org> wrote:
> On Mon, Feb 26, 2018 at 03:20:15PM -0800, Kees Cook wrote:
>> On Mon, Feb 26, 2018 at 3:04 PM, Alexei Starovoitov
>> <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>> > On Mon, Feb 26, 2018 at 07:26:54AM +0000, Sargun Dhillon wrote:
>> >> This patchset enables seccomp filters to be written in eBPF. Although, this
>> >> [...]
>> > The main statement I want to hear from seccomp maintainers before
>> > proceeding any further on this that enabling eBPF in seccomp won't lead
>> > to seccomp folks arguing against changes in bpf core (like verifier)
>> > just because it's used by seccomp.
>> > It must be spelled out in the commit log with explicit Ack.
>>
>> The primary thing I'm concerned about with eBPF and seccomp is
>> side-effects from eBPF programs running at syscall time. This is an
>> extremely sensitive area, and I want to be sure there won't be
>> feature-creep here that leads to seccomp getting into a bad state.
>>
>> As long as seccomp can continue have its own verifier,
>
> I guess these patches should introduce some additional restrictions in
> kernel/seccomp.c then? Based on my reading now, it's whatever the eBPF
> verifier allows.
>
Like what? The helpers allowed are listed in seccomp.c. You have the
same restrictions as the traditional eBPF verifier (no unsafe memory
access, jumps backwards, etc..). I'm not sure which built-in eBPF
functionality presents risk.

>> I *think* this will be fine, though, again I remain concerned about
>> maps, etc. I'm still reviewing these patches and how they might
>> provide overlap with Tycho's needs too, etc.
>
> Yes, it's on my TODO list to take a look at how to do it as suggested
> by Alexi on top of this set before posting a v2. Haven't had time
> recently, though.
>
> Cheers,
>
> Tycho

There's a lot of interest (in general) of having a mechanism to do
notifications to userspace processes from eBPF for a variety of use
cases. I think that this would be valuable for more than just seccomp,
if it's implemented in a general purpose manner.
