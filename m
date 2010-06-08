From: Mathieu Peresse <mathieu.peresse-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: VRF-like use of Network Namespaces
Date: Tue, 8 Jun 2010 23:48:02 +0200
Message-ID: <AANLkTinmsRRKdWaf8QONeRRJSQRXPhaUtY1cFv_JGcy8@mail.gmail.com>
References: <AANLkTimA_0aZwZM1uZ-GH3OxfEZvegoitaaKTYPLvW5F@mail.gmail.com>
	<4C0E6466.3030100@free.fr>
	<AANLkTik77W7F7BV7qp9ZQlM3yJCKNydHAMN47FaLTr7Z@mail.gmail.com>
	<4C0EB0C5.8070904@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4C0EB0C5.8070904-GANU6spQydw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

I want to be able to type say: "ip vrf add vrf_name" to create a persisting
network namespace, and then be able to add a net device to this namespace
"ip link add dev tun0 vrf vrf_name" and then add a route to a subnet in this
namespace using e.g. "ip route add 192.168.1.0/24 dev tun0 vrf vrf_name"

I believe i can patch iproute2 (providing the 'ip' config utility) to use
setns() and unshare() to add new namespaces and configure interfaces and
routing in namespace ?

I will look more into it tomorrow :)

Thanks a lot for this awesome work anyways !

mathieu.

On Tue, Jun 8, 2010 at 11:06 PM, Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>wrote:

> On 06/08/2010 07:12 PM, Mathieu Peresse wrote:
>
>> Looks good, thanks ! Has anyone worked to make 'ip' use these facilities ?
>>
>> If I understand correctly, from a network resource configuration
>> perspective:
>>
>> - Creating a persisting namespace ('VRF') is equivalent to: create a
>> namespace (using clone()),  which creates a proc entry for that namespace,
>> and then bind mount the file so that it stays open.
>>
>>
>
> From the same process, unshare (using unshare()), open /proc/self/ns/net,
> store the fd, unshare again, open /proc/self/ns/net, store the fd, ...
> A single process handles by this way several network namespaces.
>
> To switch from one namespace to another, just use the setns syscall.
>
> Well this is one example to use it, AFAIK you are looking for this very
> specific usage no ?
>
> Thanks
>  -- Daniel
>
>
>


-- 
a+
mathieu
