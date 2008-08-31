From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: linux-2.6-lxc ?
Date: Sun, 31 Aug 2008 02:36:06 -0400
Message-ID: <48BA3BD6.3070407@cs.columbia.edu>
References: <48B6BE55.3000901@fr.ibm.com> <1219938246.5497.6.camel@nimitz>
	<48B800CF.7030206@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <48B800CF.7030206-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi,

I have lots of fixes ready to be posted. I will post them most likely by
Tuesday night (until which I'm away). No need to hold your breath, but
perhaps better to wait until I send them...

Oren.


Cedric Le Goater wrote:
> Dave Hansen wrote:
>> On Thu, 2008-08-28 at 17:03 +0200, Cedric Le Goater wrote:
>>> what's in that git tree ?  
>>>
>>> 	http://git.kernel.org/?p=linux/kernel/git/daveh/linux-2.6-lxc.git;a=summary
>>>
>>> I'd like to start playing with some C/R code. Is that the one to use ? are 
>>> oren patches included ? If not, can I help ? :)
>> Nope, they're not in there, yet.
>>
>> Speaking of which, I should update that.
>>
>> The best thing you could help with would be to try and find any little
>> nuggets from what Oren is doing that can be simplified or pushed
>> upstream, first.  Or those that require something done upstream first.
>> Things where he copy-and-pasted code need to go first.
> 
> To start with, here's a version of oren's patchset for the latest mainline 
> kernel :
> 
> 	http://legoater.free.fr/patches/2.6.27/2.6.27-rc5-orenl-cr-v2/
> 
> I've fixed the patches and ckpt+rstr work as announced.
> 
> Now I'm looking at your own version :
> 
> 	http://legoater.free.fr/patches/2.6.27/2.6.27-rc5-daveh-cr-v2/
> 
> and oren's to see how we can reorganize the bits and pieces.
> 
> Thanks,
> 
> C.
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
