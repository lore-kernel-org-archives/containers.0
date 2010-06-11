From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: Re: VRF-like use of Network Namespaces
Date: Fri, 11 Jun 2010 17:52:04 +0200
Message-ID: <4C125BA4.4020300@free.fr>
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

On 06/11/2010 04:47 PM, Mathieu Peresse wrote:
> Hi,
>
> [this is related to the use of Eric Biederman's new set of patches for named
> netns / netns switching]
>
> ok so I successfully modified /sbin/ip. I can now:
> - add/del a new netns by name: "ip netns {addns,delns} ns_name"
> ->  The namespace files are mounted on /var/run/netns/ns_name (so you have to
> mkdir /var/run/netns/ for this to work).
>    

IMHO, the ip command is not suitable for this, it does not write 
anything to the fs.
You should write you own command, which can be a perl script using the 
'unshare' command (util-linux package on my distro).

vrf create <name>
vrf delete <name>
vrf attach <name>
vrf list

vrf create will bind mount the ns at the place you decided in the script 
(eg. a tmpfs in order to keep the directory consistent across (unclean) 
reboots).

> - list netns: "ip netns show"
> - use /sbin/ip in any named netns: "ip -netns ns_name link show"
>
> (rough patch against current git tree attached)
>
> I want now to move devices across namespaces using their filesystem names
> (instead of using PIDs...). I'm not sure I can do it in userspace with the
> current code yet, can I ?
>    
No, you can do that only with pids, but why don't you move the devices 
at the create time ?
You have all the latitude to do that, no ?

> I saw there was a rtnetlink attribute to set the netns of a device but it
> uses the PID of a namespace owner to do so... within 'ip' i can refer to
> only one namespace (i.e. the one that 'ip' task_struct->ns_proxy currently
> points to), so I won't be able to move an interface from outside my
> namespace to my namespace...
> I hope my explanation is clear and that this will get some interest... :)
>    

Your 'create' command can open a fd to its current  netns, unshare a new 
namespace, bind mount it, and then return to the previously saved netns.

> BTW is this the right ML to post this on ?
>    

Well, this is something related to a subsystem of the containers, so it 
has some interest but I would suggest to send to the netdev@ mailing 
list (netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org), maybe cc'ing this mailing list.
