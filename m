From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: Re: [lxc-devel] LXC quota support
Date: Thu, 03 Sep 2009 10:49:36 +0200
Message-ID: <4A9F8320.6090001@free.fr>
References: <ac1c4bf20909010930q5721c9bas2ea3722e94657820@mail.gmail.com>
	<4A9D68D1.5030807@free.fr>
	<d95d44a20909021953x7779a2dfpcc38e5915ae5515b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <d95d44a20909021953x7779a2dfpcc38e5915ae5515b-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: anqin <anqin.qin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, kt-S89nZTSLPHGGdvJs77BJ7Q@public.gmane.org, lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: containers.vger.kernel.org

anqin wrote:
> On Wed, Sep 2, 2009 at 2:32 AM, Daniel Lezcano<daniel.lezcano-GANU6spQydw@public.gmane.org> wrote:
>> Krzysztof Taraszka wrote:
>>> Hello,
>>>
>>> I am looking for quota support for LXC containers. For example, I would
>>> like
>>> to have two containers.  One of them may have 20GB, second 50GB.
>>> I found this one patch:
>>>
>>> https://lists.linux-foundation.org/pipermail/containers/2009-February/015807.htmland
>>> I have a question. Does there is another implemented method for have
>>> disk quota for container and his cgrop ? How about rootfs available disk
>>> space information ? If no, is there any ideas how to and when the disk
>>> quota
>>> will be implemented?
>> Anqui did a first try with this patch. The feature was positively received
>> but not in this form. I don't know what is the status of this work, but
>> maybe Anqui can give an answer :) - Cc'ed.
>>
>> Anqui ? Did you tried to implement quotas with the directory hierarchy level
>> as suggested Paul ?
>>
> 
> Yes, I am still in this work. I have attached a tag to directory
> hierarchy which
> can account the space consumption of each sub-directories and its files for
> different task groups. The way indeed can calculate the total disk consumpton
> of each group and limit its quota, however other trouble occurs when facing
> access control and security issue. I am dealing with the issue.


Excellent !

If you have a patchset, even not working nor tested or not compiled, I 
will be happy to review it.

>> Krzysztof, one solution to restrict disk usage to a container can be to
>> create an disk image of 20GB, mount it on a directory, install the rootfs on
>> it and use this directory as the rootfs for the container.
>>
> 
> This is another way to achieve same functionalities, by 'dd'ing image file
> with given quota and mounting as rootfs of task group. However, it is not
> easy to change the limited quota dynamically. This is not flexible enough
> for performance control (in green computing) and resource enforcement
> (in cloud computing).

Yep, agreed.

Thanks Anquin

   -- Daniel
