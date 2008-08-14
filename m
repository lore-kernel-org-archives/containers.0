From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [Devel] Re: [RFC][PATCH 1/4] checkpoint-restart:
	general	infrastructure
Date: Thu, 14 Aug 2008 12:09:00 +0400
Message-ID: <48A3E81C.6010008__34091.2484717139$1218701672$gmane$org@openvz.org>
References: <20080807224033.FFB3A2C1@kernel>	
	<20080807224034.735B1F84@kernel>	<200808081146.54834.arnd@arndb.de>	<1218221451.19082.36.camel@nimitz>
	<489CB3CA.6050304@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <489CB3CA.6050304-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Theodore Tso <tytso-3s7WtUTddSA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Oren Laadan wrote:
> 
> Dave Hansen wrote:
>> On Fri, 2008-08-08 at 11:46 +0200, Arnd Bergmann wrote:
>>> On Friday 08 August 2008, Dave Hansen wrote:
>>>> +	hh->magic = 0x00a2d200;
>>>> +	hh->major = (LINUX_VERSION_CODE >> 16) & 0xff;
>>>> +	hh->minor = (LINUX_VERSION_CODE >> 8) & 0xff;
>>>> +	hh->patch = (LINUX_VERSION_CODE) & 0xff;
>> ...
>>>> +}
>>> Do you rely on the kernel version in order to determine the format
>>> of the binary data, or is it just informational?
>>>
>>> If you think the format can change in incompatible ways, you
>>> probably need something more specific than the version number
>>> these days, because there are just so many different trees with
>>> the same numbers.
>> Yeah, this is very true.  My guess is that we'll need something like
>> what we do with modversions. 
> 
> Exactly. The header should eventually contain sufficient information
> to describe the kernel version, configuration, compiler, cpu (arch and
> capabilities), and checkpoint code version.

Sorry for late response - I was on vacation till Wednesday.

I am opposed against having *explicit* information about the kernel
configuration inside the image.

I see this like we store object images in a file, and these images do 
*not* change depending on the .config. But instead of this, at the time 
of restore we may *only* detect whether we can restore this type of
object or not.

E.g. consider we are saving a container image on ipv6 node and trying 
to restore from it on the one without the ipv6. In that case we *may*
have some object of for example CKPT_IPV6_IFA type of CLPT_IPV6_SOCK_INFO
and fail the restoration process when finding such in an input file. But 
what we should *not* do is to write any information about whether we had
the CONFIG_IPV6 turned on on the dumping side and check for this on the
restoring side.

(Sorry, if this question is already settled, but the discussion thread
 built by my mailer is a bit messy, so I suspect I could miss some part
 of the threads)

> How would you suggest to identify the origin tree with an identifier
> (or a text field) in the header ?
