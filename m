From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 1/5] The config option itself
Date: Wed, 31 Oct 2007 20:34:52 +0300
Message-ID: <4728BCBC.8030007@openvz.org>
References: <47285FEE.9030001@openvz.org>	<4728615D.5070700@openvz.org>
	<20071031091906.dd84761a.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20071031091906.dd84761a.randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Randy Dunlap <randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Cc: Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Randy Dunlap wrote:
> On Wed, 31 Oct 2007 14:05:01 +0300 Pavel Emelyanov wrote:
> 
>> The option is called NAMESPACES. It can be selectable only
>> if EMBEDDED is chosen (this was Eric's requisition). When
>> the EMBEDDED is off namespaces will be on automatically.
>> Signed-off-by: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
> 
> 
> and when EMBEDDED is on, it looks like NAMESPACES will be off
> automatically (but user-changeable)?  Is that intended?

Yes. The namespaces are likely not needed on cell-phones or similar,
but if the user does want them - he may turn them on.

This was one of Eric's wishes to give only the embedded people the
choice.

> 
>> ---
>>
>> diff --git a/init/Kconfig b/init/Kconfig
>> index c3de3ed..fc76773 100644
>> --- a/init/Kconfig
>> +++ b/init/Kconfig
>> @@ -400,6 +400,15 @@ config RELAY
>>  
>>  	  If unsure, say N.
>>  
>> +config NAMESPACES
>> +	bool "Namespaces support" if EMBEDDED
>> +	default !EMBEDDED
>> +	help
>> +	  Provides the way to make tasks work with different objects using
>> +	  the same id. For example same IPC id may refer to different objects
>> +	  or same user id or pid may refer to different tasks when used in
>> +	  different namespaces.
>> +
>>  config BLK_DEV_INITRD
>>  	bool "Initial RAM filesystem and RAM disk (initramfs/initrd) support"
>>  	depends on BROKEN || !FRV
> 
> 
> ---
> ~Randy
> 
