From: Cedric Le Goater <clg@fr.ibm.com>
Subject: Re: [PATCH 0/3] clone64() and unshare64() system calls
Date: Thu, 10 Apr 2008 14:33:10 +0200
Message-ID: <47FE0906.8080102@fr.ibm.com>
References: <20080409222611.GA28087@us.ibm.com> <47FD5899.2040206@zytor.com> <20080410010717.GA28477@us.ibm.com> <47FD6921.6090408@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756500AbYDJMd0@vger.kernel.org>
In-Reply-To: <47FD6921.6090408@zytor.com>
Sender: linux-kernel-owner@vger.kernel.org
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: sukadev@us.ibm.com, Andrew Morton <akpm@osdl.org>, serue@us.ibm.com, "David C. Hansen" <haveblue@us.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

H. Peter Anvin wrote:
> sukadev@us.ibm.com wrote:
>>>
>>> If you're going to make it a 64-bit pass it in as a 64-bit number,
>>> instead of breaking it into two numbers.
>>
>> Maybe I am missing your point. The glibc interface could take a 64bit
>> parameter, but don't we need to pass 32-bit values into the system
>> call on 32 bit systems ?
> 
> Not as such, no.  The ABI handles that.  To make the ABI clean on some
> architectures, it's good to consider a 64-bit value only in positions
> where they map to an even:odd register pair once slotted in.

OK. I didn't know that. I took sys_llseek() as an example of an interface 
to follow when coded clone64(). 

Thanks,

C. 
