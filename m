From: Timothy Chen <tnachen-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: How to start contributing to namespaces in the kernel.
Date: Mon, 29 Dec 2014 13:31:17 -0800
Message-ID: <CAFx0iW9EEAy1VDqpVmAygZgXBMAvQR4jjDMjSKx-YYx5dAeGDg@mail.gmail.com>
References: <CAFx0iW_oZn=esL63swjJyChsuORMfmzcgRBLYFrKR0VVtM8Tcw@mail.gmail.com>
	<87k31a2m6o.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87k31a2m6o.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Thanks Eric for the detailed reply!

I want to gain more understanding and context around namespaces in the
kernel, and thought contributing is the best way to do so.

I wonder if there is a public backlog that lists open issues that you
mentioned or haven't get to work on yet?

Thanks!

Tim

On Mon, Dec 29, 2014 at 1:14 PM, Eric W. Biederman
<ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
>
> I was just asked how to start contributing to namespaces in the kernel
> and my reply is generic to anyone so I am making it public in the hopes
> it is of use to more people.
>
> Timothy Chen <tnachen-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:
>
>> Hi Eric,
>>
>> My name is Timothy Chen and I work a lot on Mesos/Docker/Rocket that
>> all utilizes namespaces.
>>
>> I'm looking to contribute to Namespaces in the Kernel and besides
>> knowing where the code is I don't actually have much idea what the
>> process is like and what issues I can start looking at.
>>
>> I see you're the main person working with Namespaces so I wonder if
>> you can point me to where I can start learning how the patch process
>> work for namespaces, and what issues/bugs I can look at to start off
>> with?
>
> You will want to follow the containers mailling list:
> http://lists.linuxfoundation.org/mailman/listinfo/containers
>
> The standard reference for the kernel process is:
> https://www.kernel.org/doc/Documentation/SubmittingPatches
> (also found in the kernel git repo under Documentation).
>
> Priorities are set by enlightend self interest.  Aka you see a problem
> that you understand, and care about and you submit a patch.
>
> In most cases this involves working with the upstream maintainer of
> whatever subsystem the namespaces is for.   Aka all networking patches
> go through David Miller.  I tend to review namespace specific issues so
> I would appreciate a Cc.
>
> There are some outstanding issues and outstanding patches that I am a
> little behind on, as I was away from the kernel for quite a few months
> on a job hunt earlier this year.  Hopefully in the next couple of weeks
> I will finish getting that backlog cleared up.
>
> Developing namespace code is simultaneously simple and very difficult.
> On a good day a namespace is just an extra layer of indirection where
> you have to look up a name.  On a bad day the entire subsystem has to be
> rewritten so that extra layer of indirection can be supported in a clean
> way without hacks.  The general case always has to be solved for
> namespace patches to be interesting in upstream, and with a kernel that
> is going on 23 years old that can be a lot of cases to consider in some
> cases.
>
> From my perspective namespaces are essentially complete.  There are a
> few little things around the edges (as there always will be) that need
> work, but there are core seems pretty solid.  The things I am aware of
> right now are:
> - netlink passable ids for network namespaces
> - unprivileged mounts of filesystems (with the user namespace)
> - cgroup namespaces (aka getting cgroups and containers to play nice).
> - unprivileged cgroups (aka making chmod on a cgroup file not exploitable).
> - nested networking or making it reasonably easy to support containers
>   in a data center, and easy to support multiple containers on one
>   machine.
> - devices in containers - Usually this is just dealing with the fact
>   that there are no proper abstractions for a class of devices and
>   figuring out how to deal with that.
>
> My priorities are getting security issues cleared up (especially with
> user namespaces) and then getting a little feature work done so that
> more things can be done safely in user namespaces without privilege
> (especially filesystem mounting).
>
> The process for features is that when figuring out what to do and where
> to start we have conversations (generally publicly) and then write the
> code and implement.  Patches always make features ideas much more
> concrete and sometimes it can take a while.  As part of making progress
> I wound up needing to rewrite sysfs and sysctl and significant parts of
> proc, so the result would be clean and maintainable.  Conversations also
> need to be had with not just container folks but also people who
> maintain the affected subsystems.  So sometimes despite the result being
> comparatively simple easy to follow code, the road to get there can be
> long.
>
> Good luck and I hope you can find an itch in the kernel namespaces code
> you can succesfully scratch.
>
> Eric
