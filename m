From: "Paul Menage" <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [Question] power management related with cgroup based resource
	management
Date: Sat, 25 Oct 2008 08:43:53 -0700
Message-ID: <6599ad830810250843u10f65917x3388276211e90316__41510.4268155575$1224949573$gmane$org@mail.gmail.com>
References: <2891419e0810201954q57087fc8ufcaa0e42f3ca99e2@mail.gmail.com>
	<4901B5C2.9070108@linux.vnet.ibm.com>
	<2891419e0810240524u746b731cjcbd127fa4204bd4d@mail.gmail.com>
	<20081024232503.GA20140@srcf.ucam.org>
	<2891419e0810250105j3e210df0pa3ba9665bd35313a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <2891419e0810250105j3e210df0pa3ba9665bd35313a-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dong-Jae Kang <baramsori72-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: corsetproject-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org, xen-devel-GuqFBffKawuULHF6PoxzQEEOCMrvLtNR@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Matthew Garrett <mjg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

On Sat, Oct 25, 2008 at 1:05 AM, Dong-Jae Kang <baramsori72-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> Thank you for your positive opinion about my question
>
> I also hope cgroup framework has good point related with power management
> I think I need more re-consideration for it. ^^
>
> How do you think about cgroup based management of new HW devices, for
> example, SSD, NVRAM and so on.
> Is there any requirement for it ?
> and is there any required work for it?
> I didn't seriously consider  about that until now.^^ so I don't have cool idea
> but, I think it is worthy to find new domain to be applied by existing
> technology

Control Groups is just a framework for associating state with
(user-created) groups of processes. So if you have a problem to solve
that involves tracking state for different processes, or applying
different behaviour to groups of processes based on that group's
state, then cgroups may well be an appropriate tool.

In the case you mention (management of new devices) that's already
somewhat covered by the existing device isolation subsystem - you can
create a cgroup that has (or doesn't have) access to particular HW
devices.

Paul
