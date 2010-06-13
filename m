From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: VRF-like use of Network Namespaces
Date: Sun, 13 Jun 2010 02:43:49 -0700
Message-ID: <m1ljajl12i.fsf@fess.ebiederm.org>
References: <AANLkTimA_0aZwZM1uZ-GH3OxfEZvegoitaaKTYPLvW5F@mail.gmail.com>
	<4C0E6466.3030100@free.fr>
	<AANLkTik77W7F7BV7qp9ZQlM3yJCKNydHAMN47FaLTr7Z@mail.gmail.com>
	<4C0EB0C5.8070904@free.fr>
	<AANLkTinmsRRKdWaf8QONeRRJSQRXPhaUtY1cFv_JGcy8@mail.gmail.com>
	<AANLkTilUNrMAeeUjHsXkTwd7Ysx0o9mdl8UaSUvG6wvf@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <AANLkTilUNrMAeeUjHsXkTwd7Ysx0o9mdl8UaSUvG6wvf-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	(Mathieu Peresse's message of "Fri\,
	11 Jun 2010 16\:47\:00 +0200")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Mathieu Peresse <mathieu.peresse-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Mathieu Peresse <mathieu.peresse-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:

> Hi,
>
> [this is related to the use of Eric Biederman's new set of patches for named
> netns / netns switching]
>
> ok so I successfully modified /sbin/ip. I can now:
> - add/del a new netns by name: "ip netns {addns,delns} ns_name"
> -> The namespace files are mounted on /var/run/netns/ns_name (so you have to
> mkdir /var/run/netns/ for this to work).
> - list netns: "ip netns show"
> - use /sbin/ip in any named netns: "ip -netns ns_name link show"
>
> (rough patch against current git tree attached)
>
> I want now to move devices across namespaces using their filesystem names
> (instead of using PIDs...). I'm not sure I can do it in userspace with the
> current code yet, can I ?
> I saw there was a rtnetlink attribute to set the netns of a device but it
> uses the PID of a namespace owner to do so... within 'ip' i can refer to
> only one namespace (i.e. the one that 'ip' task_struct->ns_proxy currently
> points to), so I won't be able to move an interface from outside my
> namespace to my namespace...
> I hope my explanation is clear and that this will get some interest... :)

In my nsfd tree if you look there is a new IFLA_NET_NS_FD attribute so should
be able to update the existing code in ip that takes a netns by pid, and do
a name based search first, and if you don't find the name and the value is
numeric do a search by ip.

> BTW is this the right ML to post this on ?

For hashing out the idea this is fine.  Ultimately this conversation needs
to hit netdev, before we merge all of this.

That rough patch looks particularly promising.

Eric
