From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: Re: [PATCH] liblxc: Update lxc-debian to use the lenny release
Date: Mon, 09 Feb 2009 22:45:52 +0100
Message-ID: <4990A410.3040701@free.fr>
References: <1233825739.28338.22.camel@localhost>	
	<1233826353.28338.35.camel@localhost> <49906491.8050200@free.fr>
	<1234213118.29561.17.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1234213118.29561.17.camel@localhost>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Matt Helsley wrote:
> On Mon, 2009-02-09 at 18:14 +0100, Daniel Lezcano wrote:
>   
>> Matt Helsley wrote:
>>     
>>> With the release of lenny nearing this patch may soon be useful.
>>>
>>> Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
>>> ---
>>>  scripts/lxc-debian.in |    4 ++--
>>>  1 file changed, 2 insertions(+), 2 deletions(-)
>>>
>>> Index: lxc/scripts/lxc-debian.in
>>> ===================================================================
>>> --- lxc.orig/scripts/lxc-debian.in
>>> +++ lxc/scripts/lxc-debian.in
>>> @@ -222,8 +222,8 @@ create() {
>>>  	        # download a mini debian into a cache
>>>  		echo "Downloading debian minimal ..."
>>>  		debootstrap --verbose --variant=minbase --arch=$ARCH \
>>> -		    --include apache,netbase,net-tools,iproute,openssh-server \
>>> -		    etch $CACHE/partial-$ARCH http://ftp.debian.org/debian
>>> +		    --include apache2,netbase,net-tools,iproute,openssh-server \
>>> +		    lenny $CACHE/partial-$ARCH http://ftp.debian.org/debian
>>>  		
>>>  		RESULT=$?
>>>  		if [ "$RESULT" != "0" ]; then
>>>   
>>>       
>> Applied, thanks Matt.
>>
>> ps : I added the ifupdown missing package because ifup/ifdown are no 
>> longer in the initscripts package.
>>     
>
> 	Hasn't debian switched to Network Manager too? Seems like there should
> be a way to interact with it via scripts without forcing the use of
> ifup/ifdown.
>   
It looks like the minbase does not have the network manager (I didn't 
checked if it is available for "lenny").
So I just made a quick fix adding the ifupdown scripts in order to have 
the debian booting with the network up.
Using the network manager is an interesting solution, but in the short 
term I think the lxc-debian script should be improved to provide a 
simple TUI configuration menu so we can make more complex configurations.
> 	I was somewhat suprised to find debootstrap is incredibly easy to
> install by hand on non-debian systems. Even better, there's a package in
> fedora. So I've been playing with lxc-debian on fedora 9 and 10. However
>   
Yeah, it is a great tool. I am experiencing to do the same with a 
fedora. It may be possible to use yum like debootstrap for an minbase 
fedora install.

> I've had problems "Configuring" the opennssh-server package. Removing
> that package allows lxc-debian to create the rootfs. I haven't found an
> underlying reason yet :/ -- have you run into this problem?
>   
Mmh, no. I just recreated several times a debian, logged via ssh and I 
didn't fall in this problem.
What problem did you faced ?
