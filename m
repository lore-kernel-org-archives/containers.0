From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: Re: [PATCH] liblxc: lxc-debian expects missing directories
Date: Thu, 05 Feb 2009 11:21:44 +0100
Message-ID: <498ABDB8.4000702@free.fr>
References: <1233824717.28338.8.camel@localhost> <498AAF77.20906@free.fr>	
	<1233826174.28338.30.camel@localhost>
	<1233827943.28338.49.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1233827943.28338.49.camel@localhost>
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
> On Thu, 2009-02-05 at 01:29 -0800, Matt Helsley wrote:
>   
>> On Thu, 2009-02-05 at 10:20 +0100, Daniel Lezcano wrote:
>>     
>>> Matt Helsley wrote:
>>>       
>>>> lxc-debian fails unless the directories a given rootfs needs already
>>>> exist. To fix this without relying on any particular function call order
>>>> we can do: mkdir -p `dirname PATH/TO/FILE`
>>>> before actually making the file.
>>>>
>>>> Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
>>>> ---
>>>>   
>>>>         
>>> Do you have an example on how that happens ?
>>>       
>> Configure lxc with a non-/ prefix:
>>
>> ./configure --prefix=/usr
>>     
>
> This explanation is wrong, sorry.
>
> The patch isn't necessary -- take a look at the one that handles
> debootstrap interruption/failure. Basically debootstrap would fail
> (apache doesn't exist in lenny I found out) and I'd have to go cleaning
> up lxc-debian directories by hand before I could retry. If I missed
> something one time then then lxc behaved oddly. This got me past some of
> that odd behavior (only to fail later of course).
>   
Ok, I understand why you tried to force the directory creation.
I will not apply this one, the next patch you sent with the partial 
debootstrap will fix this.

Thanks Matt.
