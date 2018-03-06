From: Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>
Subject: Re: Userspace helper design
Date: Tue, 6 Mar 2018 13:14:30 -0800
Message-ID: <CAMp4zn8fdMYOpemqaQ_7+KAMmnVtHzi-wz_RqG_HJh15b81SDg@mail.gmail.com>
References: <20180306013448.GA6631@ircssh-2.c.rugged-nimbus-611.internal>
	<20180306014542.me6xtmyhhkystywz@ast-mbp>
	<CAMp4zn_c51SC5gvsk=pzTD7UCsid1DCyPhe-ScohZzrpyObu7g@mail.gmail.com>
	<20180306015351.5swdihfrisxb7226@ast-mbp>
	<307b9945-57d0-1178-32af-3837aaefae90@iogearbox.net>
	<CAMp4zn-Ga08OFF34BiQ+YqcnmKYrAbNgRKbK9UkG5TfVrjLqTw@mail.gmail.com>
	<fc4e2ea0-5bdc-a0be-c500-f55e7de8e1bd@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <fc4e2ea0-5bdc-a0be-c500-f55e7de8e1bd-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Cc: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Mar 6, 2018 at 12:31 PM, Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org> wrote:
> On 03/06/2018 05:02 PM, Sargun Dhillon wrote:
>> On Tue, Mar 6, 2018 at 3:26 AM, Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org> wrote:
>>> On 03/06/2018 02:53 AM, Alexei Starovoitov wrote:
>>>> On Mon, Mar 05, 2018 at 05:46:51PM -0800, Sargun Dhillon wrote:
>>>>> On Mon, Mar 5, 2018 at 5:45 PM, Alexei Starovoitov
>>>>> <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>>>>>> On Tue, Mar 06, 2018 at 01:34:51AM +0000, Sargun Dhillon wrote:
>>>>>>>
>>>>>>> I want to get y'all's thoughts.
>>>>>>>
>>>>>>> In seccomp, we need a mechanism to delegate some functionality to
>>>>>>> userspace programs. Ideally, we build this mechanism in a generic
>>>>>>> way to notify userspace "monitors" from a BPF program.
>>>>>>
>>>>>> why perf_event_output helper is not enough?
>>>>>> It seems it can already do everything as you described.
>>>
>>> perf RB would just be unidirectional, though. :-/
>>>
>>>>> Because Tycho wants it to be synchronous. The BPF program can't
>>>>> wait on the response from userspace with perf_event_output.
>>>>
>>>> bpf in kernel execution will never wait on user space process.
>>>
>>> Potentially, such daemon could be hooked into kernel via the module
>>> loader approach, I think that might be interesting. Given this would
>>> sleep, it would probably need to be a verdict that then does the
>>> push into user space waiting for the result. Other approach could be
>>> via helper and you'd have a per-cpu refcount that makes sure the
>>> BPF prog (or better the seccomp struct holding it) doesn't evict
>>> during that time when you drop / reacquire RCU read lock from within
>>> the helper.
>> How do you deal with map values and such? Those can also be released
>> if we give up rcu read lock.
>
> Agree, that would be a problem. Any such access would need to be
> invalidated by the verifier.
>
>> I think a terminal "helper" would be better. The problem I see with a
>> terminal helper is how do you deal with errors?
>
> E.g. in XDP, we have a return verdict XDP_ABORTED. Potentially you
> could also have an 'exception' return verdict for seccomp that would
> eventually be the same as behavior as SECCOMP_RET_KILL, but would
> still allow for some sort of introspection such that it can be detected
> that the daemon triggered such error. Whether tracepoint might be the
> appropriate choice as well in that case ... probably not though.

So, would this verifier just ensure that no maps are accessed prior to
the helper being called, XOR ensure that after the helper is called,
no map values are accessed?
