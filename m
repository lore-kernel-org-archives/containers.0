From: Jeremias Blendin <jeremias-ZqkW+k4+4H9AfugRpC6u6w@public.gmane.org>
Subject: Re: Get statistics from all network interfaces on a system, including
	those inside network namespaces
Date: Sat, 21 Mar 2015 19:45:40 +0100
Message-ID: <CAFZrTr5u832ZXuEba-VNYjpo66gC47rZi7CRz=cymXmw+g58og__5984.78914839706$1426963564$gmane$org@mail.gmail.com>
References: <CAFZrTr52ksuMaJKbNGmQ3NuNLjRe8T15gaDvxuJ66errGN7g3g@mail.gmail.com>
	<87bnjnctw8.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87bnjnctw8.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
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
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Thank you for the detailed answer!

See also my comments below:

2015-03-20 21:10 GMT+01:00 Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>:
> Jeremias Blendin <jeremias-ZqkW+k4+4H9AfugRpC6u6w@public.gmane.org> writes:
>
>> Hi,
>>
>> I hope this is the right list to post this question.
>
> This list and netdev are the right lists.  It is one of those
> overlapping topics.
>
> Right now I find applications dealing with multiple network namespaces
> interesting as the APIs are a little rough and it is time to knock off
> some of the rough edges.
>
>> Currently, we are using a patched version of bwm-ng to poll statistics
>> of network interfaces. Some of these interfaces are located inside
>> network namespaces, unfortunately we have found no way to poll all
>> interfaces from all netspaces at once, without making our client
>> application process traverse through all the available network
>> namespaces (one result is this patch for bwm-ng:
>> https://github.com/jgjl/bwm-ng/tree/lxns).
>> Is there a more efficient way (for example by using netlink directly)
>> to get a complete list of the statistics of all network interfaces
>> existing in the kernel e.g. tagged by their netns?
>
> Not at this point.  Although we have ids that are now possible of that
> tagging.  At this point you need to have a separate socket for each
> network namespace.
ok
>
> All network devices in all network namespaces is not going to ever
> happen as that makes nested containers and migration impossible.  All
> network devices in an interesting subset of network namespaces is a very
> reasonable request.
That would indeed be very helpful. I (and numerous other people) use
the Mininet network emulator (mininet.org) for research purposes. In
this context a centralized and efficient way to poll at least a subset
of namespaces would be very helpful.
>
>> Any pointers are appreciated :)
>
> I would look at iproute2.  Looking at the description of your code you
Yes, we are currently investigating the use of pyroute2, which is a
iproute implementation in Python.
> don't even pick up on the names that have been assigned to network
> namespaces.  So I don't think you are up to speed on everything that is
> going on there.
In this specific context of Mininet all required information is
already in the network interface name, so there is no need to get the
namespace name. Nonetheless I would like to get more up to speed, the
question is what is the best way to do so? There seems to be a lot of
information on network namespaces scattered in the man pages, the
Linux kernel documentation files and lwn. Is there a better place to
stay updated on this topic?

Jeremias
>
> Eric
