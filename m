From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: How to start contributing to namespaces in the kernel.
Date: Tue, 30 Dec 2014 00:08:52 -0600
Message-ID: <87lhlpy8i3.fsf@x220.int.ebiederm.org>
References: <CAFx0iW_oZn=esL63swjJyChsuORMfmzcgRBLYFrKR0VVtM8Tcw@mail.gmail.com>
	<87k31a2m6o.fsf@x220.int.ebiederm.org>
	<CAFx0iW9EEAy1VDqpVmAygZgXBMAvQR4jjDMjSKx-YYx5dAeGDg@mail.gmail.com>
	<87r3vi0ws0.fsf@x220.int.ebiederm.org>
	<CAA2m6vczmqJ3uBEL_5nGa04vb2dw43yM5HbzszruXPtFhDsDJw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CAA2m6vczmqJ3uBEL_5nGa04vb2dw43yM5HbzszruXPtFhDsDJw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	(Amir Goldstein's message of "Tue, 30 Dec 2014 05:23:04 +0200")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Amir Goldstein <amir-3AfRa/s5aFdBDgjK7y7TUQ@public.gmane.org>
Cc: Timothy Chen <tnachen-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Amir Goldstein <amir-3AfRa/s5aFdBDgjK7y7TUQ@public.gmane.org> writes:

> On Tue, Dec 30, 2014 at 3:08 AM, Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> wrote:
>
>> Timothy Chen <tnachen-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:
>>
>> > Thanks Eric for the detailed reply!
>> >
>> > I want to gain more understanding and context around namespaces in the
>> > kernel, and thought contributing is the best way to do so.
>>
>> It can't hurt.
>>
>> > I wonder if there is a public backlog that lists open issues that you
>> > mentioned or haven't get to work on yet?
>>
>> Nothing more than I have posted.  That isn't how I work, and it isn't
>> how folks in the kernel tend to work.
>>
>
> Setting up a wiki page could make for a good first contribution ;-)

Only if the person who sets up the wiki can see why the wiki would be a
good idea and has a vision of how it would help, and where the wiki
needs to go.

One of the largest challenges with kernel namespace patches from new
contributors is many of them are poorly thought out.  Sometimes the
original author isn't even certain what problem they are really trying
to solve.  That tends to suck up the time and tax the patience of kernel
maintainers who tend towards being over-worked as it is.

As such I am very reluctant to encourage people with baby steps.  If
folks can figure out how to jump in and deal with everything they that
needs to be dealt with that would be a tremendous help.  If too much
hand holding is necessary it becomes a drag because there are only so
many hands to go around.

>> Start with assuming there aren't bugs in the kernel implementation.
>> The certainly are no known bugs that someone who is not familiar with
>> the kernel is likely to be able to fix.
>>
>> So find something you would like to do with a container, and figure out
>> why you can't, and then send a patch or ask a question about how to make
>> it work.
>>
>
> Sharing from my personal experience, I learned about Google summer of code
> in 2011 and found the program to be very helpful in matching itches to
> scratch with potential open source contributors.
>
> The Linux Foundation has been a participating organization in the
> program in recent years as well as several of the Linux distros.  With
> the rising interest in containers, open source projects looking for
> new blood should consider applying to the program and propose
> containers related projects.
>
> As a mentor, it was very rewarding for me to help a new kernel developer
> join the community.

I don't know that I have the time and am willing to be a mentor.  I am
willing to describe what is going on and what it takes to contribute.

With namespaces most of the low hanging fruit has been picked long ago.
It is only when someone comes in with a different perspective or a
different use case that occassionally new low hanging fruit will be
spotted.  I can't supply that different perspective or that different
use case, at best I can encourage people to look at what they are doing,
look at what the kernel and ask people to find that use case themselves.

Eric
