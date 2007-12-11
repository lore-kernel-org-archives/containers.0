From: Cedric Le Goater <clg@fr.ibm.com>
Subject: Re: [PATCH][RFC] freezer : add the TIF_FREEZE flag to
	all archs
Date: Tue, 11 Dec 2007 13:31:40 +0100
Message-ID: <475E832C.2010601@fr.ibm.com>
References: <47594F8C.7070900@fr.ibm.com> <200712101736.29676.rjw@sisk.pl>
	<475D6C6D.5010903@sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-pm-bounces@lists.linux-foundation.org>
In-Reply-To: <475D6C6D.5010903@sw.ru>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/linux-pm>,
	<mailto:linux-pm-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/linux-pm>
List-Post: <mailto:linux-pm@lists.linux-foundation.org>
List-Help: <mailto:linux-pm-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/linux-pm>,
	<mailto:linux-pm-request@lists.linux-foundation.org?subject=subscribe>
Sender: linux-pm-bounces@lists.linux-foundation.org
Errors-To: linux-pm-bounces@lists.linux-foundation.org
To: Kirill Korotaev <dev@sw.ru>
Cc: linux-arch@vger.kernel.org, Linux Containers <containers@lists.osdl.org>, linux-pm@lists.linux-foundation.org
List-Id: containers.vger.kernel.org

Kirill Korotaev wrote:
>>> From: Cedric Le Goater <clg@fr.ibm.com>
>>
>> Sorry for the delay, I somehow managed to overlook your message.
>>
>>
>>> This patch is the first step in making the refrigerator() available 
>>> to all architectures, even for those without power management. 
>>>
>>> The purpose of such a change is to be able to use the refrigerator() 
>>> in a new control group subsystem which will implement a control group
>>> freezer.
>>
>> Hm, sounds interesting, but ...
>>  
>>
>>> If you think this is safe and not utterly stupid, I'll send the rest
>>> of the patchset exporting the refrigerator to all arches.
>>
>> ... you will need to provide some details, I think.
>>
>> I also think that it's safe to define TIF_FREEZE for all architectures, but
>> the usefulness of it will very much depend on the purpose. :-)

I'm sending the full patchset, asap

> refrigerator() can be used (and is actually used in OpenVZ containers) to freeze
> container processes for checkpointing (live migration).
> So this can be used regardless system suspend and on all archs.

Exactly !

Thanks,

C.
