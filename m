From: Mathieu Peresse <mathieu.peresse-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: VRF-like use of Network Namespaces
Date: Tue, 8 Jun 2010 19:12:47 +0200
Message-ID: <AANLkTik77W7F7BV7qp9ZQlM3yJCKNydHAMN47FaLTr7Z@mail.gmail.com>
References: <AANLkTimA_0aZwZM1uZ-GH3OxfEZvegoitaaKTYPLvW5F@mail.gmail.com>
	<4C0E6466.3030100@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4C0E6466.3030100-GANU6spQydw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Looks good, thanks ! Has anyone worked to make 'ip' use these facilities ?

If I understand correctly, from a network resource configuration
perspective:

- Creating a persisting namespace ('VRF') is equivalent to: create a
namespace (using clone()),  which creates a proc entry for that namespace,
and then bind mount the file so that it stays open.
- Modifying network resource configuration for a particular namespace
('VRF') is equivalent to: use setns() with the fd matching the previously
open namespace's proc file and then call network resource setting function
(e.g. netlink API)

Maybe I'm a bit confused, that's my first day in container land ... :)

Thanks,

mathieu.

On Tue, Jun 8, 2010 at 5:40 PM, Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>wrote:

> On 06/08/2010 05:23 PM, Mathieu Peresse wrote:
>
>> Hi all,
>>
>> I saw this post from Oct 2008:
>>
>> https://lists.linux-foundation.org/pipermail/containers/2008-October/013917.html
>> ,
>> discussing how to manipulate network namespaces like we do with VRFs
>> on
>> Cisco routers (e.g. using normal network commands, plus appending "vrf
>> vrf_name" at the end to manipulate the desired VRF), without the need to
>> have processes "bound" to network namespaces.
>>
>> Are there any activities on this subject ?
>>
>>
>
> There is a prototype here:
>
> git://
> git.kernel.org/pub/scm/linux/kernel/git/ebiederm/linux-2.6.33-nsfd-v5.git
>
> The description of what it does:
>
>
> http://git.kernel.org/?p=linux/kernel/git/ebiederm/linux-2.6.33-nsfd-v5.git;a=commit;h=9c2f86a44d9ca93e78fd8e81a4e2a8c2a4cdb054
>
> I don't know what is the status of this patchset and if Eric is willing to
> push it for the next kernel version.
>
> Thanks
>  -- Daniel
>



-- 
a+
mathieu
