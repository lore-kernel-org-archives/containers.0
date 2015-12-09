From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: piping core dump to a program escapes container
Date: Wed, 09 Dec 2015 00:32:51 -0600
Message-ID: <87oae0dtd8.fsf__27155.3563922227$1449643326$gmane$org@x220.int.ebiederm.org>
References: <CABAubTgj8+xngrvc7sNbYS_Hq+-rGAYCz0y433ByiZ45dZuT0w@mail.gmail.com>
	<56679161.303@cn.fujitsu.com> <56679399.6080306@cn.fujitsu.com>
	<876108fgfq.fsf@x220.int.ebiederm.org>
	<5667C1BC.7070204@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <5667C1BC.7070204-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> (Dongsheng Yang's message of
	"Wed, 9 Dec 2015 13:53:00 +0800")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dongsheng Yang <yangds.fnst-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Shayan Pooya <shayan-UQzSddOuLosdnm+yROfE0A@public.gmane.org>, Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>
List-Id: containers.vger.kernel.org

Dongsheng Yang <yangds.fnst-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> writes:

> On 12/09/2015 11:29 AM, Eric W. Biederman wrote:
>> Dongsheng Yang <yangds.fnst-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> writes:
>>
> [...]
>
>> There has not yet been an obvious namespace in which to stick
>> core_pattern, and even worse exactly how to appropriate launch a process
>> in a container has not been figured out.
>>
>> If those tricky problems can be solved we can have a core_pattern in a
>> container.  What we have now is the best we have been able to figure out
>> so far.
>
> Thanx Eric, but if I want to make docker works rely on this behaviour,
> is that reliable?
>
> I mean, I want to make a docker container to dump the
> core file to a specified path in host by a pipe way. But I am afraid
> this behaviour would be changed later. Any suggestion?

The kernel rules say if there is a behavior someone depends on and that
behavior changes and breaks userspace that is a regression and it is not
allowed.

As developers we try not to create regressions.  But some days it
requires someone testing/using the functional enough to catdch an issue.

That said the real issue you are likely to run into when developing this
as part of docker is that docker doesn't get to own the core pattern.
It doesn't make sense for any one application to, as it is a kernel wide
setting.  To have different app or container specific policies for core
dumping likely requires either solving the problems I mentioned with
containers or in userspace a solution so there can be an
/etc/core_pattern.d/ with different configuration and different scripts
that somehow know how to select which core files they want and dump them
sanely.

Eric
