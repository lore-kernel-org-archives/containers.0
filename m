From: Paul Moore <pmoore-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net-next 0/3] eBPF Seccomp filters
Date: Tue, 13 Feb 2018 16:08:13 -0500
Message-ID: <CAGH-KgtPNrjuTLq_yu0XbO263kVh-b8B9a2Yi6L8x4WhTTyjBw__16605.9062853039$1518556009$gmane$org@mail.gmail.com>
References: <20180213154244.GA3292@ircssh-2.c.rugged-nimbus-611.internal>
	<CAGXu5jLiYh0rSRuJ_-2xLB03Wod5G07njpoESR4SnmsmiUnsEw@mail.gmail.com>
	<CAMp4zn8VNurTjmrUtHnaK21A4hUQQz5tnarj15vmTU+TjY79XA@mail.gmail.com>
	<CAEk6tEw3ty0kBH+06TYt4=Ywt-4_cHBa9f8p3ajMghtjRkHmMg@mail.gmail.com>
	<CAMp4zn-Lw0grNrCyjHJZUje1Aznaj03iAUWZ86ki68MZMN1-zA@mail.gmail.com>
	<CAGXu5jKv3QFVKLhok1JWiPamE0b4CqLTO-hx8sP0KWED921=6w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CAGXu5jKv3QFVKLhok1JWiPamE0b4CqLTO-hx8sP0KWED921=6w-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
Cc: Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, paul-r2n+y4ga6xFZroRs9YW3xA@public.gmane.org, Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>, Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Feb 13, 2018 at 3:16 PM, Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org> wrote:
> On Tue, Feb 13, 2018 at 9:31 AM, Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org> wrote:
>> On Tue, Feb 13, 2018 at 9:02 AM, Jessie Frazelle <me-XvZkT8t+Da5Wk0Htik3J/w@public.gmane.org> wrote:
>>> On Tue, Feb 13, 2018 at 11:29 AM, Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org> wrote:
>>>> On Tue, Feb 13, 2018 at 7:47 AM, Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org> wrote:
>>>>> What's the reason for adding eBPF support? seccomp shouldn't need it,
>>>>> and it only makes the code more complex. I'd rather stick with  -- cBPF
>>>>> until we have an overwhelmingly good reason to use eBPF as a "native"
>>>>> seccomp filter language.
>>>>>
>>>> Three reasons:
>>>> 1) The userspace tooling for eBPF is much better than the user space
>>>> tooling for cBPF. Our use case is specifically to optimize Docker
>>>> policies. This is roughly what their seccomp policy looks like:
>>>> https://github.com/moby/moby/blob/master/profiles/seccomp/default.json.
>>>> It would be much nicer to be able to leverage eBPF to write this in C,
>>>> or any other the other languages targetting eBPF. In addition, if we
>>>> have write-only maps, we can exfiltrate information from seccomp, like
>>>> arguments, and errors in a relatively cheap way compared to cBPF, and
>>>> then extract this via the bcc stack. Writing cBPF via C macros is a
>>>> pain, and the off the shelf cBPF libraries are getting no love.

What do you mean "no love"?  I would consider libseccomp is a cBPF
library and it is actively maintained/developed.

>>>> The eBPF community is *exploding* with contributions.
>
> eBPF moving quickly is a disincentive from my perspective, as I want
> absolutely zero surprises when it comes to seccomp. :) Given the
> steady stream of exploitable flaws in eBPF, I don't want seccomp
> anywhere near it. :( Many distros ship with the bpf() syscall
> disabled, for example (or entirely compiled out, as in Chrome OS and
> Android).
>
> The convenience of writing C for eBPF output is certainly nice, but it
> seems like either LLVM could grow a cBPF backend, or libseccomp could
> be improved to provide the needed features.

I'm always happy to discuss adding new functionality to libseccomp;
feel free to use the GH issue tracker or the libseccomp mailing list.

> Can you explain the exfiltration piece? Do you mean it would be
> "cheap" in the sense that the results can be stored and studied
> without needing a ptrace manager to catch the failures?

I'm a little confused about this piece too.

> I remain unconvinced that seccomp needs a more descriptive language,
> given its limited usage.

FWIW, I haven't yet seen a functionality request for libseccomp that
couldn't be addressed with cBPF and some creativity.

>> A really naive approach is to take the JSON seccomp policy document
>> and converting it to plain old C with switch / case statements. Then
>> we can just push that through LLVM and we're in business. Although,
>> for some reason, I don't think the folks will want to take a hard dep
>> on llvm at runtime, so maybe there's some mechanism where it first
>> tries llvm, then tries to create a eBPF application naively, and then
>> falls back to cBPF. My primary fear with the first two approaches is
>> that given how the policies are written today, it's not conducive to
>> the eBPF instruction limit.
>
> How about having libseccomp grow a JSON parser?

Generally my opinion is that seccomp filter configuration file formats
are best left to the calling application, not libseccomp.  This way
the seccomp filter configuration can be consistent with the rest of
the application's configuration.

However, if someone really wants to work on this, I'm not sure I would say "no".

>>>> 2) In my testing, which thus so far has been very rudimentary, with
>>>> rewriting the policy that libseccomp generates from the Docker policy
>>>> to use eBPF, and eBPF maps performs much better than cBPF. The
>>>> specific case tested was to use a bpf array to lookup rules for a
>>>> particular syscall. In a super trivial test, this was about 5% low
>>>> latency than using traditional branches. If you need more evidence of
>>>> this, I can work a little bit more on the maps related patches, and
>>>> see if I can get some more benchmarking. From my understanding, we
>>>> would need to add "sealing" support for maps, in which they can be
>>>> marked as read-only, and only at that point should an eBPF seccomp
>>>> program be able to read from them.
>
> This came up recently on the libseccomp mailing list. The map lookup
> is faster than a linear search, but for large filters, the filter can
> be written as a balanced tree (as Chrome does), or reordered by
> syscall frequency (as is recommended by minijail), and that appears to
> get a much larger improvement than even the map lookup.

For reference, the current libseccomp approach is to put the shorter
rules near the top of the filter (e.g. syscall only) with the longer
rules (e.g. syscall + arguments) towards the end.  The libseccomp API
does allow for callers to influence the ordering via syscall priority
hints.

Someone is currently looking a tree-based ordering of syscalls for
libseccomp, and I'm always open to new/better ideas.

-- 
paul moore
security @ redhat
