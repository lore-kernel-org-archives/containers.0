From: Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>
Subject: Re: [systemd-devel] How to use cgroups within containers?
Date: Mon, 20 Oct 2014 19:33:32 +0200
Message-ID: <5445476C.3020603@nod.at>
References: <CAFLxGvxzmfhLZPsmsFG9qdB0oDf9ayvNaWNNOXqcAkW3yATffg@mail.gmail.com>
	<20141020162445.GA4008@gardel-login> <54453D06.9020101@nod.at>
	<20141020165129.GA4179@gardel-login> <54453E6F.6000202@nod.at>
	<20141020170442.GA4271@gardel-login> <54454355.90605@nod.at>
	<20141020172734.GA4462@gardel-login>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20141020172734.GA4462@gardel-login>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Lennart Poettering <lennart-mdGvqq1h2p+GdvJs77BJ7Q@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "systemd-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org" <systemd-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org>, LXC development mailing-list <lxc-devel-cunTk1MwBs9qMoObBWhMNEqPaTDuhLve2LY78lusg7I@public.gmane.org>
List-Id: containers.vger.kernel.org

Am 20.10.2014 um 19:27 schrieb Lennart Poettering:
> On Mon, 20.10.14 19:16, Richard Weinberger (richard-/L3Ra7n9ekc@public.gmane.org) wrote:
> =

>>> Have you read the link I posted?
>>
>> Sure, I've also been in the room in D=FCsseldorf while you've read it
>> in front of us.
> =

> Not that I changed it since then... ;-)
> =

>>> Yes, I test systemd inside containers. Daily. Actually it's my primary
>>> way of testing systemd, since it is extremely quick and allows me to
>>> attach from the host with debugging tools...
>>>
>>> As long as you follow the suggestions in the document I linked systemd
>>> will work without modifications in container managers. At least
>>> libvirt-lxc and nspawn follows these suggestions, not sure about the
>>> other container managers.
>>
>> If I read the source of nspwan correctly, it does not use user
>> namespaces.
> =

> Ah, this is about user namespaces? No I have not played around with
> them so far. Sorry.

Yep. Please have a look at them. There are some pitfalls.

>> libvirt-lxc is currently not sure how to support systemd. So far it
>> bind mounts only the machine specific part of cgroups into the container.
>> Which is not really nice but better than exposing the whole hierarchy in=
to
>> the container.
> =

> It really should also bind mount the upper parts, but possibly mark
> them read-only (which nspawn currently doesn't do).

Okay. Or maybe cgroup namespaces will help.
Let's find out. :)

Thanks,
//richard
