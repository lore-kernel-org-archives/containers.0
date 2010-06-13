From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: Re: VRF-like use of Network Namespaces
Date: Sun, 13 Jun 2010 22:30:15 +0200
Message-ID: <4C153FD7.7000400@free.fr>
References: <AANLkTimA_0aZwZM1uZ-GH3OxfEZvegoitaaKTYPLvW5F@mail.gmail.com>	<4C0E6466.3030100@free.fr>	<AANLkTik77W7F7BV7qp9ZQlM3yJCKNydHAMN47FaLTr7Z@mail.gmail.com>	<4C0EB0C5.8070904@free.fr>	<AANLkTinmsRRKdWaf8QONeRRJSQRXPhaUtY1cFv_JGcy8@mail.gmail.com>	<AANLkTilUNrMAeeUjHsXkTwd7Ysx0o9mdl8UaSUvG6wvf@mail.gmail.com>	<4C125BA4.4020300@free.fr>
	<m11vcbl0d5.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m11vcbl0d5.fsf-+imSwln9KH6u2/kzUuoCbdi2O/JbrIOy@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On 06/13/2010 11:59 AM, Eric W. Biederman wrote:
> Daniel Lezcano<daniel.lezcano-GANU6spQydw@public.gmane.org>  writes:
>
>    
>> On 06/11/2010 04:47 PM, Mathieu Peresse wrote:
>>      
>>> Hi,
>>>
>>> [this is related to the use of Eric Biederman's new set of patches for named
>>> netns / netns switching]
>>>
>>> ok so I successfully modified /sbin/ip. I can now:
>>> - add/del a new netns by name: "ip netns {addns,delns} ns_name"
>>> ->   The namespace files are mounted on /var/run/netns/ns_name (so you have to
>>> mkdir /var/run/netns/ for this to work).
>>>
>>>        
>> IMHO, the ip command is not suitable for this, it does not write
>> anything to the fs.
>>      
> It does configuration by all kinds of means.  As far as it goes I
> think the ip command is perfectly suitable in this particular
> situation.  Having a vrf functionality in linux is very desirable.
>    

I agree it would be preferable to centralize all in the ip command.

But the approach proposed by Mathieu relies on the filesystem. I don't 
think there is another solution but having the ip command mounting, 
writing and reading from this directory is a bit weird IMHO, may be 
because it does not do that (or I missed something).

And for this reason, only, I find the ip command not suitable for this.
But I am perfectly fine with the idea in general.

That makes me feel, maybe a 'netnsfs' is missing. IMHO, it is like we 
fork and we store the pid in /var/run/pid/1234.
In the other hand, the 'ip' command is run as root, so we can assume he 
knows what it does, like the 'mount' command writing to /etc/mtab.

> Getting this into ip has the major advantage that we will have a defacto
> standard, and using IFLA_NET_NS_FD makes a lot more sense if everything
> is in ip.
>    

Sure, if the netdev guys are ok with writing into /var/run/netns, I 
won't argue against.

>> You should write you own command, which can be a perl script using the
>> 'unshare' command (util-linux package on my distro).
>>
>> vrf create<name>
>> vrf delete<name>
>> vrf attach<name>
>> vrf list
>>
>> vrf create will bind mount the ns at the place you decided in the script
>> (eg. a tmpfs in order to keep the directory consistent across (unclean)
>> reboots).
>>
>>      
>>> - list netns: "ip netns show"
>>> - use /sbin/ip in any named netns: "ip -netns ns_name link show"
>>>
>>> (rough patch against current git tree attached)
>>>
>>> I want now to move devices across namespaces using their filesystem names
>>> (instead of using PIDs...). I'm not sure I can do it in userspace with the
>>> current code yet, can I ?
>>>
>>>        
>> No, you can do that only with pids, but why don't you move the devices
>> at the create time ?
>> You have all the latitude to do that, no ?
>>      
> Does my published tree not have IFLA_NET_NS_FD in it?

Hmm, AFAICS no.
>>> I saw there was a rtnetlink attribute to set the netns of a device but it
>>> uses the PID of a namespace owner to do so... within 'ip' i can refer to
>>> only one namespace (i.e. the one that 'ip' task_struct->ns_proxy currently
>>> points to), so I won't be able to move an interface from outside my
>>> namespace to my namespace...
>>> I hope my explanation is clear and that this will get some interest... :)
>>>
>>>        
>> Your 'create' command can open a fd to its current  netns, unshare a new
>> namespace, bind mount it, and then return to the previously saved netns.
>>
>>      
>>> BTW is this the right ML to post this on ?
>>>
>>>        
>> Well, this is something related to a subsystem of the containers, so it
>> has some interest but I would suggest to send to the netdev@ mailing
>> list (netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org), maybe cc'ing this mailing list.
>>      
> Anyway it looks like time to post the core of my patchset for review,
> and get things moving on this.
>    
Reviewing in progress ... ;)

Thanks
   -- Daniel
