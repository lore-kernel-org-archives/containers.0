From: "Michael Kerrisk (man-pages)" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: For review: user_namespace(7) man page
Date: Sat, 13 Sep 2014 19:42:24 -0700
Message-ID: <54150090.1050306__13948.7292887226$1410662566$gmane$org@gmail.com>
References: <53F5310A.5080503@gmail.com>
	<CALCETrX2qwvzmeoVcLFLxEK=1Fv+f0Ri0TouzzvbN_rgDjka4A@mail.gmail.com>
	<540F0810.7030408@gmail.com> <87ppf4n5ib.fsf@x220.int.ebiederm.org>
	<5411B5D6.9010201@gmail.com>
	<CALCETrV1EtrzfEhS55ToPD5VTbY9VjmmOA6bv2H9PGGQ-G=WGA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CALCETrV1EtrzfEhS55ToPD5VTbY9VjmmOA6bv2H9PGGQ-G=WGA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Cc: "linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, richard -rw- weinberger <richard.weinberger-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

On 09/11/2014 08:14 AM, Andy Lutomirski wrote:
> On Thu, Sep 11, 2014 at 7:46 AM, Michael Kerrisk (man-pages)
> <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>> Hi Eric,
>>
>> On 09/09/2014 09:05 AM, Eric W. Biederman wrote:
>>> "Michael Kerrisk (man-pages)" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:
>>>
>>>> Hi Andy, and Eric,
>>>>>>        1. The  writing  process  must  have  the CAP_SETUID (CAP_SETGID)
>>>>>>           capability in the user namespace of the process pid.
>>>>>
>>>>> This checked for the opening process (and I don't actually remember
>>>>> whether it's checked for the writing process).
>>>>
>>>> Eric, can you comment?
>>>
>>> We have to check for the opening processes and that changes was made
>>> after I implemented my interface. Pieces of the code appear to also
>>> examine the writing process and verify everything applies to it as well.
>>>
>>> I goofed when I designed the interface originall and had not realized
>>> what a classic design error it can be to not restrict by the opening
>>> process.
>>
>> So, I still need some help here. Should the sentence above just read:
>>
>>         1. The  *opening*  process  must  have  the CAP_SETUID (CAP_SETGID)
>>            capability in the user namespace of the process pid.
> 
> I think this is sufficient.
> 
>>
>> or must something also be said about the writing process? (If so, i'd
>> appreciate a completely formed sentence or two that I can just drop into
>> the man page..)
> 
> There might be a restriction there, too, but I think it could be
> removed, and I also think that it's unlikely that anyone will
> encounter it.

Okay. Thanks, Andy.

Cheers,

Michael


-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/
