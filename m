From: Kirill Korotaev <dev-3ImXcnM4P+0@public.gmane.org>
Subject: Re: [PATCH][RFC] freezer : add the TIF_FREEZE flag to all archs
Date: Mon, 10 Dec 2007 19:42:21 +0300
Message-ID: <475D6C6D.5010903@sw.ru>
References: <47594F8C.7070900@fr.ibm.com> <200712101736.29676.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <200712101736.29676.rjw-KKrjLPT3xs0@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Cc: linux-arch-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

>>From: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
> 
> 
> Sorry for the delay, I somehow managed to overlook your message.
> 
> 
>>This patch is the first step in making the refrigerator() available 
>>to all architectures, even for those without power management. 
>>
>>The purpose of such a change is to be able to use the refrigerator() 
>>in a new control group subsystem which will implement a control group
>>freezer.
> 
> 
> Hm, sounds interesting, but ...
>  
> 
>>If you think this is safe and not utterly stupid, I'll send the rest
>>of the patchset exporting the refrigerator to all arches.
> 
> 
> ... you will need to provide some details, I think.
> 
> I also think that it's safe to define TIF_FREEZE for all architectures, but
> the usefulness of it will very much depend on the purpose. :-)

refrigerator() can be used (and is actually used in OpenVZ containers) to freeze
container processes for checkpointing (live migration).
So this can be used regardless system suspend and on all archs.

Thanks,
Kirill
