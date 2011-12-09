From: nishant mungse <nishantmungse-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [Lxc-users] How to start the network services so as to get the IP
	address using lxc-execute???
Date: Fri, 9 Dec 2011 11:03:12 +0530
Message-ID: <CAHnfO6yTvEjADomKqoqW+_jw-AVzarjjiuB7XuF5WLS_yFJLSg@mail.gmail.com>
References: <CAHnfO6xppccpXCKQgNh32qiD69Qz4BTmjKM_dm9tk8hagKUsAA@mail.gmail.com>
	<1323344375.29258.147.camel@bahia.local>
	<CAHnfO6y1PDeq0JgkwRWvAKpaLv=j2Z+ePcr=LqTu4jKOm5LKPA@mail.gmail.com>
	<4257021D-20D5-4401-9052-65B2242548F7@gmail.com>
	<CAEyk9GjyWBjJJrkS8hNAorr_tmGEzgW-AfMH3Kmz-tvGt5WcuQ@mail.gmail.com>
	<CAHnfO6yU2XKSkP_hrDUJ-msPALv4CjB=Hq973szzry3yxDvQFQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CAHnfO6yU2XKSkP_hrDUJ-msPALv4CjB=Hq973szzry3yxDvQFQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Geordy Korte <gkorte-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "lxc-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org" <lxc-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi Geordy,

You said that your script gets the IP from running container, but i dont
want to use lxc-start I just want the IP address and use lxc-execute to
start network services.


Regards,
Nishant

On Fri, Dec 9, 2011 at 11:00 AM, nishant mungse <nishantmungse-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>wrote:

> Hi,
>
>
> Thanks 4 script.
>
> Regards,
> Nishant
>
>
> On Fri, Dec 9, 2011 at 12:18 AM, Geordy Korte <gkorte-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>
>> Ok, got out of the hellish traffic jam.  Attached the Script I use to
>> check the IP number of a running machine.
>>
>>
>>
>>
>> On Thu, Dec 8, 2011 at 5:48 PM, Geordy Korte <gkorte-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>>
>>> I have a script that gets the from a running container, if that is what
>>> you need i post it tommorrow morning. If i forget ST me via the ibm network.
>>>
>>> Mvg
>>>
>>> Geordy Korte
>>> (Sent via iphone so shorter then normal)
>>>
>>>
>>> On 8 dec. 2011, at 13:59, nishant mungse <nishantmungse-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>>> wrote:
>>>
>>>
>>> Hi Greg,
>>>
>>> Thanks 4 reply.
>>>
>>> I just want the IP addresses of the containers. And one more thing can I
>>> get the IP address of containers in sequence for eg. container1 ::
>>> 198.208.168.1 container 2 :: 198.208.168.2 and like this.
>>>
>>> Please help me ASAP.
>>>
>>> Regards,
>>> Nishant
>>>
>>> On Thu, Dec 8, 2011 at 5:09 PM, Greg Kurz <gkurz-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org> wrote:
>>>
>>>> On Thu, 2011-12-08 at 16:03 +0530, nishant mungse wrote:
>>>> > Hi,
>>>> >
>>>> > I want to manually invoke a networking setup to start the network
>>>> > service to get the IP address of container , But the problem is i
>>>> > don't want to start the container and want to use lxc-execute.
>>>> >
>>>> > When I tried these things happened::
>>>> >
>>>> > command :: lxc-execute -n base
>>>> > -f /home/nishant/ubuntu.conf
>>>> /var/lib/lxc/base1/rootfs/etc/init.d/networking start
>>>>
>>>> Ok... this can't work. lxc-execute is for application containers only:
>>>> it runs lxc-init instead of standard /sbin/init. The networking script
>>>> you invoke needs upstart to be already running in the container... You
>>>> seem to have a system container here, it _MUST_ be started with
>>>> lxc-start.
>>>>
>>>> >
>>>> > O/P
>>>> >
>>>> > Rather than invoking init scripts through /etc/init.d, use the
>>>> > service(8)
>>>> > utility, e.g. service networking start
>>>> >
>>>> > Since the script you are attempting to invoke has been converted to an
>>>> > Upstart job, you may also use the start(8) utility, e.g. start
>>>> > networking
>>>> > start: Unable to connect to Upstart: Failed to connect to
>>>> > socket /com/ubuntu/upstart: Connection refused
>>>> >
>>>> >
>>>> > How to start the network services so as to get the IP addresses of
>>>> > containers?
>>>> >
>>>>
>>>> What's your true need here ? Controlling the containers network services
>>>> from the host or just knowing the addresses used by the containers ? I
>>>> guess both are doable in a variety of ways.
>>>>
>>>> Cheers.
>>>>
>>>> >
>>>> > Regards,
>>>> > Nishant
>>>> >
>>>> >
>>>> >
>>>> >
>>>> ------------------------------------------------------------------------------
>>>> > Cloud Services Checklist: Pricing and Packaging Optimization
>>>> > This white paper is intended to serve as a reference, checklist and
>>>> point of
>>>> > discussion for anyone considering optimizing the pricing and
>>>> packaging model
>>>> > of a cloud services business. Read Now!
>>>> > http://www.accelacomm.com/jaw/sfnl/114/51491232/
>>>> > _______________________________________________ Lxc-users mailing
>>>> list Lxc-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
>>>> https://lists.sourceforge.net/lists/listinfo/lxc-users
>>>>
>>>> --
>>>> Gregory Kurz                                     gkurz-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org
>>>> Software Engineer @ IBM/Meiosys                  http://www.ibm.com
>>>> Tel +33 (0)534 638 479                           Fax +33 (0)561 400 420
>>>>
>>>> "Anarchy is about taking complete responsibility for yourself."
>>>>        Alan Moore.
>>>>
>>>>
>>>
>>> ------------------------------------------------------------------------------
>>> Cloud Services Checklist: Pricing and Packaging Optimization
>>> This white paper is intended to serve as a reference, checklist and
>>> point of
>>> discussion for anyone considering optimizing the pricing and packaging
>>> model
>>> of a cloud services business. Read Now!
>>> http://www.accelacomm.com/jaw/sfnl/114/51491232/
>>>
>>> _______________________________________________
>>> Lxc-users mailing list
>>> Lxc-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
>>> https://lists.sourceforge.net/lists/listinfo/lxc-users
>>>
>>>
>>
>>
>> --
>> ==============
>> Geordy Korte
>> MSN geordy-g7HIL0voYUVmR6Xm/wNWPw@public.gmane.org
>>
>
>
