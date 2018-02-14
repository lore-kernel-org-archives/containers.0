From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: [PATCH net-next 0/3] eBPF Seccomp filters
Date: Wed, 14 Feb 2018 17:25:00 +0000
Message-ID: <CALCETrV9xUd3XRgobTDgVNRFY_+o=pEDkfjvuxQ7w_UyH324zA__37076.9209381708$1518629046$gmane$org@mail.gmail.com>
References: <20180213154244.GA3292@ircssh-2.c.rugged-nimbus-611.internal>
	<CAGXu5jLiYh0rSRuJ_-2xLB03Wod5G07njpoESR4SnmsmiUnsEw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CAGXu5jLiYh0rSRuJ_-2xLB03Wod5G07njpoESR4SnmsmiUnsEw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
Cc: Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>, Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Feb 13, 2018 at 3:47 PM, Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org> wrote:
> On Tue, Feb 13, 2018 at 7:42 AM, Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org> wrote:
>> This patchset enables seccomp filters to be written in eBPF. Although,
>> this patchset doesn't introduce much of the functionality enabled by
>> eBPF, it lays the ground work for it.
>>
>> It also introduces the capability to dump eBPF filters via the PTRACE
>> API in order to make it so that CHECKPOINT_RESTORE will be satisifed.
>> In the attached samples, there's an example of this. One can then use
>> BPF_OBJ_GET_INFO_BY_FD in order to get the actual code of the program,
>> and use that at reload time.
>>
>> The primary reason for not adding maps support in this patchset is
>> to avoid introducing new complexities around PR_SET_NO_NEW_PRIVS.
>> If we have a map that the BPF program can read, it can potentially
>> "change" privileges after running. It seems like doing writes only
>> is safe, because it can be pure, and side effect free, and therefore
>> not negatively effect PR_SET_NO_NEW_PRIVS. Nonetheless, if we come
>> to an agreement, this can be in a follow-up patchset.
>
> What's the reason for adding eBPF support? seccomp shouldn't need it,
> and it only makes the code more complex. I'd rather stick with cBPF
> until we have an overwhelmingly good reason to use eBPF as a "native"
> seccomp filter language.
>

I can think of two fairly strong use cases for eBPF's ability to call
functions: logging and Tycho's user notifier thing.  They let seccomp
filters *do* something synchronously, which is a better match for both
use cases than the current approach of "hey, I'd like to log this
syscall, but it's really awkward to attach other information or to
track exactly *which* filter logged what or to stack any of it".

Also, eBPF's stronger arithmetic support would allow bitops (I think),
which would make "is the nr in this list" quite a bit faster in some
cases.
