From: chris hyser <chris.hyser-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: Re: [net-next v3 0/2] eBPF seccomp filters
Date: Tue, 27 Feb 2018 11:59:48 -0500
Message-ID: <ddbefdda-f3b8-3956-fa0f-dcba8cf8e7d9@oracle.com>
References: <20180226072651.GA27045@ircssh-2.c.rugged-nimbus-611.internal>
	<20180226230418.46nczgkh5csakyu7@ast-mbp>
	<CAGXu5jLdOcrn16q9pQ7JwTf88AVsL0o5LMJ=4P6vRN36u-_k_g@mail.gmail.com>
	<CALCETrXNODxWkcwF-LbXBn+Ju7QJEyi3JR+spsRX4ecg8d1iMQ@mail.gmail.com>
	<CAGXu5j+64WzxjBnpQxYCU50ak+VqVw1y0W+MWygFodxsDqEZRw@mail.gmail.com>
	<db759dd2-31dc-d094-251d-d4c1e8af8704@oracle.com>
	<CAGXu5j+idW9AjZHVdeedqLOFXriObUJLvcw8-9k5WxyQF8EWrg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CAGXu5j+idW9AjZHVdeedqLOFXriObUJLvcw8-9k5WxyQF8EWrg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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

On 02/27/2018 11:00 AM, Kees Cook wrote:
> On Tue, Feb 27, 2018 at 6:53 AM, chris hyser <chris.hyser-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org> wrote:
>> On 02/26/2018 11:38 PM, Kees Cook wrote:
>>>
>>> On Mon, Feb 26, 2018 at 8:19 PM, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
>>> wrote:
>>>>
>>>> 3. Straight-up bugs.  Those are exactly as problematic as verifier
>>>> bugs in any other unprivileged eBPF program type, right?  I don't see
>>>> why seccomp is special here.
>>>
>>>
>>> My concern is more about unintended design mistakes or other feature
>>> creep with side-effects, especially when it comes to privileges and
>>> synchronization. Getting no-new-privs done correctly, for example,
>>> took some careful thought and discussion, and I'm shy from how painful
>>> TSYNC was on the process locking side, and eBPF has had some rather
>>> ugly flaws in the past (and recently: it was nice to be able to say
>>> for Spectre that seccomp filters couldn't be constructed to make
>>> attacks but eBPF could). Adding the complexity needs to be worth the
>>> gain. I'm on board for doing it, I just want to be careful. :)
>>
>>
>>
>> Another option might be to remove c/eBPF from the equation all together.
>> c/eBPF allows flexibility and that almost always comes at the cost of
>> additional security risk. Seccomp is for enhanced security yes? How about a
>> new seccomp mode that passes in something like a bit vector or hashmap for
>> "simple" white/black list checks validated by kernel code, versus user
>> provided interpreted code? Of course this removes a fair number of things
>> you can currently do or would be able to do with eBPF. Of course, restated
>> from a security point of view, this removes a fair number of things an
>> _attacker_ can do. Presumably the performance improvement would also be
>> significant.
>>
>> Is this an idea worth prototyping?
> 
> That was the original prototype for seccomp-filter. :) The discussion
> around that from years ago basically boiled down to it being
> inflexible. Given all the things people want to do at syscall time,
> that continues to be true. So true, in fact, that here we are now,
> trying to move to eBPF from cBPF. ;)

I will try to find that discussion. As someone pointed out here though, eBPF is being used by more and more people in 
areas where security is not the primary concern. Differing objectives will make this a long term continuing issue. We 
ourselves were looking at eBPF simply as a means to use a hashmap for a white/blacklist, i.e. performance not flexibility.

-chrish
